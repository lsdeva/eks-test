

---

### **AWS Documentation**  
[Amazon EKS Fargate Logging User Guide](https://docs.aws.amazon.com/eks/latest/userguide/fargate-logging.html)  
Amazon EKS on Fargate includes a built-in log router based on Fluent Bit. This eliminates the need for explicitly running a Fluent Bit container as a sidecar, as Amazon manages it for you.

---

### **Steps to Set Up Logging for EKS Fargate**

#### **1. Create the Namespace for `aws-observability`**
Apply the namespace configuration required for Fluent Bit logging:  
```bash
kubectl apply -f aws-observability-namespace.yaml
```

---

#### **2. Create a ConfigMap for Fluent Bit Configuration**
Set up a ConfigMap to define the Fluent Bit configuration for shipping container logs to CloudWatch or another destination:  
```bash
kubectl apply -f aws-logging-cloudwatch-configmap.yaml
```

---

#### **3. Set Permissions for the Fargate Pod Execution Role**
To enable Fargate pods to ship logs to CloudWatch, perform the following steps:

1. **Download the Permissions JSON File**  
   ```bash
   curl -O https://raw.githubusercontent.com/aws-samples/amazon-eks-fluent-logging-examples/mainline/examples/fargate/cloudwatchlogs/permissions.json
   ```

2. **Create an IAM Policy for Logging**  
   ```bash
   aws iam create-policy \
     --policy-name eks-fargate-logging-policy \
     --policy-document file://permissions.json
   ```

3. **Attach the Policy to the Fargate Pod Execution Role**  
   ```bash
   aws iam attach-role-policy \
     --policy-arn arn:aws:iam::xxxxxxxxxxxx:policy/eks-fargate-logging-policy \
     --role-name eksctl-<your-cluster-name>-FargatePodExecutionRole-<unique-id>
   ```

---
