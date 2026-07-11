### Test
1. Update the desired configuration at `test/eks.tf`
2. `terraform plan`
3. `terraform apply`
4. `aws eks update-kubeconfig --region <region> --name <cluster-name>`
5. Try to access with kubectl. exmaple `kubectl get namespace`
6. Clean up: `terraform destroy`
