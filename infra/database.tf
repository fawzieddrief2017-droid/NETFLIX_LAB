resource "aws_dynamodb_table" "titles" {
  name         = "${var.project_prefix}-Titles"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "titleId"

  attribute {
    name = "titleId"
    type = "S"
  }
}

resource "aws_dynamodb_table" "watch_history" {
  name         = "${var.project_prefix}-WatchHistory"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "titleId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "titleId"
    type = "S"
  }
}
