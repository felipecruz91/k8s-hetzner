#!/bin/bash
export TF_VAR_hcloud_token=$(cat hetzner-api-token.txt)
terraform apply -var master_location=hel1 -var master_server_type=cpx11 -var worker_nodes_count=1 -var worker_server_type=cpx11 -var worker_location=hel1
