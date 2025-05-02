# 🧱 Single-Node Kubernetes Setup for Ubuntu 24.04

This script automates the installation and configuration of a full single-node Kubernetes cluster using `kubeadm`, `containerd`, and Calico networking. It also deploys a sample Hello World pod.

## ✅ Features

- Installs `containerd` as the container runtime
- Configures Kubernetes using `kubeadm`
- Sets up Calico CNI
- Allows scheduling on the control plane node
- Deploys a simple pod that prints "Hello, world"

## ⚙️ Requirements

- Ubuntu 24.04 LTS
- 2+ CPUs, 2GB+ RAM
- Root access (use `sudo`)

## 🚀 Quick Start

1. Clone or download this repo:

   ```bash
   git clone https://github.com/your-user/k8s-ubuntu-setup.git
   cd k8s-ubuntu-setup

