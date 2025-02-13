

# Terraform & Ansible Prometheus Deployment

Welcome to the **Terraform & Ansible Prometheus Deployment** repository! 🚀 This repository is dedicated to practicing **Terraform** for infrastructure automation, primarily using **AWS**. Over time, the configurations will be improved and optimized for better performance and scalability.

## **Setup Guide**

### **1. Configure AWS Credentials**
Before deploying infrastructure, ensure that your AWS credentials are correctly configured:
```bash
aws configure
```
This will prompt you to enter your AWS **Access Key ID**, **Secret Access Key**, **Region**, and **Output Format**.

### **2. Initialize Terraform**
Run the following command to initialize the Terraform project:
```bash
terraform init
```
This will download the necessary provider plugins and set up your Terraform environment.

### **3. Apply Terraform Configuration**
To create the infrastructure on AWS, execute:
```bash
terraform apply
```
Review the plan and confirm by typing **yes** when prompted. This step provisions your EC2 instances and networking components.

### **4. Verify Inventory File**
After Terraform completes, check the generated `inventory.json` file to ensure that the correct instance details are stored:
```bash
cat inventory.json
```
This file contains the **Ansible inventory** with dynamic instance details such as IP addresses and SSH configurations.

### **5. Deploy Prometheus, grafana and node exporter using Ansible**
Run the Ansible playbook to configure **Prometheus** on the newly created instance:
```bash
ansible-playbook prometheus.yml -i inventory.json -vvv
```
The `-vvv` flag enables **verbose output** for debugging and detailed logs.

---

## **How It Works** 🛠️
- **Terraform** provisions the required AWS infrastructure, including EC2 instances.
- **Ansible** automates the deployment of **Prometheus** using the dynamic inventory.
- The playbook fetches the instance IP dynamically from `inventory.json`, ensuring **flexibility** in deployments.
- This project will be **continuously improved** with better Terraform modules, Ansible roles, and optimized configurations.

### **Future Enhancements** ✨
- Implement **Terraform modules** for modular infrastructure.
- Use **Ansible roles** for better configuration management.
- Integrate **Prometheus exporters** for system monitoring.
- Automate **TLS/SSL** setup for secure communication.

---

Stay tuned for updates and feel free to contribute! 🚀

### **Author:**
Emmanuel Steven Catin
MireCloud Technologies ☁️


