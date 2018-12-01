#!/bin/bash

# Destroy Misc Resources
terraform init \
    -backend-config="storage_account_name=${TF_VAR_k8sbook_prefix}aiotfstate" \
    -backend-config="container_name=tfstate-misc" \
    -backend-config="key=terraform.tfstate" \
    -reconfigure \
    ./misc

terraform destroy -auto-approve ./misc-blue

# Destroy AKS Clster (Blue)
terraform init \
    -backend-config="storage_account_name=${TF_VAR_k8sbook_prefix}aiotfstate" \
    -backend-config="container_name=tfstate-shared" \
    -backend-config="key=terraform.tfstate" \
    -reconfigure \
    ./cluster-blue

terraform destroy -auto-approve ./cluster-blue

# Destroy Shared Resources
terraform init \
    -backend-config="storage_account_name=${TF_VAR_k8sbook_prefix}aiotfstate" \
    -backend-config="container_name=tfstate-shared" \
    -backend-config="key=terraform.tfstate" \
    -reconfigure \
    ./shared

terraform destroy -auto-approve ./shared

# Delete Resource Group for Remote State
RESOURCE_GROUP_NAME=${TF_VAR_k8sbook_prefix}-k8sbook-aio-tfstate-rg
az group delete -n $RESOURCE_GROUP_NAME

# Delete Kubetenetes config
context=$(kubectl config current-context)

cluster=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'$context'")].context.cluster}')
user=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'$context'")].context.user}')

kubectl config delete-context $context
kubectl config delete-cluster $cluster
kubectl config unset users.${user}