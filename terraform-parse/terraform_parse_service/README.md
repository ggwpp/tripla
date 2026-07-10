# Terraform-Parse Service

A small Go/Fiber API that renders an S3 bucket request into Terraform configuration.

The API returns the generated Terraform as a base64 string so clients can decode it into a raw `.tf` file with the original newlines preserved. The service also writes the same generated content to the local output directory for inspection during local development.

## Run

Requirements:

- Go
- `jq` and `base64` for the decode examples
- Terraform and AWS credentials for the end-to-end check

```sh
go run .
```

The service listens on `:3000` by default.

## Configuration

| Env | Description | Default value |
| --- | --- | --- |
| `PORT` | HTTP port used by the Fiber server. | `3000` |
| `TEMPLATE_PATH` | Path to the Terraform template file. | `templates/s3_bucket.tf.tmpl` |
| `OUTPUT_DIR` | Directory where a copy of the generated `.tf` file is written. | `generated` |
| `DEFAULT_OBJECT_OWNERSHIP` | Default S3 object ownership value when `object-ownership` is omitted from the request. | `BucketOwnerPreferred` |

Example:

```sh
PORT=8080 OUTPUT_DIR=/tmp/generated go run .
```

## API

### Request

```sh
curl -X POST http://localhost:3000/terraform \
  -H 'Content-Type: application/json' \
  -d '{
    "payload": {
      "properties": {
        "aws-region": "eu-west-1",
        "acl": "private",
        "bucket-name": "tripla-bucket",
        "object-ownership": "BucketOwnerPreferred"
      }
    }
  }'
```

`object-ownership` is optional. When omitted, the service uses `DEFAULT_OBJECT_OWNERSHIP`.

Example with `ObjectWriter`:

```sh
curl -X POST http://localhost:3000/terraform \
  -H 'Content-Type: application/json' \
  -d '{
    "payload": {
      "properties": {
        "aws-region": "eu-west-1",
        "acl": "private",
        "bucket-name": "tripla-bucket",
        "object-ownership": "ObjectWriter"
      }
    }
  }'
```

### Response

```json
{
  "terraform_base64": "..."
}
```

Decode `terraform_base64` to create the Terraform file:

```sh
curl -X POST http://localhost:3000/terraform \
  -H 'Content-Type: application/json' \
  -d '{
    "payload": {
      "properties": {
        "aws-region": "ap-northeast-1",
        "acl": "private",
        "bucket-name": "tripla-bucket-123sfs"
      }
    }
  }' | jq -r .terraform_base64 | base64 -d > tripla-bucket-123sfs.tf
```

On macOS, use `base64 -D` instead of `base64 -d` if your local `base64` command does not support `-d`.

## Test

```sh
go test ./...
```

## End-to-end Check

1. Start the server.

```sh
go run .
```

2. Generate and decode the Terraform file.

```sh
curl -X POST http://localhost:3000/terraform \
  -H 'Content-Type: application/json' \
  -d '{
    "payload": {
      "properties": {
        "aws-region": "ap-northeast-1",
        "acl": "private",
        "bucket-name": "tripla-bucket-123sfs"
      }
    }
  }' | jq -r .terraform_base64 | base64 -d > tripla-bucket-123sfs.tf
```

3. Apply the Terraform.

```sh
terraform init
terraform apply
```

4. Confirm the bucket was created.

```sh
aws s3 ls
```

5. Clean up.

```sh
terraform destroy
```

## AI Assistant Usage

I used an AI assistant as a development partner for this project. It helped compare the trade-offs between returning raw Terraform content and returning base64-encoded content, update the response shape to `terraform_base64`, revise tests to decode and verify the response, and polish this README.

I reviewed the generated suggestions, made the final design decisions, and verified the implementation with the test suite.
