aws eks update-kubeconfig --name my-eks && \ 
// Atualiza a configuração do kubectl para o cluster EKS
kubectl apply -f ./kubernetes
// Aplica os recursos do Kubernetes definidos no diretório 'kubernetes/'