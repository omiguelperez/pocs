export NAMESPACE=st-airflow-ns

# Create Namespace
# kubectl create namespace $NAMESPACE

# Install the chart
export RELEASE_NAME=st-airflow-release
# helm install $RELEASE_NAME apache-airflow/airflow --namespace $NAMESPACE

# Install the chart with sample DAGs
helm install $RELEASE_NAME apache-airflow/airflow \
  --namespace $NAMESPACE \
  --set-string "env[0].name=AIRFLOW__CORE__LOAD_EXAMPLES" \
  --set-string "env[0].value=True"

# Port Forwarding
kubectl port-forward svc/$RELEASE_NAME-webserver 8080:8080 --namespace $NAMESPACE

# Get Fernet Key
echo Fernet Key: $(kubectl get secret --namespace $NAMESPACE $RELEASE_NAME-fernet-key -o jsonpath="{.data.fernet-key}" | base64 --decode)

# Uninstall
helm uninstall $RELEASE_NAME --namespace $NAMESPACE

# Add DAGs

mkdir my-airflow-project && cd my-airflow-project
mkdir dags  # put dags here
cat <<EOM > Dockerfile
FROM apache/airflow
COPY . .
EOM

# https://medium.com/international-school-of-ai-data-science/hello-world-using-apache-airflow-792947431455

docker build --pull --tag my-dags:0.0.1 .
kind load docker-image my-dags:0.0.1

helm upgrade $RELEASE_NAME apache-airflow/airflow --namespace $NAMESPACE \
    --set images.airflow.repository=my-dags \
    --set images.airflow.tag=0.0.1