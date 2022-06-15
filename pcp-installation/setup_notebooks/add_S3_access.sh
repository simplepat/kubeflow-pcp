#!/bin/bash

### Airbus ca can be found here: https://github.airbus.corp/connectivity/airbus-ca/blob/master/bundle/airbus-ca.crt
ROLE_NAME=arn:aws:iam::475747285824:role/role-2i84-eks-kubeflow-kube2iam-demo
PROFILE_NAMESPACE=kubeflow-user-example-com
PODDEFAULT_FILE="poddefault_s3_access.yaml"

# 1) Create PodDefault that will add this role to any Notebook that will select the right configuration during Notebook creation
cat > $PODDEFAULT_FILE << 'EOF'
apiVersion: "kubeflow.org/v1alpha1"
kind: PodDefault
metadata:
  name: add-aws-datascience-role
  namespace: $PROFILE_NAMESPACE
spec:
 selector:
  matchLabels:
    add-aws-datascience-access-role: "true"
 desc: "add aws datascience services role to the Notebook server"
 annotations:
   iam.amazonaws.com/role: $ROLE_NAME
EOF
gsed -i 's#$PROFILE_NAMESPACE#'"$PROFILE_NAMESPACE"'#g' $PODDEFAULT_FILE
gsed -i 's#$ROLE_NAME#'"$ROLE_NAME"'#g' $PODDEFAULT_FILE
kubectl apply -f $PODDEFAULT_FILE

