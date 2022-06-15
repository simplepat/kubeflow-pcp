#!/bin/bash

### Airbus ca can be found here: https://github.airbus.corp/connectivity/airbus-ca/blob/master/bundle/airbus-ca.crt
PATH_TO_CA_BUNDLE=/Users/zanni_a/Documents/airbus-ca/bundle/airbus-ca.crt
PROFILE_NAMESPACE=kubeflow-user-example-com
PODDEFAULT_FILE="poddefault_airbus_ca.yaml"

# 1) Create config map in namespace target
kubectl -n $PROFILE_NAMESPACE create configmap ca-pemstore --from-file=$PATH_TO_CA_BUNDLE

# 2) Create PodDefault that will mount this configmap to any Notebook that will select the right configuration during Notebook creation
cat > $PODDEFAULT_FILE << 'EOF'
apiVersion: "kubeflow.org/v1alpha1"
kind: PodDefault
metadata:
  name: add-airbus-ca-crt
  namespace: $PROFILE_NAMESPACE
spec:
 selector:
  matchLabels:
    add-airbus-ca-crt: "true"
 desc: "add airbus ca certificate to git clone from Airbus repo"
 volumeMounts:
 - name: ca-pemstore
   mountPath: /etc/ssl/certs/airbus-ca.crt
   subPath: airbus-ca.crt
 volumes:
 - name: ca-pemstore
   configMap:
     name: ca-pemstore
EOF
gsed -i 's#$PROFILE_NAMESPACE#'"$PROFILE_NAMESPACE"'#g' $PODDEFAULT_FILE
kubectl apply -f $PODDEFAULT_FILE

