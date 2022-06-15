#!/bin/bash
# Namespace containing the secret artifactory-creds-$ns
source_ns="kube-system"
# Namespaces to receive the duplicated secret
NamespaceArray=("kubeflow-user-example-com")


cat << EOP

#######################################################
###       SECRETS CREATION  (Profiles)        ###
#######################################################
EOP
echo "### Creating Artifactory secret for all namespace ###"
# List of Namespace to create

# For all secrets in @SecretArray, try to create the secret if not exist
for ns in "${NamespaceArray[@]}"
do
  if ! kubectl get secret -A | grep -q artifactory-creds-"$ns"; then
    echo "Creating Artifactory Secret in Namespace $ns"
    while ! kubectl get secret -A | grep -q artifactory-creds-"$ns"; do
      kubectl get secret artifactory-creds-$source_ns --namespace=$source_ns -o yaml | sed 's/kube-system/'"$ns"'/' | kubectl apply -f -
      echo "Trying to create secret in namespace $ns..."
      sleep 2
    done
    echo "Artifactory Secret in namespace $ns successfully created"
  else
    echo "Artifactory Secret in namespace $ns already created, skipping"
  fi
done

cat << EOP

#######################################################
###       ATTACH SECRETS TO DEFAULT SA        ###
#######################################################
EOP
echo "### Creating Artifactory secret for all namespace ###"
# For all secrets in @SecretArray, try to create the secret if not exist
for ns in "${NamespaceArray[@]}"
do
	kubectl -n $ns patch serviceaccount default -p '{"imagePullSecrets": [{"name": "artifactory-creds-'${ns}'"}]}'
done

