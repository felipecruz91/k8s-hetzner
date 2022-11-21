#!/bin/bash
export TF_VAR_hcloud_token=$(cat hetzner-api-token.txt)
terraform destroy
