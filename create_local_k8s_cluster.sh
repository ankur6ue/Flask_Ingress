# The steps shown below are for the most part the same as described in the instructions on how to deploy
# a local kubernetes cluster using kubeadm here:
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
# turn off swap
sudo swapoff -a
# reset current state
yes | sudo kubeadm reset
# We use two custom settings in kubeadm:
# 1. initialize kubeadm with a custom setting for horizontal pod autoscaler (hpa) downscale (lower downscale time from
# default (5 min) to 15s)) so that pod downscaling occurs faster
# 2. Specify a custom pod-network-cidr, which is needed by Flannel
sudo kubeadm init --config custom-kube-controller-manager-config.yaml
# To see default kubeadm configs, use:
# kubeadm config print init-defaults

mkdir -p $HOME/.kube
yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml
# linux foundation kubernetes tutorial recommends calico networking plugin
# kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

# to get rid of old cni plugins, delete cni files in /etc/cni/net.d/
# IMPORTANT: Do this for worker nodes also:
#  sudo rm -rf /etc/cni/net.d
# sudo rm -rf /var/lib/cni
# Wait for all pods to come up
sleep 5s
# verify all kube-system pods are running
kubectl get pods -n kube-system
# By default, your cluster will not schedule Pods on the control-plane node for security reasons.
# If you want to be able to schedule Pods on the control-plane node, for example for a single-machine
# Kubernetes cluster for development, run:
kubectl taint nodes --all node-role.kubernetes.io/master-

# deploy nginx ingress controller (in the ingress-nginx namespace):
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/baremetal/deploy.yaml

# To check if all is ok:
# kubectl get all -n ingress-nginx

# to see token list
kubeadm token list

# To enable kubectl autocomplete. Must start a new shell after this command
# echo 'source <(kubectl completion bash)' >>~/.bashrc
alias k=kubectl
source <(kubectl completion bash)                       # completion will save a lot of time and avoid typo
source <(kubectl completion bash | sed 's/kubectl/k/g') # so completion works with the alias "k"

############ CLUSTER SET UP COMPLETE #####################

