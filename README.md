# Azure DBT Snowflake

## Overview
This repository sets up an Azure-based environment for running dbt (Data Build Tool) with Snowflake. The setup includes infrastructure automation with Terraform and a CI/CD pipeline for deploying dbt transformations.

## Prerequisites
Before setting up this project, ensure you have the following installed:

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [Docker](https://docs.docker.com/get-docker/)
- [DBT]([https://docs.getdbt.com/docs/get-started/getting-started-dbt-core](https://docs.getdbt.com/docs/core/installation-overview))
- [Snowflake Account](https://signup.snowflake.com/)
- OpenSSL (Required for key-pair generation) - Install from [OpenSSL](https://slproweb.com/products/Win32OpenSSL.html) (for Windows)

## Project Structure
```
├── baseline/                 # Terraform configuration for foundational infrastructure
├── infra/                    # Terraform configuration for Azure Container Instances
├── tpch_transform/           # dbt models for transformations
├── .github/workflows/        # CI/CD workflows for deployment
└── README.md                 # This documentation
```

## Setup Guide

### 1. Authenticate with Azure
Run the following command to authenticate with Azure:
```sh
az login
```
Ensure you have the correct Azure subscription selected:
```sh
az account set --subscription <subscription-id>
```

### 2. Setup Terraform State Backend
Terraform stores its state in an Azure Storage Account. If the storage account does not exist, you need to create it manually or automate the creation.

To create the storage account using Terraform:
```sh
cd baseline
terraform apply -auto-approve
```

If the backend is not configured correctly, check `backend.tf` under the `baseline` folder and ensure the storage account exists.

### 3. Initialize and Apply Terraform Configuration
After setting up the storage backend, initialize Terraform:
```sh
terraform init
```

Then, apply the Terraform configuration:
```sh
terraform apply -auto-approve
```

### 4. Build and Push Docker Image
Authenticate to the Azure Container Registry (ACR):
```sh
az acr login --name <acr_name>
```
Build the Docker image:
```sh
docker build -t <acr_name>.azurecr.io/dbt/tpch_transform:latest .
```
Push the image to ACR:
```sh
docker push <acr_name>.azurecr.io/dbt/tpch_transform:latest
```

### 5. Deploy the Azure Container Instance
Run Terraform in the `infra` directory to deploy the container instance:
```sh
cd ../infra
terraform apply -auto-approve
```

### 6. Setup DBT for Local Execution
Activate the Python virtual environment:
```sh
source dbt_env/bin/activate  # macOS/Linux
# OR
.\dbt_env\Scripts\activate   # Windows PowerShell
```

Run dbt transformations:
```sh
dbt run
```

### 7. Troubleshooting Issues
#### a. Docker Engine Error on Windows
If you encounter an error related to Docker Desktop Linux Engine:
```sh
error during connect: Get "http://%2F%2F.%2Fpipe%2FdockerDesktopLinuxEngine/..."
```
Ensure Docker is running in Windows mode:
1. Open Docker Desktop
2. Switch to Windows containers if necessary

#### b. Terraform Storage Backend Not Found
If you see a 404 error related to the storage backend:
```sh
Error: retrieving Storage Account... unexpected status 404
```
Ensure the storage account is created by running:
```sh
terraform apply -auto-approve -target=azurerm_storage_account.storageaccount
```

#### c. DBT Command Not Found
If running `dbt run` results in an error:
```sh
' dbt ' is not recognized as an internal or external command
```
Ensure dbt is installed and activated in the virtual environment:
```sh
pip install dbt-core dbt-snowflake
source dbt_env/bin/activate  # macOS/Linux
```

#### d. Snowflake Authentication Issues
If you receive an error like:
```sh
Password was not given but private key is encrypted
```
Ensure you have set up the private key correctly:
```sh
openssl genrsa -out rsa_key.pem 2048
openssl rsa -in rsa_key.pem -pubout -out rsa_key.pub
```
Use the public key in Snowflake user settings.

## References
- [DBT Documentation](https://docs.getdbt.com/docs/introduction)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Snowflake Setup](https://docs.snowflake.com/en/user-guide/admin-security-fed-auth-use)

## Conclusion
This guide provides step-by-step instructions to set up and deploy dbt on Azure with Terraform and Snowflake. Follow the troubleshooting steps to resolve common issues. For further improvements or issues, feel free to raise a GitHub issue.

---
_Last updated: March 2025_

