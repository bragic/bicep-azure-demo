# bicep-azure-demo

A hands-on Azure infrastructure project using Bicep IaC and GitHub Actions CI/CD. Built to practice modular Bicep patterns, multi-environment deployments, and pipeline automation against a real Azure subscription.

## What It Does

Deploys a storage account to Azure across two environments (dev and prod) using a reusable Bicep module, environment-specific parameter files, and a GitHub Actions pipeline with an approval gate protecting prod.

## Stack

- **IaC:** Azure Bicep
- **Pipeline:** GitHub Actions
- **Cloud:** Microsoft Azure
- **Auth:** Azure Service Principal (scoped to target resource groups)

## Project Structure

```
bicep-azure-demo/
├── .github/
│   └── workflows/
│       └── deploy.yml        # GitHub Actions pipeline
├── modules/
│   └── storage/
│       └── storage.bicep     # Reusable storage account module
├── parameters/
│   ├── dev.parameters.json   # Dev environment values
│   └── prod.parameters.json  # Prod environment values
└── main.bicep                # Root template - calls modules, handles naming and env logic
```

## Pipeline Flow

```
Push to main
    │
    ▼
Validate ──── az bicep build (syntax check)
         ──── what-if against dev (no changes made)
    │
    ▼
Deploy Dev ── deploys automatically on validate success
    │
    ▼
Deploy Prod ── what-if runs first
            ── manual approval gate (GitHub environment protection)
            ── deploys on approval
```

## Key Concepts Practiced

**Modular Bicep structure** — storage account extracted into a reusable module with its own parameters and outputs. Root template handles naming conventions and environment logic, keeping the module generic and reusable.

**Environment-based configuration** — single Bicep template deploys differently per environment via parameter files. Dev uses `Standard_LRS` storage, prod uses `Standard_GRS` for geo-redundancy.

**Least-privilege auth** — GitHub Actions authenticates via a service principal scoped only to the two target resource groups, not the full subscription.

**What-if before deploy** — pipeline runs `--what-if` before every deployment to surface changes without applying them, mirroring the `terraform plan` workflow.

**Approval gate on prod** — GitHub environment protection requires manual review before prod deployment proceeds.

## Running Locally

Prerequisites: Azure CLI, Bicep CLI (`az bicep install`), an Azure subscription.

```bash
# Validate syntax
az bicep build --file main.bicep

# What-if (preview changes without deploying)
az deployment group what-if \
  --resource-group rg-bicepdemo-dev \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json

# Deploy
az deployment group create \
  --resource-group rg-bicepdemo-dev \
  --template-file main.bicep \
  --parameters @parameters/dev.parameters.json
```

## What I Learned

- Bicep module patterns and how parent templates pass values to child modules
- How parameter files override template defaults (and when to use defaults vs explicit values)
- GitHub Actions environment protection rules and approval gates
- The relationship between Bicep, ARM templates, and the Azure deployment model
- Structuring IaC repos for multi-environment deployments
