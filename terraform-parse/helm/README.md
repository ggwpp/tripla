### Test

Render the helm-chart
```sh
# Render the template
helm template terraform-parse .
```

Test on minikube
```sh
# Deploy to k8s
minikube start
# make sure in the `terraform-parse/helm` dir
helm install terraform-parse .

# Backend Test
kubectl port-forward svc/terraform-parse-backend 3000:3000
# In new terminal
curl -X POST http://localhost:3000/terraform \
  -H 'Content-Type: application/json' \
  -d '{
      "payload": {
        "properties": {
          "aws-region": "ap-northeast-1",
          "acl": "private",
          "bucket-name": "tripla-bucket"
          }
        }
      }'

# Frontend Test
kubectl port-forward svc/terraform-parse-frontend 8080:80
curl localhost:8080
```
