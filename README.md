# AWS EC2 to ECS Migration

A hands-on DevOps project demonstrating the migration of a legacy application running on a single Amazon EC2 instance to a modern, containerised **Amazon ECS Fargate** architecture.

The project focuses on the type of migration commonly encountered in production environments: containerisation, Infrastructure as Code, networking, CI/CD, observability, security and a safe production cutover strategy.

---

## Project Scenario

The starting point is a small Python Flask API hosted on a single EC2 instance behind Nginx.

The existing architecture has several limitations:

* Manual application deployments
* Single EC2 instance
* No autoscaling
* Nginx running directly on the server
* Inconsistent logging
* Limited monitoring
* Infrastructure managed manually
* Single point of failure
* No automated CI/CD pipeline

The objective is to migrate the workload to **Amazon ECS using Fargate** while improving reliability, security and deployment automation.

---

## Migration Overview

```text
Legacy Architecture

Internet
   |
   v
EC2 Instance
   |
   +-- Nginx
   |
   +-- Flask API
   |
   +-- Local application logs
```

will be migrated to:

```text
                    Internet
                       |
                       v
              Application Load Balancer
                       |
                       v
                 ECS Service
                  /       \
                 /         \
          Fargate Task   Fargate Task
                |             |
                +-------------+
                       |
                 Flask API
                       |
                       v
               CloudWatch Logs
```

Container images will be stored in:

```text
GitHub
   |
   v
GitHub Actions
   |
   +--> Tests
   |
   +--> Docker Build
   |
   +--> Security Scan
   |
   +--> Amazon ECR
              |
              v
         ECS Fargate
```

---

# Objectives

The project aims to demonstrate the ability to:

* Analyse an existing EC2 workload
* Containerise a legacy application
* Build Docker images using production practices
* Store container images in Amazon ECR
* Provision infrastructure using Terraform
* Design AWS networking for container workloads
* Deploy applications using ECS Fargate
* Replace Nginx with an Application Load Balancer
* Configure ECS health checks
* Build an automated CI/CD pipeline
* Use GitHub Actions with AWS OIDC authentication
* Implement container security scanning
* Centralise logs using CloudWatch
* Configure monitoring and alerts
* Introduce ECS autoscaling
* Design a low-risk production migration
* Define rollback procedures
* Document operational decisions

---

# Technology Stack

| Area                   | Technology                    |
| ---------------------- | ----------------------------- |
| Cloud                  | AWS                           |
| Compute                | EC2 / ECS Fargate             |
| Containers             | Docker                        |
| Container Registry     | Amazon ECR                    |
| Infrastructure as Code | Terraform                     |
| Load Balancing         | Application Load Balancer     |
| CI/CD                  | GitHub Actions                |
| Authentication         | GitHub OIDC → AWS IAM         |
| Logging                | Amazon CloudWatch Logs        |
| Monitoring             | Amazon CloudWatch             |
| Application            | Python / Flask                |
| Networking             | VPC, Subnets, Security Groups |
| Security Scanning      | Trivy                         |

---

# Project Structure

```text
aws-ec2-to-ecs-migration/
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── tests/
│
├── terraform/
│   ├── modules/
│   │   ├── networking/
│   │   ├── alb/
│   │   ├── ecr/
│   │   └── ecs/
│   │
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── providers.tf
│
├── .github/
│   └── workflows/
│       └── deploy.yml
│
├── Dockerfile
├── .dockerignore
├── README.md
└── migration-plan.md
```

The exact structure may evolve as the migration progresses.

---

# Phase 1 — Understand the Legacy Environment

The first stage is to understand how the application currently operates.

The legacy environment consists of:

```text
Internet
   |
Nginx
   |
Flask Application
   |
EC2
```

Before migrating, the following areas should be identified:

* How the application starts
* Application dependencies
* Environment variables
* Ports
* Nginx configuration
* Health endpoints
* Logging behaviour
* AWS permissions
* Deployment process
* Application state
* External dependencies

This prevents simply moving existing problems into containers.

---

# Phase 2 — Containerise the Application

The Flask application will be packaged into a Docker container.

Example workflow:

```text
Application Code
      |
      v
 Docker Build
      |
      v
 Container Image
      |
      v
 Local Container
```

