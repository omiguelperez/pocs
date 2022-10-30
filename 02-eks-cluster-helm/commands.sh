# Install EKS
# https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html

export AWS_PROFILE=personal
export AWS_REGION=eu-west-1
export CLUSTER_NAME=your-eks-cluster

# Get KubeConfig
kubectl config view

# Create cluster
eksctl cluster -f 02-eks-cluster.yaml --profile $AWS_PROFILE

# Update KubeConfig with EKS cluster info
aws eks --region $AWS_REGION update-kubeconfig --name $CLUSTER_NAME
# Log: Added new context arn:aws:eks:eu-west-1:590875020771:cluster/your-eks-cluster to /home/o/.kube/config

# Helm
helm create frontend
# Get current context
kubectl config current-context
# Install Frontend
helm install frontend .
# Fix issue: https://github.com/helm/helm/issues/10975
# Output
# Get the application URL by running these commands:
# export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=frontend,app.kubernetes.io/instance=frontend" -o jsonpath="{.items[0].metadata.name}")
# export CONTAINER_PORT=$(kubectl get pod --namespace default $POD_NAME -o jsonpath="{.spec.containers[0].ports[0].containerPort}")
# echo "Visit http://127.0.0.1:8080 to use your application"
# kubectl --namespace default port-forward $POD_NAME 8080:$CONTAINER_PORT

# Upgrade the application
helm upgrade frontend .

# Get service IP
export SERVICE_IP=$(kubectl get svc --namespace default frontend --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
echo http://$SERVICE_IP:80

# Switching contexts
kubectl config current-context
kubectl config get-contexts
kubectl config use-context {CONTEXT_NAME}
