output "api_endpoint" {
  description = "API Gateway HTTP API Endpoint"
  value       = aws_apigatewayv2_api.main.api_endpoint
}

output "cloudfront_domain" {
  description = "CloudFront Distribution Domain Name"
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "cognito_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "s3_bucket_name" {
  description = "S3 Bucket Name"
  value       = aws_s3_bucket.media.id
}

output "cloudfront_key_pair_id" {
  description = "CloudFront Public Key ID for signing URLs"
  value       = aws_cloudfront_public_key.signer.id
}
