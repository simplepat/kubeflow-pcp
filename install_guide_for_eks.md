[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/awslabs/kubeflow-manifests/issues)
![current development version](https://img.shields.io/badge/Kubeflow-v1.4.1-green.svg?style=flat)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](./LICENSE)
# Kubeflow on PCP - EKS

## Steps to follow to deploy Kubeflow on a sandbox PCP environment

Follow this [installation guide](https://awslabs.github.io/kubeflow-manifests/docs/deployment/vanilla/guide/) to deploy Kubeflow on [Amazon Elastic Kubernetes Service (Amazon EKS)](https://aws.amazon.com/eks/).
Only sections below were used:
* "Install individual components"
    * Git clone [installation guide](https://awslabs.github.io/kubeflow-manifests/docs/deployment/vanilla/guide/)
    * Execute: cd <path-to>/kubeflow-pcp/upstream
    * Execute the commands in <path-to>/kubeflow-pcp/pcp-installation/setup_kubeflow/install_individual_components.sh )
* "Exposing Kubeflow over Load Balancer". Only sections below were used:
    * "Configure Ingress"
        * add certificate arn to param and 
    * "Configure Load Balancer controller" 1.
        * 2., 3., 4. require OIDC service which is not available in PCP
    * Deploy Ingress: 
        * Execute: cd .. 
        * Execute: kustomize build awsconfigs/common/istio-ingress/overlays/https | kubectl apply -f -
        * Add ingress to Route53 record
        * Add security group https-lan
        * Change 200 to 302 redirect for health checks
    * Make minio accessible: 
        * Execute: kubectl apply -f pcp-installation/setup_kubeflow/vs_minio_ui.yaml 

## Install Mlflow

Execute: kubectl apply -f pcp-installation/setup_mlflow/deploy.yaml

## Setup Notebook environment

You must first initialize the different variables present in the following scripts.

* Create PodDefaults with:
    * pcp-installation/setup_notebooks/add_airbus_ca.sh
    * pcp-installation/setup_notebooks/add_artifactory_ca.sh
* Add artifactory credentials to User profiles:
    * pcp-installation/setup_notebooks/add_artifactory_creds_to_profiles.sh
* Add access rights to notebook run by User:
    * pcp-installation/setup_notebooks/add_new_profile_setup.sh
    
## Delete all

Execute commands in pcp-installation/uninstall_kubeflow.sh
Execute: kubectl delete -f pcp-installation/setup_mlflow/deploy.yaml
