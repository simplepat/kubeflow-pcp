kustomize build common/cert-manager/cert-manager/base | kubectl apply -f -
sleep 5
kustomize build common/cert-manager/kubeflow-issuer/base | kubectl apply -f -
sleep 5
kustomize build common/istio-1-9/istio-crds/base | kubectl apply -f -
kustomize build common/istio-1-9/istio-namespace/base | kubectl apply -f -
kustomize build common/istio-1-9/istio-install/base | kubectl apply -f -
sleep 5
kustomize build common/dex/overlays/istio | kubectl apply -f -
sleep 5
kustomize build common/oidc-authservice/base | kubectl apply -f -
kustomize build common/knative/knative-serving/base | kubectl apply -f -
kustomize build common/istio-1-9/cluster-local-gateway/base | kubectl apply -f -
sleep 5
kustomize build common/knative/knative-eventing/base | kubectl apply -f -
kustomize build common/kubeflow-namespace/base | kubectl apply -f -
kustomize build common/kubeflow-roles/base | kubectl apply -f -
kustomize build common/istio-1-9/kubeflow-istio-resources/base | kubectl apply -f -
sleep 5
kustomize build apps/pipeline/upstream/env/platform-agnostic-multi-user | kubectl apply -f -
sleep 5
kustomize build apps/kfserving/upstream/overlays/kubeflow | kubectl apply -f -
kustomize build apps/katib/upstream/installs/katib-with-kubeflow | kubectl apply -f -
kustomize build apps/centraldashboard/upstream/overlays/istio | kubectl apply -f -
kustomize build apps/admission-webhook/upstream/overlays/cert-manager | kubectl apply -f -
kustomize build apps/jupyter/notebook-controller/upstream/overlays/kubeflow | kubectl apply -f -
kustomize build apps/jupyter/jupyter-web-app/upstream/overlays/istio | kubectl apply -f -
kustomize build apps/profiles/upstream/overlays/kubeflow | kubectl apply -f -
kustomize build apps/volumes-web-app/upstream/overlays/istio | kubectl apply -f -
kustomize build apps/tensorboard/tensorboards-web-app/upstream/overlays/istio | kubectl apply -f -
kustomize build apps/tensorboard/tensorboard-controller/upstream/overlays/kubeflow | kubectl apply -f -
kustomize build apps/training-operator/upstream/overlays/kubeflow | kubectl apply -f -
kustomize build apps/mpi-job/upstream/overlays/kubeflow | kubectl apply -f -
kustomize build common/user-namespace/base | kubectl apply -f -
#
#kustomize build common/istio-ingress/overlays/https | kubectl apply -f -