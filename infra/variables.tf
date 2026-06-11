variable "aws_region" {
  type        = string
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "project_prefix" {
  type        = string
  description = "Prefix for resource names"
  default     = "netflix-lab"
}

variable "budget_amount" {
  type        = string
  description = "Monthly budget threshold in USD"
  default     = "5.0"
}

variable "budget_email" {
  type        = string
  description = "Email address for budget alerts (optional)"
  default     = ""
}
