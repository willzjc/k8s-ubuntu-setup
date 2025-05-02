#!/bin/bash
set -e

echo "🚧 Disabling swap..."
swapoff -a
sed -i '/ swap / s/^/#/' /etc/fstab

echo "📦 Installing dependencies..."
apt update && apt install -y apt-transport-https ca-certificates curl gpg gnupg lsb-release

echo "📦 Installing containerd..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt update && apt install -y containerd.io
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd

echo "🗝️ Adding Kubernetes repo (pkgs.k8s.io)..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

echo "📦 Installing kubelet, kubeadm, kubectl..."
apt update && apt install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "🚀 Initializing Kubernetes cluster..."
kubeadm init --pod-network-cidr=192.168.0.0/16

echo "🔧 Configuring kubectl access for user: $SUDO_USER"
mkdir -p /home/$SUDO_USER/.kube
cp -i /etc/kubernetes/admin.conf /home/$SUDO_USER/.kube/config
chown $(id -u $SUDO_USER):$(id -g $SUDO_USER) /home/$SUDO_USER/.kube/config

echo "🌐 Installing Calico network plugin..."
sudo -u $SUDO_USER kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

echo "👷 Allowing control-plane to run workloads..."
sudo -u $SUDO_USER kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

echo "💬 Deploying Hello World pod..."
cat <<EOF | sudo -u $SUDO_USER kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hello-world
spec:
  restartPolicy: Never
  containers:
  - name: hello
    image: bash
    command: ["bash", "-c", "echo Hello, world; sleep 10"]
EOF

echo "✅ Kubernetes cluster is ready. Use 'kubectl get pods -A' to check status."

