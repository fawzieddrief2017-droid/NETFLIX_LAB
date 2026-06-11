# Quickstart: Deploying the Mini AWS Netflix-like Platform

This guide explains how to deploy the infrastructure and sample data using Terraform.

## Prerequisites
1. **AWS CLI** configured (`aws configure`) with Administrator permissions.
2. **Terraform** installed (`terraform -v`).
3. **Python 3.12** installed for packaging Lambda functions.

## Step 1: Initialize Terraform
Navigate to the `infra/` directory and initialize Terraform:
```bash
cd infra
terraform init
```

## Step 2: Generate RSA Keys for CloudFront
We need a key pair to sign CloudFront URLs. Run the following to generate keys locally (do not commit `private_key.pem` to Git):
```bash
openssl genrsa -out private_key.pem 2048
openssl rsa -pubout -in private_key.pem -out public_key.pem
```

## Step 3: Package Python Lambdas
Install dependencies into the respective Lambda directories:
```bash
cd ../src/catalog && pip install -r requirements.txt -t .
cd ../stream && pip install -r requirements.txt -t .
cd ../history && pip install -r requirements.txt -t .
cd ../../infra
```

## Step 4: Deploy
Review the deployment plan, then apply:
```bash
terraform plan
terraform apply
```
*Note: Terraform will automatically zip the Lambda directories during deployment.*

## Step 5: Post-Deployment Setup
After `terraform apply` finishes, it will output variables like `s3_bucket_name` and `cognito_user_pool_id`.

1. **Upload Assets**:
   - Upload sample MP4s to `s3://<bucket-name>/videos/`
   - Upload sample JPGs to `s3://<bucket-name>/thumbnails/`

2. **Populate DynamoDB**:
   - Manually insert a record into the `Titles` table matching the files you uploaded.

3. **Test API**:
   - Create a test user in Cognito.
   - Get a JWT token and use it as a Bearer token against the API Gateway endpoints.
