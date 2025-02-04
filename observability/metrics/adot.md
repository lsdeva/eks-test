## 
https://aws-observability.github.io/observability-best-practices/guides


## installation adot add-on


### cert-manager installation

eksctl create fargateprofile \
  --cluster my-eks-cluster \
  --name cert-manager \
  --namespace cert-manager

kubectl create namespace cert-manager

helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.16.3 \
  --set webhook.securePort=10260 \
  --set crds.enabled=true


eksctl create fargateprofile \
  --cluster my-eks-cluster \
  --name "appspace" \
  --namespace "appspace"


### adot add-on installation
https://aws.amazon.com/blogs/containers/metrics-and-traces-collection-using-amazon-eks-add-ons-for-aws-distro-for-opentelemetry/

validate adot version 

 aws eks describe-addon-versions | grep -i adot -A 20
v0.109.0-eksbuild.2

kubectl create namespace opentelemetry-operator-system

eksctl create fargateprofile \
  --cluster my-eks-cluster \
  --name opentelemetry-operator-system \
  --namespace opentelemetry-operator-system

aws eks create-addon --addon-name adot --addon-version v0.109.0-eksbuild.2 --cluster-name my-eks-cluster

aws eks describe-addon --addon-name adot --cluster-name my-eks-cluster



### Deploying the ADOT Collector


eksctl create iamserviceaccount \
--name amp-iamproxy-ingest-role \
--namespace prometheus \
--cluster my-eks-cluster \
--attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
--approve \
--override-existing-serviceaccounts

eksctl create fargateprofile \
  --cluster my-eks-cluster \
  --name prometheus \
  --namespace prometheus

WORKSPACE_ID=$(aws amp list-workspaces --alias observability-workshop | jq .workspaces[0].workspaceId -r)
AMP_ENDPOINT_URL=$(aws amp describe-workspace --workspace-id $WORKSPACE_ID | jq .workspace.prometheusEndpoint -r)
AMP_REMOTE_WRITE_URL=${AMP_ENDPOINT_URL}api/v1/remote_write
curl -O https://raw.githubusercontent.com/aws-samples/one-observability-demo/main/PetAdoptions/cdk/pet_stack/resources/otel-collector-prometheus.yaml
sed -i -e s/AWS_REGION/$AWS_REGION/g otel-collector-prometheus.yaml
sed -i -e s^AMP_WORKSPACE_URL^$AMP_REMOTE_WRITE_URL^g otel-collector-prometheus.yaml


#### the otel config had to chnage for higher resource demand.

kubectl apply -f ./otel-collector-prometheus.yaml

