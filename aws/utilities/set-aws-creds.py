"""
AWS MFA Authentication Script
This script retrieves temporary AWS credentials using Multi-Factor Authentication (MFA).
It prompts the user for their MFA code, validates it, and updates the AWS CLI configuration
with temporary session credentials.
The script performs the following operations:
1. Parses command line arguments to specify the AWS profile to update
2. Retrieves the current AWS user's identity
3. Fetches the user's MFA device serial number
4. Prompts for and validates a 6-digit MFA code
5. Requests temporary session credentials from AWS STS
6. Updates the specified AWS CLI profile with the new credentials
Command Line Arguments:
    --profile: AWS profile name to update (default: 'mfa', optional. 
    * Default / provided profile will be created if it doesn't already exist.
Requirements:
    - AWS CLI must be installed and configured
    - User must have valid AWS credentials configured
    - User must have an MFA device associated with their AWS account
    - boto3 library must be installed
Example:
    python set-aws-creds.py --profile my-mfa-profile
Raises:
    SystemExit: If credentials are invalid, MFA device not found, or other errors occur
"""

import argparse
import sys
import boto3
import botocore.exceptions
import subprocess

# Parse command line arguments for AWS profile name (Optional, defaults to 'mfa').
parser = argparse.ArgumentParser(description='Get temporary AWS credentials using MFA')
parser.add_argument('--profile', default='mfa', help='AWS profile name to update (default: mfa)')
args = parser.parse_args()

# Function to update AWS CLI configuration with new credentials.
# * Requires AWS CLI to be installed and configured.
def update_via_cli(profile, key, secret, token):
    commands = [
        ('aws_access_key_id', key),
        ('aws_secret_access_key', secret),
        ('aws_session_token', token)
    ]
    
    for config_key, value in commands:
        subprocess.run([
            'aws', 'configure', 'set',
            config_key, value,
            '--profile', profile
        ], check=True)

profile = args.profile
sts_client = boto3.client('sts')
iam_client = boto3.client('iam')

try:
    sts_response = sts_client.get_caller_identity()
except botocore.exceptions.NoCredentialsError:
    print('Error retrieving caller identity. Please check your AWS credentials and configuration.')
    sys.exit(1)
except Exception as e:
    print(f'Unexpected error: {e}')
    sys.exit(1)

username = sts_response['Arn'].split('/')[-1]

# Retrieve the MFA device associated with the user.
# Assumes the user has exactly one MFA device / use the first one found; Multiple devices are not currently supported.
try:
    mfadevice = iam_client.list_mfa_devices(
        UserName = username
    )['MFADevices'][0]['SerialNumber']
except IndexError:
    print('No MFA devices found for the user. Please set up an MFA device in the AWS Console.')
    sys.exit(1)
except Exception as e:
    print(f'Error retrieving MFA devices: {e}')
    sys.exit(1) 

print(f'Your MFA device is: {mfadevice}')

while True:
    mfacode = input('Enter your MFA code now: ').strip()
    if len(mfacode) == 6 and mfacode.isdigit():
        break
    print('MFA code must be a 6 digit number. Please try again.')

tokens = sts_client.get_session_token(
    SerialNumber = mfadevice,
    TokenCode = mfacode
)

secret_access_key = tokens['Credentials']['SecretAccessKey']
session_token = tokens['Credentials']['SessionToken']
access_key_id = tokens['Credentials']['AccessKeyId']
expiration = tokens['Credentials']['Expiration']

# Update AWS CLI configuration with new temporary credentials.
update_via_cli(profile, access_key_id, secret_access_key, session_token)

print(f'Keys valid until {expiration}')
