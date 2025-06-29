# 🚀 Azure Virtual Desktop (AVD) Full Environment Deployment

This repository contains all infrastructure-as-code (IaC) and automation logic needed to deploy a full Azure Virtual Desktop (AVD) environment using Bicep templates and a GitHub Actions CI/CD pipeline.

---

## 📦 What's Included?

This solution provisions the following Azure resources:

- **Virtual Network (VNet)** and subnet
- **Azure Active Directory Domain Services (AD DS)** domain (`xxx`), ensure it is azure verified
- **DNS Update** with Domain Controller IPs
- **User-Assigned Managed Identity** with RBAC for Image Builder
- **Azure Image Builder Template** (AVD image creation)
- **AVD Host Pool** with registration token
- **AVD Session Hosts** (joined to domain)
- **Application Group** (Desktop Application Group)
- **AVD Workspace** (linked to the app group)

---

## Manually via CLI using bash/powershell or Azure portal provision the following;
- Resources group to contain all resources
- Service Principle creation to give Github access/log in to Azure resource container
- Create SIG (Shared image gallery)
- Create Shared Image Name
- Deploy AD DS, NSG (open necessary ports) & VNet+Subnet, file path = manual-bicep/aad-ds.bicep
- Log into azure portal copy IP of AD DS after deployment and update the Vnet DNS
- Disable the PLSNP (privatelinkserviceNetworkPolicy) and PENP (PrivateEndpointNetworkPolicy) of the subnet because it blocks the image builder, private link service and private endpoints. 
- Deploy Identity + RBAC, Creates user-assigned identity with roles, file path = manual-bicep/id-rbac.bicep
- Deploys image template file path = manual-bicep/image-temp.bicep (for sessions hosts)


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
│   ├── hostpool.bicep         # Host Pool
│   ├── sessionhosts.bicep     # VM session hosts from the deployed image + registration to hostpool
│   ├── applicationgroup.bicep # Desktop Application Group
│   ├── workspace.bicep        # AVD Workspace
├── ad_ds_ips.json             # Output file for domain IPs
└── README.md


## 🔑 Required GitHub Secrets
--Secret Name	Description
- AZURE_CREDENTIALS	AZURE CREDENTIALS as a json format
- AZURE_SUBSCRIPTION_ID	Azure subscription ID
- VM_ADMIN_USERNAME	Username for AVD VMs
- VM_ADMIN_PASSWORD	Password for AVD VMs
- DOMAIN_JOIN_USERNAME	Domain-join user (AD DS)
- DOMAIN_JOIN_PASSWORD	Password for domain-join user
- SUBNET_ID optional
- IMAGE_ID
- IDENTITY_ID

## 📝 Notes
- Ensure az bicep install is run locally if testing manually.
- The avd-image-identity must already be created or its name referenced correctly in id-rbac.bicep.
- Ensure to customize apps that install silently during vm creation

## 📘 References
- Azure Virtual Desktop Docs

- Bicep Documentation

- GitHub Actions for Azure
