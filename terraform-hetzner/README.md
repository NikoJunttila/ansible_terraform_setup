# Hetzner Cloud VPS with Terraform

This project sets up a simple VPS on Hetzner Cloud using Terraform.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) installed.
- A [Hetzner Cloud account](https://console.hetzner.cloud/).

## Setup Instructions

### 1. Get Hetzner Cloud API Token

1.  Log in to the [Hetzner Cloud Console](https://console.hetzner.cloud/).
2.  Select your project (or create a new one).
3.  In the left sidebar, click on **Security**.
4.  Go to the **API Tokens** tab.
5.  Click **Generate API Token**.
6.  Give it a name (e.g., "terraform") and ensure it has **Read & Write** permissions.
7.  **Copy the token immediately**—you won't be able to see it again!

### 2. Configure the API Token

You can provide the token in two ways:

#### Option A: Environment Variable (Recommended)
This keeps your token out of your codebase.
```bash
export TF_VAR_hcloud_token="your_actual_token_here"
```

#### Option B: Variables File
Create a file named `terraform.tfvars` (which should be ignored by Git) and add:
```hcl
hcloud_token = "your_actual_token_here"
```

### 3. Setup SSH Key

Terraform is configured to read your public key from a file path.

1.  **Generate a dedicated key** (if you don't have one):
    ```bash
    ssh-keygen -t ed25519 -f ~/.ssh/hcloud-key -C "hcloud-key"
    ```
    This will create `~/.ssh/hcloud-key` (private) and `~/.ssh/hcloud-key.pub` (public).

2.  **Configure the path**:
    By default, it uses `~/.ssh/hcloud-key.pub`. You can change this in `variables.tf` or override it in `terraform.tfvars`:
    ```hcl
    public_key_path = "~/.ssh/hcloud-key.pub"
    ```

## Usage

1.  **Login to Terraform Cloud**:
    ```bash
    terraform login
    ```
    Follow the prompts to create an API token and paste it into the terminal.

2.  **Configure HCP Terraform Workspace**:
    After logging in and initializing, go to your workspace in the HCP Terraform UI and verify these settings:
    - **Execution Mode**: Set to **Local**. This is required so Terraform can read your local SSH key file and environment variables. If set to "Remote", the `file()` function and `TF_VAR_` variables will not work out of the box.
    - **Remote State Sharing**: Under **Settings > General**, ensure your state sharing is configured appropriately (usually "Share with all workspaces in this organization" if you plan to reference this VPS state elsewhere).

3.  **Configure Organization**:
    ```bash
    terraform init
    ```
    If you have existing local state, Terraform will ask to migrate it to the cloud.

4.  **Preview Changes**:
    ```bash
    terraform plan
    ```

5.  **Deploy**:
    ```bash
    terraform apply
    ```

4.  **Connect**:
    Once deployed, get the IP from the output and connect:
    ```bash
    ssh root@<server_ipv3>
    ```
