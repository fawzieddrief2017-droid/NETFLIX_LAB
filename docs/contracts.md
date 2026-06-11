# API Contracts (API Gateway HTTP API)

**Base URL**: `https://{api-id}.execute-api.us-east-1.amazonaws.com`
**Authorization**: `Authorization: Bearer <Cognito-JWT-Access-Token>` (Required for all routes)

---

## 1. Get Catalog
- **Endpoint**: `GET /titles`
- **Description**: Returns all available titles in the catalog.
- **Response** (200 OK):
  ```json
  [
    {
      "titleId": "title_123",
      "title": "AWS Architect Journey",
      "genre": "Documentary",
      "description": "Learn AWS by building...",
      "thumbnailUrl": "https://{cloudfront-domain}/thumbnails/title_123.jpg"
    }
  ]
  ```

## 2. Get Title Detail
- **Endpoint**: `GET /titles/{id}`
- **Description**: Returns details for a specific title.
- **Response** (200 OK):
  ```json
  {
    "titleId": "title_123",
    "title": "AWS Architect Journey",
    "genre": "Documentary",
    "description": "Learn AWS by building...",
    "thumbnailUrl": "https://{cloudfront-domain}/thumbnails/title_123.jpg"
  }
  ```

## 3. Get Stream URL
- **Endpoint**: `GET /titles/{id}/stream`
- **Description**: Generates a short-lived CloudFront signed URL for video playback.
- **Response** (200 OK):
  ```json
  {
    "streamUrl": "https://{cloudfront-domain}/videos/title_123.mp4?Expires=...&Signature=...&Key-Pair-Id=..."
  }
  ```

## 4. Get Watch History
- **Endpoint**: `GET /users/{userId}/history/{titleId}`
- **Description**: Gets the last saved playback position.
- **Response** (200 OK):
  ```json
  {
    "userId": "uuid-from-cognito",
    "titleId": "title_123",
    "lastTimestamp": 125,
    "completed": false
  }
  ```
  *(If no history exists, returns `{"lastTimestamp": 0, "completed": false}`)*

## 5. Update Watch History
- **Endpoint**: `POST /users/{userId}/history`
- **Description**: Saves the current playback position.
- **Request Body**:
  ```json
  {
    "titleId": "title_123",
    "lastTimestamp": 130,
    "completed": false
  }
  ```
- **Response** (200 OK):
  ```json
  {
    "message": "History updated successfully"
  }
  ```
