# Feature Spec: Mini AWS Netflix-Like Streaming Platform — Architecture Only

## Summary
A small-scale, educational AWS cloud architecture inspired by Netflix's infrastructure
patterns, deployed entirely via Terraform. The system supports user auth (Cognito),
content catalog (DynamoDB + Python Lambda), video storage and delivery (single S3 bucket +
CloudFront signed URLs), a serverless HTTP API (API Gateway), watch history, and basic
monitoring (CloudWatch) — single region, free-tier-friendly, IaC-first.

---

## Goals
1. Design a realistic, deployable AWS architecture for an intermediate learner.
2. Cover all major Netflix-inspired infrastructure domains at lab scale.
3. Maximize use of AWS Free Tier / always-free services.
4. Keep the architecture serverless, single-region, and deployable via Terraform.
5. Produce a spec that drives a concrete Terraform-based implementation plan.

---

## Non-Goals
- No frontend code, UI design, or web page implementation.
- No video transcoding pipeline in MVP (pre-encoded MP4 only).
- No Kubernetes, ECS, or large EC2 fleets.
- No multi-region or multi-CDN setup.
- No enterprise microservices sprawl.
- No custom Lambda authorizers — native Cognito JWT authorizer only.
- No multiple S3 buckets — single bucket with key prefixes.
- Not a production platform — no SLAs or compliance scope.

---

## Actors
| Actor | Role |
|---|---|
| Learner / Builder | Writes Terraform, deploys and operates the infrastructure |
| Test Viewer | Authenticates, browses catalog, plays videos, saves/resumes progress |
| AWS Platform | Hosts, secures, and monitors all components |

---

## Functional Areas (Architecture Scope)

### 1. User Authentication
- Amazon Cognito User Pool: sign-up, sign-in, JWT issuance.
- API Gateway HTTP API uses the native Cognito JWT authorizer.
- All protected routes validate the token before Lambda is invoked.

### 2. Content Catalog Metadata
- DynamoDB `Titles` table: titleId (PK), title, genre, description,
  thumbnailKey, videoKey.
- DynamoDB `Episodes` table (optional): episodeId (PK), titleId (SK),
  season, episodeNumber, videoKey.
- Python Lambda serves catalog reads via API Gateway.

### 3. Video & Asset Storage
- Single private S3 bucket with key prefixes:
  - `videos/`      → pre-encoded MP4 files
  - `thumbnails/`  → title thumbnail images
- S3 Block Public Access fully enabled.
- All access exclusively via CloudFront OAC.

### 4. Video Delivery
- CloudFront distribution with single OAC on the S3 bucket.
- Python Lambda (stream-handler) generates short-lived CloudFront signed URLs
  scoped to `videos/*`.
- Thumbnails served via standard (unsigned) CloudFront URLs from `thumbnails/*`.

### 5. API Layer
- API Gateway HTTP API with native Cognito JWT authorizer.
- Routes:
  - GET  /titles                        → list catalog
  - GET  /titles/{id}                   → title detail + thumbnail URL
  - GET  /titles/{id}/stream            → signed CloudFront video URL
  - GET  /users/{id}/history/{titleId}  → get watch position
  - POST /users/{id}/history            → save watch position

### 6. Backend Business Logic — Python Lambda Functions
- Runtime: Python 3.12 across all functions.
- Three functions, each with a dedicated least-privilege IAM role:
  - `catalog-handler`  → handles /titles routes, queries DynamoDB Titles table
  - `stream-handler`   → generates CloudFront signed URLs using Python `rsa` + boto3
  - `history-handler`  → reads/writes WatchHistory in DynamoDB

### 7. Watch History / Continue Watching
- DynamoDB `WatchHistory` table:
  - PK: userId | SK: titleId
  - Attributes: lastTimestamp (number, seconds), lastUpdated (string), completed (boolean)
- `history-handler` Lambda upserts on pause/exit; reads on title open.
- Missing record → `{ "timestamp": 0 }`, plays from start.

### 8. Monitoring and Logging
- CloudWatch Logs: one log group per Lambda function (auto-created).
- CloudWatch Metrics: Lambda errors/duration, API Gateway 4xx/5xx rates.
- CloudWatch Alarm: Lambda error spike → optional SNS email alert.
- AWS Budgets: $5/month billing alarm as primary cost guardrail.

---

## Constraints
- Single AWS region: us-east-1.
- IaC: Terraform only (HCL).
- Terraform state: local backend (learner's machine) — no remote S3 state for MVP.
- Single S3 bucket with `/videos/` and `/thumbnails/` key prefixes.
- Lambda runtime: Python 3.12 for all functions.
- Video library: ≤ 10 pre-encoded MP4 files (≤ 720p), manually uploaded post-apply.
- Concurrent users: < 5 (lab scale).
- All compute: Lambda only.
- API Gateway: HTTP API type only.
- No custom domain in MVP.
- Budget guard: AWS Budget alarm at $5/month.
