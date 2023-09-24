Documentation of Deploying Multi-Region AWS Architecture 
Table of Contents
1. Introduction
2. Architecture Overview
3. Prerequisites
4. Step 1: VPC Creation
5. Step 2: Subnet Configuration
6. Step 3: Internet Gateway
7. Step 4: NAT Gateway
8. Step 5: Elastic Load Balancer
9. Step 6: AWS WAF Configuration
10. Step 7: AWS RDS Configuration
11. Step 8: AWS EKS Cluster
12. Step 9: Auto Scaling Group (ASG)
13. Step 10: Routing Based on User Location
14. Request & Response Flow
15. Security Recommendations
16. Terraform Scripts
17. Conclusion


1. Introduction
This documentation outlines the steps to set up a multi-region AWS architecture to host web services 
with redundancy and global user access. We will use Terraform to create the necessary resources 
The architecture includes components such as Amazon VPC, subnets, Internet Gateway, NAT 
Gateways, AWS WAF, Elastic Load Balancer, AWS RDS and AWS EKS


2. Architecture Overview
High-Level View
The architecture consists of:
Two AWS Regions: Mumbai and Singapore.
Two Availability Zones within each region.
VPCs, subnets, IGW and NAT Gateways for each Availability Zone.
AWS WAF for security.
AWS RDS for database storage.
Elastic Load Balancer(ELB) for load distribution.
AWS EKS clusters for container orchestration.
Key Components
VPCs: Isolate network resources within each region.
Subnets: Define public and private subnets within Availability Zones.
NAT Gateways: Provide internet access for private subnets.
AWS WAF: Protect web applications from malicious traffic.
AWS RDS: Host the application's database.
Elastic Load Balancer: Distribute incoming traffic to EKS clusters.
AWS EKS: Manage and scale containerized applications.

3. Prerequisites
  ❖ AWS account with necessary permissions.
  ❖ AWS CLI or AWS Management Console access.
  ❖ Terraform installed on your local machine.

4. Step 1: VPC Creation
**Objective:** Create Virtual Private Clouds (VPCs) in the Mumbai and Singapore regions.
  ❖ Use AWS VPC service.
  ❖ Assign appropriate CIDR blocks.
  ❖ Enable DNS support and hostnames.

5. Step 2: Subnet Configuration
**Objective:** Create public and private subnets in each region.
  ❖ Use the AWS Subnet service.
  ❖ Distribute subnets across Availability Zones.
  ❖ Configure public subnets for external access.

6. Step 3: Internet Gateway
**Objective:** Set up Internet Gateways(IGW) for both VPCs.
  ❖ Create Internet Gateways using AWS Internet Gateway service.
  ❖ Attach them to VPCs.

7. Step 4: NAT Gateway
**Objective:** Configure NAT Gateways in public subnets.
  ❖ Create NAT Gateways using AWS NAT Gateway service.
  ❖ Associate Elastic IPs.
  ❖ Ensure private subnet instances can access the internet.

8. Step 5: Elastic Load Balancer
**Objective:** Set up Elastic Load Balancers (ALBs) for load distribution.
  ❖ Create Application Load Balancers using AWS ALB service.
  ❖ Configure listeners and target groups.
  ❖ Distribute incoming traffic to backend services.

9. Step 6: AWS WAF Configuration
**Objective:** Set up AWS Web Application Firewall (WAF) for security.
  ❖ Create Web ACLs and rules to protect against web application attacks.
  ❖ Configure WAF resources as needed.
  ❖ Associate WAF to ALB

10. Step 7: AWS RDS Configuration
**Objective:** Create AWS Relational Database Service (RDS) instances for database needs.
  ❖ Use AWS RDS service.
  ❖ Select appropriate database engine.
  ❖ Configure security groups, encryption, and backups.

11. Step 8: AWS EKS Cluster
**Objective:** Create AWS Elastic Kubernetes Service (EKS) clusters for container orchestration.
  ❖ Use AWS EKS service.
  ❖ Configure clusters, worker nodes, and networking.
  ❖ Ensure scalability and fault tolerance using Auto Scaling Groups (ASGs).

12. Step 9: Auto Scaling Group (ASG)
**Objective:** Configure Auto Scaling Groups for EKS worker nodes.
  ❖ Define ASGs with desired capacity, instance types, and scaling policies.

13. Step 10: Routing Based on User Location
**Objective:** Route user requests to the appropriate region.
  ❖ Utilize Amazon Route 53 for global traffic routing.

14. Request & Response Flow
Request Flow 
User requests originate from the internet.
Requests are routed to the AWS Internet Gateway.
AWS WAF inspects and filters incoming traffic.
Traffic is forwarded to the Elastic Load Balancer.
Elastic Load Balancer distributes requests to EKS cluster worker nodes in private subnets.

Response Flow
Application responses travel from the private subnets to NAT Gateways.
NAT Gateways send responses to the Internet Gateway.
Internet Gateway routes responses to the internet.
EKS clusters maintain connectivity to the RDS database for data retrieval and updates.

15. Security Recommendations
**Objective:** Implement security best practices.
Network Security
  ❖ Utilize Security Groups and Network ACLs to control inbound and outbound traffic.
  ❖ Enable VPC Flow Logs for network traffic monitoring.

Identity and Access Management (IAM)
  ❖ Implement IAM roles and policies with least privilege access.
  ❖ Use IAM for authentication to AWS resources.
  
Data Encryption
  ❖ Enable encryption at rest and in transit for sensitive data.
  ❖ Use AWS Key Management Service (KMS) for managing encryption keys.
  
Patch Management
  ❖ Regularly update and patch operating systems and software.
  ❖ Implement automated patch management solutions.

Monitoring and Logging
  ❖ Configure CloudWatch for monitoring and logging of AWS resources.
  ❖ Set up alarms and notifications for critical events.
  
Multi-Factor Authentication (MFA)
  ❖ Enforce MFA for AWS IAM users.
  
Disaster Recovery and Backup Strategies
  ❖ Implement backup and disaster recovery plans for critical data and services.
  ❖ Test disaster recovery procedures regularly
  
17. Terraform Scripts
Introduction
The Terraform scripts automate the provisioning of resources, including VPC, subnets, 
security groups, IAM roles, and AWS services such as EKS, RDS, and AWS WAF.
Create Terraform Configuration Files
main.tf - Main configuration file.
variables.tf - Define input variables.
outputs.tf - Define outputs.

Configure AWS Provider

Instructions for Using the Terraform Scripts 
To use these Terraform scripts, follow these general steps: 
Install Terraform: Ensure Terraform is installed on your local machine. 
Configure AWS Credentials: Set up AWS access and secret keys or IAM roles with necessary 
permissions. 
Customize Variables: Modify the input variables in the .tf files according to your requirements. 
Initialize Terraform: Run terraform init in the directory containing the Terraform scripts. 
Plan and Apply: Use terraform plan to preview changes and terraform apply to create or update 
resources. 
Note: Replace with the desired region to replicate same infrastructure

18. Conclusion
In conclusion, this document has provided a comprehensive overview of the architecture, including 
its components, deployment steps, request and response flows, and security recommendations. The 
included Terraform script allows for the automated provisioning of this architecture in an AWS 
environment. Following best practices for security and high availability is essential to ensure the 
reliability and resilience of this infrastructure.
