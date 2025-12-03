SHELL := /bin/bash

# Vars
TF_DIR ?= terraform/envs/vagrant
TF_DIR_ABS := $(abspath $(TF_DIR))

.PHONY: up tf-init tf-apply ansible

up: tf-init tf-apply
	TF_DIR=$(TF_DIR_ABS) ./ansible/run.sh

tf-init:
	terraform -chdir=$(TF_DIR_ABS) init

tf-apply:
	terraform -chdir=$(TF_DIR_ABS) apply -auto-approve
