1) Adapt MLFlow Docker image:
# In the DockerFile, to make the build work in Airbus context,
# add airbus proxy environnement variables
# add airbus-ca.crt &
# add pip.conf for using pip install
# remove proxy environnement variables at the end to not create conflict
# once the image is deployed
# add some linux executables like /sh, /mkdir, /cat to ssh into the container for debug purposes
 


2) Build specific MLflow Docker image:
# Log in to Airbus Artifactory project repository (use JFROG username & token)
docker login r-2i84-datamlops-docker-local.artifactory.2b82.aws.cloud.airbus.corp

# Build image locally: go to pcp-installation/setup_mlflow and execute following command
docker build -f Dockerfile -t r-2i84-datamlops-docker-local.artifactory.2b82.aws.cloud.airbus.corp/arnaud/mlflow:v12 .

# Push built image to Airbus Artifactory
docker push r-2i84-datamlops-docker-local.artifactory.2b82.aws.cloud.airbus.corp/arnaud/mlflow:v12

3) Disable istio sidecar injection into the mlflow & mysql deployment

4) First, deploy the mysql pod.

kubectl apply -f deploy-mysql-backend.yaml

# Then SSH into the deployed mysql container and manually create the user with below command:

mysql -u root -p${MYSQL_ROOT_PASSWORD}
CREATE USER 'mlflow'@'%%' IDENTIFIED BY '12341234';

5) Now, deploy the mlflow pod.

kubectl apply -f deploy-mlflow-server.yaml
