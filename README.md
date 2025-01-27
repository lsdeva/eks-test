
# EKS Test Setup

This repository contains configuration files and instructions for setting up an Amazon EKS cluster.

### 1. `create cluster`
- **Description**: Resources and configurations for creating an EKS cluster.

1. [cluster-config.yaml](create%20cluster/cluster-config.yaml)
   - **Description**: Contains the configuration details required for creating an EKS cluster.

2. [eks-private-cluster-setup.md](create%20cluster/eks-private-cluster-setup.md)
   - **Description**: Step-by-step instructions for deploying a private EKS cluster with internet access, including VPC endpoints and workload setup.

### 2. `observability/logging`
- **Description**: Resources and instructions for setting up logging in an EKS Fargate environment.

  - [aws-logging-cloudwatch-configmap.yaml](observability/logging/aws-logging-cloudwatch-configmap.yaml): Defines the ConfigMap for Fluent Bit to ship logs to CloudWatch.
  - [aws-observability-namespace.yaml](observability/logging/aws-observability-namespace.yaml): Creates the `aws-observability` namespace required for Fluent Bit logging.
  - [fargate-logging-setup.md](observability/logging/fargate-logging-setup.md): Step-by-step instructions to configure logging for EKS Fargate pods using Fluent Bit and CloudWatch.
