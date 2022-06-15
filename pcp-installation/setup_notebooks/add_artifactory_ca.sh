#!/bin/bash

ARTIFACTORY_URL=""
USER=""
PASSWORD=""
PROFILE_NAMESPACE=kubeflow-user-example-com
DOCKER_CREDS_FILE="config.json"

# 1) Artifactory-credentials already up, just need to add imagePullSecrets ?
AUTH=$(echo -n $USER:$PASSWORD | base64)
echo $AUTH
cat > $DOCKER_CREDS_FILE << 'EOF'
{
    "auths": {
      "docker.artifactory.2b82.aws.cloud.airbus.corp": "$AUTH",
      "google-container-registry.artifactory.2b82.aws.cloud.airbus.corp": "$AUTH",
      "mcr-microsoft.artifactory.2b82.aws.cloud.airbus.corp": "$AUTH",
      "quay-io.artifactory.2b82.aws.cloud.airbus.corp": "$AUTH",
      "r-2i84-datamlops-docker-local.artifactory.2b82.aws.cloud.airbus.corp": "$AUTH",
      "r-2i84-mlops-docker-remote.artifactory.2b82.aws.cloud.airbus.corp": "$AUTH"
    }
}
EOF
gsed -i 's\$AUTH\'"$AUTH"'\g' $DOCKER_CREDS_FILE
#sed -i 's#$ARTIFACTORY_URL#'"$ARTIFACTORY_URL"'#g' $DOCKER_CREDS_FILE
cat $DOCKER_CREDS_FILE


kubectl create --namespace $PROFILE_NAMESPACE configmap docker-config --from-file=$DOCKER_CREDS_FILE

# 2) Add Artifactory server certificate to Notebooks so that Fairing pods will be able to get it to push images

CA_BUNDLE_NAME=artifactory.crt
PATH_TO_CA_BUNDLE=<path-to>/$CA_BUNDLE_NAME
PROFILE_NAMESPACE=kubeflow-user-example-com
PODDEFAULT_FILE="poddefault_actifactory_ca_fairing.yaml"
CM_NAME=ca-artifactory-fairing

kubectl -n $PROFILE_NAMESPACE create configmap $CM_NAME --from-file=$PATH_TO_CA_BUNDLE

### Create a new poddefault for fairing pods
cat > $PODDEFAULT_FILE << 'EOF'
apiVersion: "kubeflow.org/v1alpha1"
kind: PodDefault
metadata:
  name: add-artifactory-ca-crt-to-fairing
  namespace: $PROFILE_NAMESPACE
spec:
 selector:
  matchLabels:
    fairing-builder: kaniko
 desc: "add artifactory ca certificate to push images to Artifactory from Fairing pod"
 volumeMounts:
 - name: $CM_NAME
   mountPath: /kaniko/ssl/certs/$CA_BUNDLE_NAME
   subPath: $CA_BUNDLE_NAME
 volumes:
 - name: $CM_NAME
   configMap:
     name: $CM_NAME
EOF
gsed -i 's#$PROFILE_NAMESPACE#'"$PROFILE_NAMESPACE"'#g' $PODDEFAULT_FILE
gsed -i 's#$CM_NAME#'"$CM_NAME"'#g' $PODDEFAULT_FILE
gsed -i 's#$CA_BUNDLE_NAME#'"$CA_BUNDLE_NAME"'#g' $PODDEFAULT_FILE
kubectl apply -f $PODDEFAULT_FILE
