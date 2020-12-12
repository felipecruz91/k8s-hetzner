# k8s-hetzner-cloud

Kubernetes cluster composed of 1 master node and 3 worker nodes.

Container runtime: docker

1. Build the VM image with Packer (will generate a snapshot)
2. Deploy infrastructure with Terraform (using as VM image the one created in step 1)

```cli
export TF_VAR_hcloud_token=$(cat hetzner-api-token.txt)
```

## Building the VM image with Packer

```cli
cd images && \
    packer build image-master.json
```

## Creating the infrastructure with Terraform

```cli
terraform init

terraform plan

terraform apply -auto-approve
```

```cli
ssh -i ~/.ssh/id_rsa root@<IP_ADDRESS>
```

## Replacing the container runtime

TODO
