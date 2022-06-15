#!/bin/bash

ARTIFACTORY_URL=""
PROFILE_NAMESPACE=kubeflow-user-example-com
SA=default-editor
NOTEBOOK=arnaud-nb
HEADER_USERID="user@example.com"
ACCESS_FILE=allow-notebook-access-to-ml-pipeline-services.yaml
# 

cat > $ACCESS_FILE << 'EOF'
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: add-header-$NOTEBOOK
  namespace: $PROFILE_NAMESPACE
spec:
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: SIDECAR_OUTBOUND
      routeConfiguration:
        vhost:
          name: ml-pipeline.kubeflow.svc.cluster.local:8888
          route:
            name: default
    patch:
      operation: MERGE
      value:
        request_headers_to_add:
        - append: true
          header:
            key: kubeflow-userid
            value: $HEADER_USERID
  workloadSelector:
    labels:
      notebook-name: $NOTEBOOK
---
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: add-header-ml-pipeline-ui-$NOTEBOOK
  namespace: $PROFILE_NAMESPACE
spec:
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: SIDECAR_OUTBOUND
      routeConfiguration:
        vhost:
          name: ml-pipeline-ui.kubeflow.svc.cluster.local:80
          route:
            name: default
    patch:
      operation: MERGE
      value:
        request_headers_to_add:
        - append: true
          header:
            key: kubeflow-userid
            value: $HEADER_USERID
  workloadSelector:
    labels:
      notebook-name: $NOTEBOOK
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
 name: bind-ml-pipeline-nb-$PROFILE_NAMESPACE
 namespace: kubeflow
spec:
 selector:
   matchLabels:
     app: ml-pipeline
 rules:
 - from:
   - source:
       principals: ["cluster.local/ns/$PROFILE_NAMESPACE/sa/$SA"]
---
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: add-header-minio-ui-$NOTEBOOK
  namespace: $PROFILE_NAMESPACE
spec:
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: SIDECAR_OUTBOUND
      routeConfiguration:
        vhost:
          name: minio-service.kubeflow.svc.cluster.local:9000
          route:
            name: default
    patch:
      operation: MERGE
      value:
        request_headers_to_add:
        - append: true
          header:
            key: kubeflow-userid
            value: $HEADER_USERID
  workloadSelector:
    labels:
      notebook-name: $NOTEBOOK
EOF
gsed -i 's#$PROFILE_NAMESPACE#'"$PROFILE_NAMESPACE"'#g' $ACCESS_FILE
gsed -i 's#$SA#'"$SA"'#g' $ACCESS_FILE
gsed -i 's#$HEADER_USERID#'"$HEADER_USERID"'#g' $ACCESS_FILE
gsed -i 's#$NOTEBOOK#'"$NOTEBOOK"'#g' $ACCESS_FILE
kubectl apply -f $ACCESS_FILE

#2)
source_ns=kube-system
kubectl get secret artifactory-creds-$source_ns --namespace=$source_ns -o yaml | sed 's/kube-system/'"$PROFILE_NAMESPACE"'/' | kubectl apply -f -

kubectl -n $PROFILE_NAMESPACE patch serviceaccount $SA -p '{"imagePullSecrets": [{"name": "artifactory-creds-'${PROFILE_NAMESPACE}'"}]}'

#3)
kubectl create --namespace=kubeflow rolebinding --clusterrole=kubeflow-edit --serviceaccount=${PROFILE_NAMESPACE}:default-editor ${PROFILE_NAMESPACE}-elyra
kubectl create --namespace=kubeflow rolebinding --clusterrole=ml-pipeline-ui --serviceaccount=${PROFILE_NAMESPACE}:default-editor ${PROFILE_NAMESPACE}-ml-pipeline-ui
kubectl create --namespace=kubeflow rolebinding --clusterrole=kubeflow-view --serviceaccount=${PROFILE_NAMESPACE}:default-editor ${PROFILE_NAMESPACE}-minio-view
kubectl create --namespace=istio-system rolebinding --clusterrole=kubeflow-view --serviceaccount=${PROFILE_NAMESPACE}:default-editor ${PROFILE_NAMESPACE}-ingressgateway-view
kubectl create --namespace=kubeflow rolebinding --clusterrole=kubeflow-kfserving-edit --serviceaccount=${PROFILE_NAMESPACE}:default-editor ${PROFILE_NAMESPACE}-kubeflow-kfserving-edit
kubectl create --namespace=seldon-system rolebinding --clusterrole=seldon-manager-role-seldon-system --serviceaccount=${PROFILE_NAMESPACE}:default-editor ${PROFILE_NAMESPACE}-seldon-manager-role

#4) Create mlpipeline-minio-artifact secret in User namespace so that pods can mount volumes
kubectl get secret mlpipeline-minio-artifact --namespace=kubeflow -o yaml | sed "s/namespace: kubeflow/namespace: $PROFILE_NAMESPACE/" | kubectl create -f -


###
#Setup Elyra (in JupyterHub server)
#1. Configure runtime:
echo http://ml-pipeline.kubeflow.svc.cluster.local:8888
echo kubeflow-user-example-com
echo Argo
echo NO_AUTHENTICATION
#
echo http://minio-service.kubeflow.svc.cluster.local:9000
echo mlpipeline
echo USER_CREDS
echo minio
echo minio123


###
#cat > $ACCESS_FILE << 'EOF'
#---
#apiVersion: networking.istio.io/v1alpha3
#kind: EnvoyFilter
#metadata:
#  name: add-header-mlmd-ui
#  namespace: $PROFILE_NAMESPACE
#spec:
#  configPatches:
#  - applyTo: VIRTUAL_HOST
#    match:
#      context: SIDECAR_OUTBOUND
#      routeConfiguration:
#        vhost:
#          name: m.kubeflow.svc.cluster.local:8080
#          route:
#            name: default
#    patch:
#      operation: MERGE
#      value:
#        request_headers_to_add:
#        - append: true
#          header:
#            key: kubeflow-userid
#            value: $HEADER_USERID
#  workloadSelector:
#    labels:
#      notebook-name: $NOTEBOOK
#---
#apiVersion: security.istio.io/v1beta1
#kind: AuthorizationPolicy
#metadata:
# name: bind-minio-nb-$PROFILE_NAMESPACE
# namespace: kubeflow
#spec:
# selector:
#   matchLabels:
#     app: minio
# rules:
# - from:
#   - source:
#       principals: ["cluster.local/ns/$PROFILE_NAMESPACE/sa/$SA"]
#EOF
#gsed -i 's#$PROFILE_NAMESPACE#'"$PROFILE_NAMESPACE"'#g' $ACCESS_FILE
#gsed -i 's#$SA#'"$SA"'#g' $ACCESS_FILE
#gsed -i 's#$HEADER_USERID#'"$HEADER_USERID"'#g' $ACCESS_FILE
#gsed -i 's#$NOTEBOOK#'"$NOTEBOOK"'#g' $ACCESS_FILE
#kubectl apply -f $ACCESS_FILE
