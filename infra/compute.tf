# Common Lambda Assume Role Policy
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# --- Catalog Lambda ---
resource "aws_iam_role" "catalog_lambda_role" {
  name               = "${var.project_prefix}-catalog-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "catalog_basic" {
  role       = aws_iam_role.catalog_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "catalog_dynamodb" {
  statement {
    actions   = ["dynamodb:Scan", "dynamodb:GetItem", "dynamodb:Query"]
    resources = [aws_dynamodb_table.titles.arn]
  }
}

resource "aws_iam_role_policy" "catalog_dynamodb_policy" {
  name   = "CatalogDynamoDBAccess"
  role   = aws_iam_role.catalog_lambda_role.id
  policy = data.aws_iam_policy_document.catalog_dynamodb.json
}

data "archive_file" "catalog_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/catalog"
  output_path = "${path.module}/catalog.zip"
}

resource "aws_lambda_function" "catalog" {
  filename         = data.archive_file.catalog_zip.output_path
  function_name    = "${var.project_prefix}-catalog"
  role             = aws_iam_role.catalog_lambda_role.arn
  handler          = "handler.handler"
  source_code_hash = data.archive_file.catalog_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 10

  environment {
    variables = {
      TITLES_TABLE = aws_dynamodb_table.titles.name
    }
  }
}

# --- Stream Lambda ---
resource "aws_iam_role" "stream_lambda_role" {
  name               = "${var.project_prefix}-stream-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "stream_basic" {
  role       = aws_iam_role.stream_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "stream_dynamodb" {
  statement {
    actions   = ["dynamodb:GetItem"]
    resources = [aws_dynamodb_table.titles.arn]
  }
}

resource "aws_iam_role_policy" "stream_dynamodb_policy" {
  name   = "StreamDynamoDBAccess"
  role   = aws_iam_role.stream_lambda_role.id
  policy = data.aws_iam_policy_document.stream_dynamodb.json
}

data "archive_file" "stream_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/stream"
  output_path = "${path.module}/stream.zip"
}

resource "aws_lambda_function" "stream" {
  filename         = data.archive_file.stream_zip.output_path
  function_name    = "${var.project_prefix}-stream"
  role             = aws_iam_role.stream_lambda_role.arn
  handler          = "handler.handler"
  source_code_hash = data.archive_file.stream_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 10

  environment {
    variables = {
      TITLES_TABLE      = aws_dynamodb_table.titles.name
      CLOUDFRONT_DOMAIN = aws_cloudfront_distribution.cdn.domain_name
      KEY_PAIR_ID       = aws_cloudfront_public_key.signer.id
      PRIVATE_KEY       = replace(tls_private_key.cf_key.private_key_pem, "\n", "\\n")
    }
  }
}

# --- History Lambda ---
resource "aws_iam_role" "history_lambda_role" {
  name               = "${var.project_prefix}-history-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "history_basic" {
  role       = aws_iam_role.history_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "history_dynamodb" {
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:UpdateItem"]
    resources = [aws_dynamodb_table.watch_history.arn]
  }
}

resource "aws_iam_role_policy" "history_dynamodb_policy" {
  name   = "HistoryDynamoDBAccess"
  role   = aws_iam_role.history_lambda_role.id
  policy = data.aws_iam_policy_document.history_dynamodb.json
}

data "archive_file" "history_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../src/history"
  output_path = "${path.module}/history.zip"
}

resource "aws_lambda_function" "history" {
  filename         = data.archive_file.history_zip.output_path
  function_name    = "${var.project_prefix}-history"
  role             = aws_iam_role.history_lambda_role.arn
  handler          = "handler.handler"
  source_code_hash = data.archive_file.history_zip.output_base64sha256
  runtime          = "python3.12"
  timeout          = 10

  environment {
    variables = {
      HISTORY_TABLE = aws_dynamodb_table.watch_history.name
    }
  }
}

# Auto-create Log Groups to ensure they are cleaned up on destroy
resource "aws_cloudwatch_log_group" "catalog_logs" {
  name              = "/aws/lambda/${aws_lambda_function.catalog.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "stream_logs" {
  name              = "/aws/lambda/${aws_lambda_function.stream.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "history_logs" {
  name              = "/aws/lambda/${aws_lambda_function.history.function_name}"
  retention_in_days = 7
}
