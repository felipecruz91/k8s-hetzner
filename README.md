# k8s-hetzner-cloud

Kubernetes cluster composed of 1 master node and 3 worker nodes.

Container runtime: docker

```cli
terraform init

terraform plan -var="hcloud_token=..."

terraform apply -var="hcloud_token=..." -auto-approve
```

```cli
ssh -i ~/.ssh/id_rsa root@<IP_ADDRESS>
```

root@master:~# kubeadm init --apiserver-advertise-address=10.0.1.5 --kubernetes-version stable-1.19
[init] Using Kubernetes version: v1.19.5
[preflight] Running pre-flight checks  
 [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow
the guide at https://kubernetes.io/docs/setup/cri/
error execution phase preflight: [preflight] Some fatal errors occurred:
[ERROR NumCPU]: the number of available CPUs 1 is less than the required 2
[ERROR KubeletVersion]: the kubelet version is higher than the control plane version. This is not a supported version skew and may lead to a malfunctional cluster. Kubelet version: "1.20.0" Control plane version: "1.19.5"

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

References:

- https://blog.alexellis.io/kubernetes-in-10-minutes/
