# How to Use Terraform Multi-Cloud Templates

This comprehensive guide provides step-by-step instructions for using the production-ready Terraform templates to deploy infrastructure across AWS, Azure, GCP, IBM Cloud, Alibaba Cloud, and OCI.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Repository Structure](#repository-structure)
3. [Quick Start](#quick-start)
4. [Cloud Provider Setup](#cloud-provider-setup)
5. [Deploying Infrastructure](#deploying-infrastructure)
6. [Configuration Examples](#configuration-examples)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

Before using these templates, ensure you have:

- **Terraform** v1.0 or higher installed
- **Cloud Provider CLIs** installed and configured:
  - AWS CLI v2
  - Azure CLI
  - Google Cloud SDK
  - IBM Cloud CLI
  - Alibaba Cloud CLI
  - OCI CLI
- **Appropriate credentials and permissions** for each cloud provider
- **Git** for cloning the repository

### Installation Steps

```bash
# Install Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# Verify installation
terraform version
```

## Repository Structure

The repository is organized by cloud provider with modular architecture:

```
terraform-multi-cloud-templates/
├── aws/
│   ├── modules/
│   │   ├── vpc/
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── ec2/
│   │   ├── rds/
│   │   └── s3/
│   └── environments/
│       ├── dev/
│       ├── staging/
│       └── prod/
├── azure/
│   ├── modules/
│   │   ├── vnet/
│   │   ├── compute/
│   │   └── storage/
│   └── environments/
├── gcp/
│   ├── modules/
│   │   ├── vpc/
│   │   ├── compute/
│   │   └── cloud_sql/
│   └── environments/
├── ibm/
├── alibabacloud/
├── oci/
├── README.md
├── HOW_TO_USE.md
└── terraform.tfvars.example
```

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/Manjunathsmurthy/terraform-multi-cloud-templates.git
cd terraform-multi-cloud-templates
```

### 2. Initialize Terraform

```bash
# For AWS
cd aws/modules/vpc
terraform init

# For Azure
cd azure/modules/vnet
terraform init

# For GCP
cd gcp/modules/vpc
terraform init
```

### 3. Plan and Apply

```bash
# Create terraform.tfvars with your configuration
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Edit with your values

# Review the plan
terraform plan -out=tfplan

# Apply the configuration
terraform apply tfplan
```

## Cloud Provider Setup

### AWS Setup

```bash
# Configure AWS credentials
aws configure

# Or use environment variables
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"

# Verify connection
aws sts get-caller-identity
```

**Provider Configuration Example:**

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

### Azure Setup

```bash
# Login to Azure
az login

# Set default subscription
az account set --subscription "subscription-id"

# Verify connection
az account show
```

### GCP Setup

```bash
# Authenticate with GCP
gcloud auth application-default login

# Set default project
gcloud config set project PROJECT_ID

# Verify connection
gcloud auth list
```

### IBM Cloud Setup

```bash
# Login to IBM Cloud
ibmcloud login

# Target the correct resource group
ibmcloud target -g resource-group-name

# Verify connection
ibmcloud account show
```

### Alibaba Cloud Setup

```bash
# Configure Alibaba Cloud credentials
cat > ~/.aliyun/config.json << EOF
{
  "current": "default",
  "profiles": [
    {
      "name": "default",
      "mode": "AK",
      "access_key_id": "your-access-key",
      "access_key_secret": "your-secret-key",
      "region_id": "cn-hangzhou"
    }
  ]
}
EOF
```

### OCI Setup

```bash
# Configure OCI credentials
mkdir -p ~/.oci
# Copy your API key to ~/.oci/
# Update ~/.oci/config with your credentials

# Verify connection
oci os ns get
```

## Deploying Infrastructure

### AWS VPC Deployment

**Step 1: Create variables file**

```bash
cd aws/modules/vpc
cat > terraform.tfvars << EOF
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
environment = "production"
common_tags = {
  Project = "CloudInfra"
  Team    = "DevOps"
}
EOF
```

**Step 2: Initialize and deploy**

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

**Step 3: Retrieve outputs**

```bash
terraform output -json > outputs.json
terraform output vpc_id
terraform output public_subnets
```

### Azure VNet Deployment

**Step 1: Create variables file**

```bash
cd azure/modules/vnet
cat > terraform.tfvars << EOF
resource_group_name = "myResourceGroup"
location = "East US"
vnet_name = "myVNet"
vnet_address_space = "10.0.0.0/16"
public_subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_prefixes = ["10.0.11.0/24", "10.0.12.0/24"]
environment = "production"
EOF
```

**Step 2: Deploy**

```bash
terraform init
terraform apply -auto-approve
```

### GCP VPC Deployment

**Step 1: Create variables file**

```bash
cd gcp/modules/vpc
cat > terraform.tfvars << EOF
network_name = "my-vpc"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
region = "us-central1"
environment = "production"
EOF
```

**Step 2: Deploy**

```bash
terraform init
terraform apply -auto-approve
```

## Configuration Examples

### Example 1: Multi-Environment Setup

```hcl
# environments/prod/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr               = "10.0.0.0/16"
  public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs   = ["10.0.11.0/24", "10.0.12.0/24"]
  environment            = "production"
  
  common_tags = {
    Environment = "Production"
    Project     = "MyApp"
    Owner       = "TeamA"
  }
}
```

### Example 2: Using Remote State

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/vpc/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### Example 3: Cross-Cloud Deployment

```bash
# Deploy to AWS
cd aws/modules/vpc && terraform apply -auto-approve

# Deploy to Azure
cd ../../azure/modules/vnet && terraform apply -auto-approve

# Deploy to GCP
cd ../../gcp/modules/vpc && terraform apply -auto-approve
```

## Best Practices

### 1. State Management

- Always use remote state for team environments
- Enable state locking with DynamoDB (AWS) or similar services
- Encrypt state at rest and in transit
- Use state isolation per environment

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "${var.environment}/terraform.tfstate"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 2. Variable Management

- Use `.tfvars` files for environment-specific values
- Don't commit sensitive data to git
- Use Terraform Cloud for secure variable storage

```bash
# Create environment-specific vars
terraform apply -var-file="environments/prod.tfvars"
```

### 3. Code Organization

- Keep modules small and focused
- Use consistent naming conventions
- Document all variables and outputs
- Separate infrastructure by environment

### 4. Security

- Use IAM roles instead of access keys when possible
- Implement least privilege access
- Enable encryption for all storage
- Regular security audits

### 5. CI/CD Integration

```yaml
# GitHub Actions example
name: Terraform Apply

on:
  push:
    branches: [main]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: hashicorp/setup-terraform@v1
      - run: terraform init
      - run: terraform plan
      - run: terraform apply -auto-approve
```

## Troubleshooting

### Issue: "Provider not configured"

```bash
# Solution: Initialize Terraform
terraform init

# Or configure provider
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

### Issue: "Insufficient permissions"

```bash
# Solution: Check IAM permissions
aws iam get-user

# Or for Azure
az role assignment list
```

### Issue: "Resource already exists"

```bash
# Solution: Import existing resource
terraform import aws_vpc.main vpc-12345678
```

### Issue: "State lock timeout"

```bash
# Solution: Release lock if stuck
aws dynamodb delete-item \
  --table-name terraform-locks \
  --key '{"LockID": {"S": "bucket/key"}}'
```

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/cloud-docs/recommended-practices)

## Support and Contribution

For issues, questions, or contributions:

1. Check existing GitHub issues
2. Create a detailed issue report
3. Submit pull requests with improvements
4. Follow the CONTRIBUTING.md guidelines

## License

These templates are provided as-is for educational and production use. See LICENSE file for details.

---

**Last Updated:** January 2026
**Maintainer:** Manjunath S (Cloud Architecture Team)