The container should:

* Install only required dependencies
* Expose the application port
* Run consistently across environments
* Support environment variables
* Produce logs to stdout/stderr
* Include an application health endpoint

Example:

```bash
docker build -t flask-api .
```

Run locally:

```bash
docker run -p 5000:5000 flask-api
```

Test:

```bash
curl http://localhost:5000/health
```

Expected result:

```json
{
  "status": "healthy"
}
```

---

# Phase 3 — Push Images to Amazon ECR

Amazon Elastic Container Registry will store application images.

```text
Developer
    |
    v
Docker Build
    |
    v
Amazon ECR
    |
    v
ECS Fargate
```

Images should use immutable identifiers such as the Git commit SHA rather than relying entirely on `latest`.

Example:

```text
flask-api:a61f39e
```

This improves traceability and rollback capability.

---

# Phase 4 — Infrastructure as Code

AWS infrastructure will be provisioned using Terraform.

Terraform will manage resources such as:

* VPC
* Public subnets
* Private subnets
* Route tables
* Internet Gateway
* Security Groups
* Application Load Balancer
* Target Groups
* ECS Cluster
* ECS Task Definition
* ECS Service
* ECR Repository
* IAM Roles
* CloudWatch Log Groups
* Autoscaling configuration

The intention is for the environment to be reproducible rather than configured manually through the AWS Console.

Typical workflow:

```bash
terraform fmt

terraform validate

terraform plan

terraform apply
```

---

# Phase 5 — Networking

The target networking architecture separates publicly accessible infrastructure from application workloads.

```text
VPC
│
├── Public Subnet A
│       └── ALB
│
├── Public Subnet B
│       └── ALB
│
├── Private Subnet A
│       └── ECS Task
│
└── Private Subnet B
        └── ECS Task
```

The Application Load Balancer accepts internet traffic.

ECS tasks should only accept application traffic from the ALB.

Example security model:

```text
Internet
   |
   | HTTPS / HTTP
   v
ALB Security Group
   |
   | Application Port
   v
ECS Security Group
```

The ECS tasks should not be directly exposed to the internet.

---

# Phase 6 — Deploy to ECS Fargate

The application will run as an ECS service using AWS Fargate.

Fargate removes the requirement to provision or maintain EC2 worker nodes.

The ECS configuration will include:

* ECS Cluster
* Task Definition
* Fargate launch type
* CPU allocation
* Memory allocation
* Container port
* Environment variables
* IAM execution role
* IAM task role
* CloudWatch logging
* Desired task count
* ALB target group
* Health checks

Example:

```text
ECS Cluster
     |
ECS Service
     |
     +--------+
     |        |
   Task 1   Task 2
```

Running multiple tasks removes the single point of failure that existed with the original EC2 instance.

---

# Phase 7 — Replace Nginx with an ALB

The legacy EC2 environment used Nginx as the public entry point.

In the new architecture, the Application Load Balancer handles traffic distribution.

```text
Before

Internet
   |
Nginx
   |
Flask
```

```text
After

Internet
   |
ALB
   |
ECS Service
   |
Flask Containers
```

The ALB provides:

* Load balancing
* Health checks
* Integration with ECS
* Multi-AZ availability
* HTTPS termination
* Routing capabilities

---

# Phase 8 — CI/CD Pipeline

Deployments will be automated using GitHub Actions.

Pipeline:

```text
Developer Push
      |
      v
GitHub Actions
      |
      v
Run Tests
      |
      v
Security Scan
      |
      v
Docker Build
      |
      v
Trivy Scan
      |
      v
Push Image to ECR
      |
      v
Register ECS Task Definition
      |
      v
Update ECS Service
      |
      v
ECS Rolling Deployment
      |
      v
Health Check
```

The pipeline removes the need to SSH into servers or manually deploy application files.

---

# AWS Authentication

GitHub Actions will authenticate to AWS using **OpenID Connect (OIDC)**.

```text
GitHub Actions
      |
      | OIDC Token
      v
AWS IAM Role
      |
Temporary AWS Credentials
      |
      v
AWS Resources
```

This avoids storing permanent AWS access keys inside GitHub Secrets.

The IAM role should follow the principle of least privilege.

---

# Security

Security controls implemented throughout the project include:

