# Terraform Multi-Cloud Templates - Quick Start Guide

## Overview

This repository contains production-ready Terraform Infrastructure as Code (IaC) templates for deploying resources across 6 major cloud providers:

- **AWS** (Amazon Web Services)
- **Azure** (Microsoft Azure)
- **GCP** (Google Cloud Platform)
- **IBM Cloud**
- **Alibaba Cloud**
- **OCI** (Oracle Cloud Infrastructure)

## Key Features

✅ **55+ Reusable Modules** covering 140+ resource types  
✅ **Production-Ready** with security best practices  
✅ **Multi-Cloud Support** with consistent patterns  
✅ **Modular Design** - import only what you need  
✅ **Well-Documented** - examples for each module  
✅ **Environment Separation** - dev, staging, prod  
✅ **Version Controlled** - Terraform lock files  
✅ **Cost Optimized** - best practices included  

## Module Coverage

### AWS (15+ modules)
- Compute: EC2, Lambda, EKS
- Database: RDS, DynamoDB, ElastiCache
- Networking: VPC, ALB, ELB
- Storage: S3 with lifecycle policies
- Security: IAM, KMS
- Messaging: SQS, SNS

### Azure (10+ modules)
- Compute: Virtual Machines, AKS
- Database: SQL Server, MySQL
- Storage: Storage Accounts
- Networking: VNet, Security Groups
- App Services: Web Apps, App Service Plans
- Security: Key Vault

### GCP (10+ modules)
- Compute: Compute Engine, GKE
- Database: Cloud SQL
- Storage: Cloud Storage
- Networking: VPC Networks
- Serverless: Cloud Functions
- Analytics: BigQuery

### IBM Cloud (5+ modules)
- Compute: Virtual Servers
- Networking: VPC
- Database: Cloud Databases
- Container: Kubernetes Service

### Alibaba Cloud (5+ modules)
- Compute: ECS
- Database: RDS
- Storage: OSS
- Networking: VPC

### OCI (5+ modules)
- Compute: Compute Instances
- Database: Autonomous Database
- Storage: Object Storage
- Networking: Virtual Cloud Networks

## Getting Started

### Prerequisites

1. **Terraform** >= 1.0
   ```bash
   terraform version  # Check version
   ```

2. **Cloud Provider CLI**
   - AWS: `aws --version`
   - Azure: `az --version`
   - GCP: `gcloud --version`
   - IBM: `ibmcloud --version`
   - Alibaba: `aliyun --version`
   - OCI: `oci --version`

3. **Credentials Configured**
   - AWS: `~/.aws/credentials`
   - Azure: `az login`
   - GCP: `gcloud auth login`
   - IBM: `ibmcloud login`
   - Alibaba: `aliyun configure`
   - OCI: `~/.oci/config`

### Basic Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Manjunathsmurthy/terraform-multi-cloud-templates.git
   cd terraform-multi-cloud-templates
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Validate Configuration**
   ```bash
   terraform validate
   ```

4. **Plan Deployment**
   ```bash
   terraform plan
   ```

5. **Apply Changes**
   ```bash
   terraform apply
   ```

## Using Modules

### Example: AWS EC2 Instance

Create a `main.tf`:

```hcl
module "aws_ec2" {
  source = "./modules/aws/ec2"

  instance_name = "web-server"
  instance_type = "t2.medium"
  ami_id        = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
  
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}

output "instance_id" {
  value = module.aws_ec2.instance_id
}
```

### Example: Azure Virtual Machine

```hcl
module "azure_vm" {
  source = "./modules/azure/compute"

  vm_name       = "windows-server"
  location      = "eastus"
  vm_size       = "Standard_B2s"
  admin_username = "azureuser"
  
  tags = {
    Environment = "staging"
  }
}
```

### Example: GCP Compute Instance

```hcl
module "gcp_compute" {
  source = "./modules/gcp/compute"

  instance_name = "web-server"
  machine_type  = "e2-medium"
  zone          = "us-central1-a"
  
  metadata = {
    startup-script = "echo 'Hello World'"
  }
}
```

## Directory Structure

