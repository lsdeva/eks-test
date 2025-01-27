Here is the rewritten version with masking for the VPC, subnets, and other specific resource identifiers:

---

### **VPC Details**
- **VPC ID**: `vpc-xxxxx`
#### **Public Subnets**
- `subnet-yyyyy1`
- `subnet-yyyyy2`
#### **Private Subnets**
- `subnet-zzzzz1`
- `subnet-zzzzz2`

---

### **Deploy Private Clusters with Limited Internet Access**

1. **Enable private access for your cluster endpoint.**

2. **Create VPC Endpoints**
```bash
aws ec2 create-vpc-endpoint --vpc-id vpc-xxxxx --service-name com.amazonaws.ap-southeast-1.elasticloadbalancing --vpc-endpoint-type Interface --subnet-ids subnet-zzzzz1 subnet-zzzzz2

aws ec2 create-vpc-endpoint --vpc-id vpc-xxxxx --service-name com.amazonaws.ap-southeast-1.ecr.api --vpc-endpoint-type Interface --subnet-ids subnet-zzzzz1 subnet-zzzzz2

aws ec2 create-vpc-endpoint --vpc-id vpc-xxxxx --service-name com.amazonaws.ap-southeast-1.ecr.dkr --vpc-endpoint-type Interface --subnet-ids subnet-zzzzz1 subnet-zzzzz2

aws ec2 create-vpc-endpoint --vpc-id vpc-xxxxx --service-name com.amazonaws.ap-southeast-1.s3 --vpc-endpoint-type Gateway

aws ec2 create-vpc-endpoint --vpc-id vpc-xxxxx --service-name com.amazonaws.ap-southeast-1.xray --vpc-endpoint-type Interface --subnet-ids subnet-zzzzz1 subnet-zzzzz2

aws ec2 create-vpc-endpoint --vpc-id vpc-xxxxx --service-name com.amazonaws.ap-southeast-1.logs --vpc-endpoint-type Interface --subnet-ids subnet-zzzzz1 subnet-zzzzz2

aws ec2 create-vpc-endpoint --vpc-id vpc-xxxxx --service-name com.amazonaws.ap-southeast-1.sts --vpc-endpoint-type Interface --subnet-ids subnet-zzzzz1 subnet-zzzzz2
```

---

### **Tag Subnets**

#### Tagging Private Subnets for ALB:
```bash
aws ec2 create-tags --resources subnet-zzzzz1 subnet-zzzzz2 --tags Key=kubernetes.io/role/internal-elb,Value=1
```

#### Tagging Public Subnets for ALB:
```bash
aws ec2 create-tags --resources subnet-yyyyy1 subnet-yyyyy2 --tags Key=kubernetes.io/role/elb,Value=1
```

---

### **Updated Commands in AWS CloudShell**

#### Create NAT Gateways:
[Use a separate  script to create NAT gateways.] (https://github.com/lsdeva/eks-test/blob/main/create%20cluster/create-nat-gateway.sh)

#### Create the Cluster:
```bash
eksctl create cluster -f cluster-config.yaml
```

#### Create IAM Service Account for AWS Load Balancer Controller:
```bash
eksctl create iamserviceaccount \
  --cluster=my-eks-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::xxxxxxxxxxxx:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve
```

#### Install AWS Load Balancer Controller:
```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --set clusterName=my-eks-cluster \
  --set serviceAccount.create=false \
  --set region=ap-southeast-1 \
  --set vpcId=vpc-xxxxx \
  --set serviceAccount.name=aws-load-balancer-controller \
  -n kube-system
```

---

### **Workload Setup**

#### Create a Fargate Profile for 2048 Sample App:
```bash
eksctl create fargateprofile \
  --cluster my-eks-cluster \
  --region ap-southeast-1 \
  --name alb-sample-app \
  --namespace game-2048
```

#### Deploy the Sample Application:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.6.1/docs/examples/2048/2048_full.yaml
```

---

### **Cleanup**

#### Delete Cluster:
```bash
eksctl delete cluster -f cluster-config.yaml
```

#### Note:
NAT Gateway deletion may leave Elastic IPs behind. Manually delete Elastic IPs if necessary.

---

### **Guest Book Application**

#### Create Fargate Profile:
```bash
eksctl create fargateprofile \
  --cluster my-eks-cluster \
  --name guestbook-profile \
  --namespace guestbook \
  --region ap-southeast-1
```

#### Deploy Guestbook Application:
```bash
kubectl create namespace guestbook
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-deployment.yaml -n guestbook
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-service.yaml -n guestbook
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-deployment.yaml -n guestbook
kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-service.yaml -n guestbook
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml -n guestbook
kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml -n guestbook
kubectl apply -f guestbookapplication.yaml
```

---

This rewritten version ensures sensitive information like resource IDs is masked. Let me know if you need further adjustments!
