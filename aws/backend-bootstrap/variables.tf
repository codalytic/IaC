variable "aws_profile" {
  type        = string
  description = "aws profile to use"
  default     = ""
}

variable "aws_region" {
  type        = string
  description = "aws source region to use"
  default     = ""
}

variable "aws_target_region" {
  type        = string
  description = "aws target region to use"
  default     = ""
}
variable "backend_bucket" {
  type        = string
  description = "Backend s3 bucket for Terraform's remote state"
  default     = ""
}

variable "target_bucket" {
  type        = string
  description = "Backend s3 bucket for Terraform's remote state"
  default     = ""
}

variable "terraform_trusted_role_arn" {
  type        = string
  description = "Trusted role arn for the backend's IAM policies"
  default     = ""
}

variable "replication_iam_role" {
  type        = string
  description = "Replication IAM role name to use"
  default     = ""
}

variable "replication_iam_policy" {
  type        = string
  description = "Replication IAM policy name to use"
  default     = ""
}

variable "backend_tags" {
  description = "Common tags to be assigned to all backend resources"
  type        = map(string)
  default     = {}
}

variable "backend_bucket_additional_tags" {
  description = "Additional tags specific to the primary backend bucket (merged with backend_tags)"
  type        = map(string)
  default     = {}
}

variable "target_bucket_additional_tags" {
  description = "Additional tags specific to the replication target bucket (merged with backend_tags)"
  type        = map(string)
  default     = {}
}

variable "backend_dd" {
  type = object({
    lock_table     = string
    name           = string
    read_capacity  = number
    write_capacity = number
    hash_key       = string
    attribute = object({
      name = string
      type = string
    })
  })
}
