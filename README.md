# Infrastructure as Code (IaC) Library

A centralized repository for infrastructure automation, provisioning modules, and operational tooling. This collection embodies **SRE principles**, focusing on modularity, security, and idempotency across hybrid cloud environments.

## 📂 Repository Structure

This repository is organized by platform. Each directory contains specific infrastructure definitions and supporting automation utilities.

| Platform | Status | Description |
| :--- | :--- | :--- |
| **[AWS](./aws)** | 🟢 Active | Terraform bootstrapping, state management, and Python-based operational tools. |
| **GCP** | 🚧 Planned | Upcoming modules for Google Cloud Platform networking and compute. |
| **Proxmox** | 🚧 Planned | Virtualization automation for private cloud / homelab environments. |

## 🚀 Key Modules

### [AWS / Backend Bootstrap](./aws/backend-bootstrap)
A definitive guide and Terraform configuration for bootstrapping a secure, state-locked AWS environment.
* **Features:** S3 State Bucket (Versioning/Encryption), DynamoDB Locking, automated policy enforcement.

### [AWS / Utilities](./aws/utilities)
Python and Shell automation for day-to-day SRE operations.
* **Highlights:** Secure AWS STS credential rotation, MFA session management, and "surgical" config updates.

## 🛠️ Tech Stack & Tools
* **Provisioning:** Terraform
* **Automation:** Python (Boto3)
* **Cloud:** AWS (Current), GCP/Private Cloud (Roadmap)

---
*Maintained by [codalytic](https://github.com/codalytic)*