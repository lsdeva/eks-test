#!/bin/bash

# Set environment variables
export REGION="ap-southeast-1"
export VPC_ID="vpc-xxxxx"
export IGW_ID="igw-xxxxx"

# Subnet IDs
export PUBLIC_SUBNET_1="subnet-yyyyy1"
export PUBLIC_SUBNET_2="subnet-yyyyy2"
export PRIVATE_SUBNET_1="subnet-zzzzz1"
export PRIVATE_SUBNET_2="subnet-zzzzz2"

# Step 1: Allocate Elastic IPs for NAT Gateways
export EIP_ALLOC_1=$(aws ec2 allocate-address --region $REGION --query 'AllocationId' --output text)
export EIP_ALLOC_2=$(aws ec2 allocate-address --region $REGION --query 'AllocationId' --output text)

# Step 2: Create NAT Gateways in public subnets
export NAT_GW_1=$(aws ec2 create-nat-gateway \
    --subnet-id $PUBLIC_SUBNET_1 \
    --allocation-id $EIP_ALLOC_1 \
    --region $REGION \
    --query 'NatGateway.NatGatewayId' \
    --output text)

export NAT_GW_2=$(aws ec2 create-nat-gateway \
    --subnet-id $PUBLIC_SUBNET_2 \
    --allocation-id $EIP_ALLOC_2 \
    --region $REGION \
    --query 'NatGateway.NatGatewayId' \
    --output text)

# Wait for NAT Gateways to become available
echo "Waiting for NAT Gateways to become available..."
aws ec2 wait nat-gateway-available --nat-gateway-ids $NAT_GW_1 $NAT_GW_2 --region $REGION
echo "NAT Gateways are available."

# Step 3: Find Route Tables for private subnets
export RTB_PRIVATE_1=$(aws ec2 describe-route-tables \
    --filters "Name=association.subnet-id,Values=$PRIVATE_SUBNET_1" \
    --region $REGION \
    --query 'RouteTables[0].RouteTableId' \
    --output text)

export RTB_PRIVATE_2=$(aws ec2 describe-route-tables \
    --filters "Name=association.subnet-id,Values=$PRIVATE_SUBNET_2" \
    --region $REGION \
    --query 'RouteTables[0].RouteTableId' \
    --output text)

# Step 4: Create routes for private subnets to use NAT Gateways
aws ec2 create-route \
    --route-table-id $RTB_PRIVATE_1 \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id $NAT_GW_1 \
    --region $REGION

aws ec2 create-route \
    --route-table-id $RTB_PRIVATE_2 \
    --destination-cidr-block 0.0.0.0/0 \
    --nat-gateway-id $NAT_GW_2 \
    --region $REGION

# Output results
echo "NAT Gateway 1: $NAT_GW_1 (EIP: $EIP_ALLOC_1)"
echo "NAT Gateway 2: $NAT_GW_2 (EIP: $EIP_ALLOC_2)"
echo "Private Subnet 1 Route Table: $RTB_PRIVATE_1"
echo "Private Subnet 2 Route Table: $RTB_PRIVATE_2"
echo "Routes have been configured for private subnets."
