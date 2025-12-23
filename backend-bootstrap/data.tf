data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "tf-state-lock-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.terraform_trusted_role_arn]
    }

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]

    resources = [aws_dynamodb_table.terraform-backend-lock.arn]
  }
}

data "aws_iam_policy_document" "replication" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket",
    ]
    resources = ["${aws_s3_bucket.backend_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]
    resources = ["${aws_s3_bucket.backend_bucket.arn}/*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags",
    ]

    resources = ["${aws_s3_bucket.backend_replication_target_bucket.arn}/*"]
  }
}

data "aws_iam_policy_document" "tf-state-bucket-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.terraform_trusted_role_arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      aws_s3_bucket.backend_bucket.arn,
      "${aws_s3_bucket.backend_bucket.arn}/*"
    ]
  }
}