```
.
├── README.md                      # Main documentation
├── QUICKSTART.md                  # This file
├── MODULES_INVENTORY.md           # Complete module listing
├── .gitignore                     # Git ignore rules
├── modules/                       # Reusable Terraform modules
│   ├── aws/                       # AWS modules
│   │   ├── ec2/
│   │   ├── rds/
│   │   ├── vpc/
│   │   └── ...
│   ├── azure/                     # Azure modules
│   ├── gcp/                       # GCP modules
│   ├── ibm/                       # IBM Cloud modules
│   ├── alibaba/                   # Alibaba Cloud modules
│   ├── oci/                       # OCI modules
│   └── common/                    # Shared modules
├── examples/                      # Example configurations
│   ├── aws/
│   ├── azure/
│   ├── gcp/
│   ├── ibm/
│   ├── alibaba/
│   └── oci/
├── environments/                  # Environment-specific configs
│   ├── dev/
│   ├── staging/
│   └── prod/
├── scripts/                       # Automation scripts
│   ├── init.sh
│   ├── validate.sh
│   ├── plan.sh
│   ├── apply.sh
│   └── destroy.sh
└── docs/                          # Detailed documentation
    ├── SETUP.md
    ├── AWS-GUIDE.md
    ├── AZURE-GUIDE.md
    ├── GCP-GUIDE.md
    ├── IBM-GUIDE.md
    ├── ALIBABA-GUIDE.md
    ├── OCI-GUIDE.md
    ├── BEST-PRACTICES.md
    └── TROUBLESHOOTING.md
```

## Best Practices

### 1. State Management

**Always use remote state in production:**

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 2. Variable Organization

```hcl
# variables.tf - Define all inputs
variable "environment" {
  type        = string
  description = "Environment name"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# terraform.tfvars - Provide values
environment = "production"
```

### 3. Tagging Strategy

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    CreatedAt   = timestamp()
  }
}

resource "aws_instance" "example" {
  tags = merge(
    local.common_tags,
    {
      Name = "my-instance"
    }
  )
}
```

### 4. Security

- **Never commit credentials** - use `terraform.tfvars` (add to .gitignore)
- **Use environment variables** for sensitive data
- **Enable encryption** for state files
- **Apply least privilege** to IAM policies
- **Use secrets management** - AWS Secrets Manager, Azure Key Vault, etc.

### 5. Module Development

Each module should have:

```
modules/aws/ec2/
├── main.tf           # Resource definitions
├── variables.tf      # Input variables
├── outputs.tf        # Exported values
├── versions.tf       # Provider versions
├── README.md         # Module documentation
└── examples/         # Usage examples
```

## Common Commands

```bash
# Initialize Terraform
terraform init

# Format code
terraform fmt -recursive

# Validate configuration
terraform validate

# Check what will be created
terraform plan -out=tfplan

# Apply changes
terraform apply tfplan

# Destroy resources
terraform destroy

# View state
terraform show

# List resources
terraform state list

# Get resource details
terraform state show aws_instance.example
```

## Helper Scripts

Use provided scripts for common operations:

```bash
./scripts/init.sh          # Initialize project
./scripts/validate.sh      # Validate all configurations
./scripts/plan.sh          # Create execution plan
./scripts/apply.sh         # Apply infrastructure
./scripts/destroy.sh       # Destroy infrastructure
./scripts/fmt.sh           # Format all files
./scripts/lint.sh          # Lint Terraform code
```

## Troubleshooting

### Issue: "No valid credential sources found"

**Solution:** Ensure cloud provider credentials are configured:

```bash
# AWS
aws configure

# Azure
az login

# GCP
gcloud auth application-default login
```

### Issue: "State lock failed"

**Solution:** Release locked state:

```bash
terraform force-unlock <LOCK_ID>
```

### Issue: "Module not found"

**Solution:** Ensure module source path is correct:

```hcl
module "example" {
  source = "./modules/aws/ec2"  # Correct relative path
}
```

## Next Steps

1. **Read MODULES_INVENTORY.md** for complete module listing
2. **Check examples/** directory for working configurations
3. **Review docs/** for cloud-provider-specific guides
4. **Follow best practices** in BEST-PRACTICES.md
5. **Set up state management** before production

## Support & Contributions

- Report issues on GitHub Issues
- Contribute improvements via Pull Requests
- See CONTRIBUTING.md for guidelines

## License

MIT License - See LICENSE file for details

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [IBM Provider](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs)
- [Alibaba Provider](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
- [OCI Provider](https://registry.terraform.io/providers/oracle/oci/latest/docs)
