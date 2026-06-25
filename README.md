# k8s-microservice-cms


Production-style AWS EKS platform for a microservice-based Parish Management System.

This repository demonstrates a modern DevOps/cloud platform using:

- Terraform Infrastructure as Code
- AWS S3 remote state
- DynamoDB state locking
- GitHub Actions OIDC authentication to AWS
- Amazon ECR container registry
- Amazon VPC networking
- Amazon EKS Kubernetes cluster
- Amazon RDS PostgreSQL
- Amazon S3 document storage
- Route 53, ACM, WAF, and ALB
- Argo CD GitOps deployment
- Helm application packaging
- Prometheus and Grafana monitoring
- Fluent Bit and OpenSearch logging
- Velero backup and restore

## Application Services

The application is composed of:

- frontend
- auth-service
- church-core-service
- document-core-service

## Databases

One RDS PostgreSQL instance will host three separate databases:

- auth_db
- church_core_db
- document_db

## Purpose

This platform is designed as a production-grade DevOps portfolio project. The environment can be provisioned, demonstrated, documented, and destroyed to control cost.
