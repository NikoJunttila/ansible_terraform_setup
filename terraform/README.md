# Terraform ARM Lab Setup

This directory contains the Terraform configuration to provision a cost-efficient ARM64 EC2 instance (`t4g.nano`) on AWS. This infrastructure serves as the target environment for our Ansible lab.

## Prerequisites

Before you begin, ensure you have the following configured on your local machine:

### 1. AWS Account & Credentials
You need an AWS account and a user with permissions to create EC2 instances, Security Groups, and Key Pairs.

**Configure AWS CLI:**
If you strictly want to use Terraform, setting up the AWS CLI credentials file is the easiest way for Terraform to authenticate.

1.  Install the [AWS CLI](https://aws.amazon.com/cli/).
2.  Run `aws configure` and enter your credentials:
    get access key and secret key from your AWS account by going to the AWS Console -> your name top right -> Security Credentials -> Access keys -> Create Access Key
    ```bash
    aws configure
    # AWS Access Key ID [None]: YOUR_ACCESS_KEY
    # AWS Secret Access Key [None]: YOUR_SECRET_KEY
    # Default region name [None]: eu-north-1
    # Default output format [None]: json
    ```
    This creates files in `~/.aws/credentials` and `~/.aws/config` which Terraform automatically detects.

### 2. SSH Key Pair
You need an SSH key pair to connect to the instance.

**Generate a new key (if you don't have one):**
```bash
ssh-keygen -t ed25519 -C "ansible-lab" -f ~/.ssh/ansible-lab
```
This creates `~/.ssh/ansible-lab` (private key) and `~/.ssh/ansible-lab.pub` (public key).

## Configuration

1.  Copy the example variables file:
    ```bash
    cp terraform.tfvars.example terraform.tfvars
    ```
2.  Edit `terraform.tfvars`:
    - `key_name`: The name you want for the Key Pair in AWS (e.g., "ansible-lab-key").
    - `public_key_path`: Path to your local public key (default: `~/.ssh/ansible-lab.pub`). Terraform will upload this key to AWS automatically.

## Usage

### 1. Initialize
Downloads the AWS provider plugins.
```bash
terraform init
```

### 2. Plan
Preview the changes Terraform will make.
```bash
terraform plan
```

### 3. Apply
Create the infrastructure.
```bash
terraform apply
```
Type `yes` when prompted.

### 4. Connect
After applying, Terraform will output the `public_ip`. You can SSH into the instance:
```bash
ssh -i ~/.ssh/YOUR_PRIVATE_KEY ubuntu@<public_ip>
```

### 5. Destroy
When you are done testing to save costs:
```bash
terraform destroy
```

## Resources Created
- **EC2 Instance:** `t4g.nano` (ARM64) with Ubuntu 22.04/24.04.
    - **Note:** Includes `AutoKill = "24h"` tag. This tag *does not* automatically destroy the instance unless you have an external tool (like cloud-nuke or a Lambda janitor) configured to respect it.
- **Security Group:** Allows inbound SSH (port 22) from the specified CIDR (default 0.0.0.0/0).
