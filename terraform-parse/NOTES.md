# - Part 1 (API Service): Describe how you implemented the `Terraform-Parse` service. Include the framework/language you chose, how the API works, and how it translates the payload into Terraform code.

Framework/Language: Go with Fiber

How the API works: When the API receives a request, it loads the Terraform template, replaces the placeholders with values from the request body, writes the rendered output to a new file, and returns the file content as a Base64-encoded response.

How it translates the payload into Terraform code: The service uses Go's `text/template` package. The Terraform configuration is provided as a Go template, and the API renders it by replacing the placeholders with values from the request body.

S3 bucket ACLs are deprecated in many use cases and should generally be replaced with IAM policies and bucket policies. However, I assumed that Tripla might still have a use case that requires ACLs, so I designed the template to support them.


# - Part 2 (Terraform): Describe the issues you found and how you approached improving them. Mention anything you think could still be enhanced.

I started by reviewing the Terraform structure and creating a root module to test the existing configuration. I then ran `terraform plan` to identify and fix errors.

I also reviewed the AWS and Terraform AWS Provider documentation to better understand the intended infrastructure and determine the correct Terraform implementation. Once the configuration could successfully provision the EKS cluster, I refactored it into a reusable Terraform module that supports deployments across multiple environments.

EKS:
- Removed references to non-existent variables
- Added an EKS managed node group

S3:
- Added support for conditional resource creation
- Added support for bucket ACL configuration

Refactoring:
- Removed the provider configuration from the module. To support deployments across multiple environments, provider configuration should be defined in the root module rather than inside a reusable child module. Keeping it inside the module can also create dependency issues when destroying resources.
- Replaced hard-coded values with configurable variables
- Created a root module for testing under `/test`

The result is a reusable Terraform module for provisioning EKS clusters across multiple environments.


# - Part 3 (Helm): Explain the problems you encountered with the chart, how you addressed them, and how you validated your changes.

I started by rendering the Helm templates, fixing the errors, and repeating the process until the chart produced valid Kubernetes manifests.

I reviewed the label selectors to ensure that traffic would be routed correctly from the Kubernetes Service to the application pods.

After validating the rendered manifests, I started a Minikube cluster, deployed the chart, and tested connectivity to the application using `kubectl port-forward`.

Validation commands:
- Used `helm template` to render and validate the chart
- Used `helm install` and `helm upgrade` to deploy and test the chart in Kubernetes

Changes:
- Fixed invalid YAML syntax and indentation
- Created reusable label helpers to reduce duplication and avoid copy-and-paste mistakes
- Replaced hard-coded values with configurable chart values
- Updated the default application values to use `terraform-parse-service`
- Configured the chart to ignore `backend.replicas` when HPA is enabled, avoiding conflicting configuration
- Created a sample values file for production deployments

# - Part 4 (System Behavior): Share your thoughts on how this setup might behave under load or in failure scenarios, and what strategies could make it more resilient in the long term.

Since the backend application generates and returns the Terraform file directly to the client, it can be considered a stateless application. Therefore, running multiple replicas should not introduce dependency or state-consistency issues, and the system should be able to scale horizontally to handle higher traffic.

However, its actual performance under load would still depend on factors such as CPU and memory usage, request size, file-generation time, and any limits imposed by downstream services. Load testing would help determine appropriate resource requests, limits, and autoscaling thresholds.

For long-term improvements, the frontend could be moved to static-content hosting behind a CDN, such as Amazon CloudFront or Cloudflare. This could reduce infrastructure costs, improve response times, and provide caching at edge locations.

For the backend, pods should be distributed across multiple worker nodes and Availability Zones. Pod anti-affinity or topology spread constraints could be used to avoid placing all replicas on the same node or in the same zone. This would improve availability if a physical host or an entire Availability Zone became unavailable.

Additional resilience strategies could include:

- Configuring a Horizontal Pod Autoscaler to scale based on CPU, memory, or request metrics
- Adding graceful shutdown and request timeout handling
- Implementing rate limiting to protect the service from excessive traffic
- Adding monitoring, logging, and alerting for latency, error rate, and resource usage
- Using a Pod Disruption Budget to maintain availability during planned maintenance

# - Part 5 (Approach & Tools): Outline the approach you took to complete the task, including any resources, tools, or methods that supported your work.
I started by understanding the problem and identifying the expected outcome. From there, I designed a solution that best addressed the requirements and constraints of the task.

I then implemented and tested the solution iteratively until it worked as expected. After completing the core functionality, I reviewed the implementation for further improvements in security, cost efficiency, reliability, maintainability, and performance.

Official documentation was my primary source of information, as it helped me understand the intended behavior, recommended practices, and technical limitations of the tools involved. I also used local testing and validation tools to confirm that each part of the solution behaved correctly.

Tools:
- Go
- Docker
- Terraform
- Helm
- AWS CLI
- kubectl
- Minikube
- VScode
- Codex
