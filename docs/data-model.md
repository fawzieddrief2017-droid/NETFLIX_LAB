# DynamoDB Data Models

## 1. Titles Table
**Table Name**: `Titles`
**Billing Mode**: `PAY_PER_REQUEST` (On-Demand)

### Schema
- **Partition Key (PK)**: `titleId` (String)

### Attributes
| Attribute | Type | Description | Example |
|---|---|---|---|
| `titleId` | String | Unique identifier | `title_123` |
| `title` | String | Display name | `AWS Architect Journey` |
| `genre` | String | Content category | `Documentary` |
| `description` | String | Brief summary | `Learn AWS by building...` |
| `thumbnailKey` | String | S3 prefix path for image | `thumbnails/title_123.jpg` |
| `videoKey` | String | S3 prefix path for video | `videos/title_123.mp4` |

---

## 2. WatchHistory Table
**Table Name**: `WatchHistory`
**Billing Mode**: `PAY_PER_REQUEST` (On-Demand)

### Schema
- **Partition Key (PK)**: `userId` (String) - Cognito User ID (`sub`)
- **Sort Key (SK)**: `titleId` (String)

### Attributes
| Attribute | Type | Description | Example |
|---|---|---|---|
| `userId` | String | Cognito Subject ID | `uuid-from-cognito` |
| `titleId` | String | Title ID being watched | `title_123` |
| `lastTimestamp`| Number | Position in seconds | `125` |
| `lastUpdated` | String | ISO-8601 Timestamp | `2026-06-11T12:00:00Z` |
| `completed` | Boolean| If the video was finished | `false` |
