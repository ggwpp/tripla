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

- Part 4 (System Behavior): Share your thoughts on how this setup might behave under load or in failure scenarios, and what strategies could make it more resilient in the long term.
- Part 5 (Approach & Tools): Outline the approach you took to complete the task, including any resources, tools, or methods that supported your work.