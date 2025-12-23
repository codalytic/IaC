# ============================================================================
# Notes:
# - This code is loosely based on Terraform's example from their documentation
#   https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration


# ============================================================================
# IAM Resources (Foundation)
# ============================================================================
# IAM role and policy for S3 bucket replication

resource "aws_iam_role" "replication" {
  name               = var.replication_iam_role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "replication" {
  name   = var.replication_iam_policy
  policy = data.aws_iam_policy_document.replication.json
}

resource "aws_iam_role_policy_attachment" "replication" {
  role       = aws_iam_role.replication.name
  policy_arn = aws_iam_policy.replication.arn
}


# ============================================================================
# Primary Backend S3 Bucket
# ============================================================================
# Main S3 bucket for Terraform state storage

resource "aws_s3_bucket" "backend_bucket" {
  bucket = var.backend_bucket
  tags   = merge(var.backend_tags, var.backend_bucket_additional_tags)
}

resource "aws_s3_bucket_versioning" "backend_bucket_versioning" {
  bucket = aws_s3_bucket.backend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "backend-bucket-policy" {
  bucket = aws_s3_bucket.backend_bucket.id
  policy = data.aws_iam_policy_document.tf-state-bucket-policy.json
}


# ============================================================================
# Replication Target S3 Bucket
# ============================================================================
# Secondary S3 bucket for cross-region replication

resource "aws_s3_bucket" "backend_replication_target_bucket" {
  bucket   = var.target_bucket
  tags     = merge(var.backend_tags, var.target_bucket_additional_tags)
  provider = aws.target
}

resource "aws_s3_bucket_versioning" "backend_replication_target_bucket_versioning" {
  provider = aws.target
  bucket   = aws_s3_bucket.backend_replication_target_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# ============================================================================
# S3 Replication Configuration
# ============================================================================
# Configures replication from primary to target bucket

resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws
  # Must have bucket versioning enabled first
  depends_on = [aws_s3_bucket_versioning.backend_bucket_versioning]

  role   = aws_iam_role.replication.arn
  bucket = aws_s3_bucket.backend_bucket.id

  rule {
    id = "replication"
    delete_marker_replication {
      status = "Enabled"
    }

    filter {}

    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.backend_replication_target_bucket.arn
      storage_class = "STANDARD"
    }
  }
}


# ============================================================================
# DynamoDB State Lock Table
# ============================================================================
# DynamoDB table for Terraform state locking

resource "aws_dynamodb_table" "terraform-backend-lock" {
  name           = var.backend_dd.name
  read_capacity  = var.backend_dd.read_capacity
  write_capacity = var.backend_dd.write_capacity
  hash_key       = var.backend_dd.hash_key
  attribute {
    name = var.backend_dd.attribute.name
    type = var.backend_dd.attribute.type
  }
  tags = var.backend_tags
}

resource "aws_dynamodb_resource_policy" "terraform-backend-lock-policy" {
  resource_arn = aws_dynamodb_table.terraform-backend-lock.arn
  policy       = data.aws_iam_policy_document.tf-state-lock-policy.json
}
