# IaC Utilities

This directory contains small, auxiliary tools designed to help mitigate and automate tasks that fall outside the scope of Terraform and Ansible. These utilities address common operational needs in infrastructure management workflows.

## Available Utilities

### set-aws-creds.py

A Python script for managing AWS temporary credentials using Multi-Factor Authentication (MFA).

#### Purpose

This utility simplifies the process of obtaining and configuring temporary AWS session credentials when MFA is required. It automates the workflow of:
- Retrieving your MFA device information
- Generating temporary credentials via AWS STS
- Updating your AWS CLI configuration with the session credentials

This is particularly useful when working with AWS accounts that enforce MFA for API access, as it eliminates the manual process of obtaining and configuring temporary credentials.

#### Requirements

- Python 3.x
- AWS CLI installed and configured
- boto3 library (`pip install boto3`)
- Valid AWS credentials configured (with MFA device attached to the IAM user)
- An active MFA device associated with your AWS account

#### Usage

Basic usage with default profile:
```bash
python set-aws-creds.py
```

Specify a custom profile name:
```bash
python set-aws-creds.py --profile my-mfa-profile
```

#### Command Line Arguments

- `--profile`: AWS profile name to create/update with temporary credentials (default: `mfa`)
  - The profile will be created if it doesn't already exist

#### How It Works

1. Retrieves your AWS identity using your configured credentials
2. Fetches your MFA device serial number from IAM
3. Prompts you to enter your 6-digit MFA code
4. Validates the MFA code format (must be 6 digits)
5. Requests temporary session credentials from AWS STS
6. Updates the specified AWS CLI profile with the temporary credentials
7. Displays the expiration time for the credentials

#### Example Output

```
Your MFA device is: arn:aws:iam::123456789012:mfa/username
Enter your MFA code now: 123456
Keys valid until 2026-01-07 12:34:56+00:00
```

#### Using the Temporary Credentials

After running the script, use the configured profile with AWS CLI or Terraform:

```bash
# AWS CLI
aws s3 ls --profile mfa

# Terraform
export AWS_PROFILE=mfa
terraform plan
```

#### Error Handling

The script provides clear error messages for common issues:
- Missing or invalid AWS credentials
- No MFA device found for the user
- Invalid MFA code format
- AWS API errors

#### Notes

- Temporary credentials are typically valid for 12 hours (AWS default)
- If you have multiple MFA devices, the script uses the first one found
- The script updates the AWS CLI configuration file directly (`~/.aws/credentials`)
- If your credentials file doesn't already contain the default (`mfa`) profile,
or the profile providede via the `--profile` parameter - a new profile block will be created with that name.