* GitHub Actions OIDC authentication
* No permanent AWS credentials in CI/CD
* Least-privilege IAM roles
* Private ECS tasks
* Security Group restrictions
* Container image scanning
* Immutable image tags
* Infrastructure as Code
* Controlled network access
* Automated deployments

Container images will be scanned using **Trivy** before deployment.

Example:

```bash
trivy image flask-api:latest
```

High or critical vulnerabilities can be configured to fail the CI pipeline.

---

# Observability

Application logs will be written to stdout/stderr and collected by CloudWatch.

```text
Flask Container
      |
 stdout / stderr
      |
      v
CloudWatch Logs
```

Monitoring will cover areas such as:

* ECS CPU utilisation
* ECS memory utilisation
* Running task count
* ALB request count
* ALB response codes
* Target response time
* Unhealthy targets

CloudWatch alarms can be created for conditions such as:

```text
ALB 5xx responses > threshold

CPU utilisation > threshold

Unhealthy ECS targets > 0
```

---

# Autoscaling

ECS Service Auto Scaling can dynamically adjust the number of running tasks.

Example:

```text
Normal Traffic

Task 1
Task 2
```

During increased demand:

```text
Task 1
Task 2
Task 3
Task 4
```

Scaling policies can use metrics such as:

* CPU utilisation
* Memory utilisation
* ALB request count

---

# Production Migration Strategy

The migration should avoid a risky "big bang" replacement of the EC2 environment.

Instead, both environments can temporarily run in parallel.

```text
               ┌── Legacy EC2
User Traffic ──┤
               └── ECS Fargate
```

The migration process will be:

1. Deploy the ECS environment.
2. Validate ECS independently.
3. Perform smoke tests.
4. Test ALB health checks.
5. Test logging and monitoring.
6. Run the EC2 and ECS environments simultaneously.
7. Gradually redirect production traffic to ECS.
8. Monitor errors, latency and application health.
9. Keep the EC2 environment available for rollback.
10. Fully migrate traffic once ECS has been validated.
11. Decommission EC2 only after an agreed stability period.

---

# Rollback Strategy

A production migration must include a rollback plan.

If serious issues appear after cutover:

```text
ECS
 |
 | Problem detected
 v
Redirect traffic
 |
 v
EC2
```

Because the original EC2 environment remains available during the migration window, traffic can be redirected back while the ECS issue is investigated.

Container image versioning also allows previous ECS releases to be redeployed.

For example:

```text
Current

flask-api:bad-release

Rollback

flask-api:previous-sha
```

---

# Migration Success Criteria

The migration will be considered successful when:

* The Flask application runs successfully in ECS Fargate
* The application is accessible through the ALB
* ECS tasks are deployed across multiple availability zones
* Container images are stored in ECR
* Infrastructure is managed through Terraform
* Deployments are automated using GitHub Actions
* AWS authentication uses OIDC
* Containers pass vulnerability scanning
* Logs are available in CloudWatch
* Monitoring and health checks operate correctly
* ECS can replace unhealthy tasks
* Autoscaling has been configured and tested
* A rollback procedure has been documented and tested
* The legacy EC2 instance can be safely decommissioned

---

# Key DevOps Concepts Demonstrated

This project demonstrates practical experience with:

**AWS**

* EC2
* ECS
* Fargate
* ECR
* IAM
* VPC
* ALB
* CloudWatch

**Infrastructure**

* Terraform
* Infrastructure as Code
* Networking
* Security Groups
* Multi-AZ architecture

**Containers**

* Docker
* Container registries
* Image versioning
* Vulnerability scanning

**CI/CD**

* GitHub Actions
* OIDC
* Automated testing
* Automated container builds
* Automated deployments
* Rolling deployments

**Platform / SRE**

* Observability
* Health checks
* Autoscaling
* High availability
* Rollbacks
* Production cutover planning

---

# Migration Journey

```text
EC2
 |
 v
Understand Existing Application
 |
 v
Dockerise
 |
 v
ECR
 |
 v
Terraform Infrastructure
 |
 v
ALB + ECS Fargate
 |
 v
CI/CD
 |
 v
CloudWatch
 |
 v
Autoscaling
 |
 v
Production Validation
 |
 v
Controlled Traffic
```
