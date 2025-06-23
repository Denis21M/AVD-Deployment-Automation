# 🚀 Azure Virtual Desktop (AVD) Full Environment Deployment

This repository contains all infrastructure-as-code (IaC) and automation logic needed to deploy a full Azure Virtual Desktop (AVD) environment using Bicep templates and a GitHub Actions CI/CD pipeline.

---

## 📦 What's Included?

This solution provisions the following Azure resources:

- **Virtual Network (VNet)** and subnet
- **Azure Active Directory Domain Services (AD DS)** domain (`corp.local`)
- **DNS Update** with Domain Controller IPs
- **User-Assigned Managed Identity** with RBAC for Image Builder
- **Azure Image Builder Template** (AVD image creation)
- **AVD Host Pool** with registration token
- **AVD Session Hosts** (joined to domain)
- **Application Group** (Desktop Application Group)
- **AVD Workspace** (linked to the app group)

---

## Manually via CLI or Azure portal provision the following;
- Resources group to contain all resources
- Service Principle creation to give Github access/log in to Azure resource container
- Log in azure portal copy IP of AD DS after deployment and update the Vnet DNS

## ⚙️ GitHub Actions Workflow: `deploy-avd.yml`

### 🔁 Trigger
- Runs automatically on every push to the `main` branch.

### 🔐 Authentication
- Uses [Service Principle](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-cli%2Clinux) to log in to Azure securely without secrets.

### 🧱 Pipeline Flow

| Step | Description |
|------|-------------|
| ✅ Checkout Code | Gets Bicep files from the repository |
| 🔐 Azure Login | Authenticates via Service Principle |
| 🌐 Deploy AD DS & VNet | Deploys network and AD Domain Services |
| 🧠 Update DNS | Manually Extracts DC IPs and updates VNet DNS servers In Azure Portal |
| 👤 Deploy Identity + RBAC | Creates user-assigned identity with roles |
| 🖼️ Deploy Image Builder | Deploys image template (for session hosts) |
| 🧩 Deploy Host Pool | Creates AVD host pool and gets registration token |
| 🧠 Deploy App Group | Creates desktop application group |
| 🖥️ Deploy Workspace | Links app group to an AVD workspace |
| 🖥️ Deploy Session Hosts | Provisions session VMs, domain-joins, registers with host pool |

---

## 📁 Folder Structure

```bash
.
├── .github/workflows/
│   └── deploy-avd.yml         # GitHub Actions workflow
├── bicep/
│   ├── aad-ds.bicep           # AD DS and VNet
│   ├── id-rbac.bicep          # Managed identity + RBAC
│   ├── image-temp.bicep       # Azure Image Builder template
│   ├── hostpool.bicep         # Host Pool + registration
│   ├── sessionhosts.bicep     # VM session hosts
│   ├── applicationgroup.bicep # Desktop Application Group
│   ├── workspace.bicep        # AVD Workspace
├── ad_ds_ips.json             # Output file for domain IPs
└── README.md


## 🔑 Required GitHub Secrets
--Secret Name	Description
- AZURE_CREDENTIALS	AZURE CREDENTIALS as a json format
- AZURE_TENANT_ID	Azure tenant ID
- AZURE_SUBSCRIPTION_ID	Azure subscription ID
- VM_ADMIN_USERNAME	Username for AVD VMs
- VM_ADMIN_PASSWORD	Password for AVD VMs
- DOMAIN_JOIN_USERNAME	Domain-join user (AD DS)
- DOMAIN_JOIN_PASSWORD	Password for domain-join user

## 📝 Notes
- Ensure az bicep install is run locally if testing manually.
- The avd-image-identity must already be created or its name referenced correctly in id-rbac.bicep.

## 📘 References
- Azure Virtual Desktop Docs

- Bicep Documentation

- GitHub Actions for Azure
