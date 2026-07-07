# Terraform-Parse Service

Small Go/Fiber API that renders an S3 bucket request into a Terraform `.tf` file.

## Run

```sh
go run .
```

The service listens on `:3000` by default. Set `PORT`, `TEMPLATE_PATH`, or `OUTPUT_DIR` to override runtime defaults.

## API

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
# ObjectWriter 
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

`object-ownership` is optional. When omitted, the service uses `BucketOwnerPreferred`.

The response includes the generated filename and Terraform content. The same content is written to `generated/<bucket-name>.tf`.

```json
{
  "filename": "generated/tripla_bucket.tf",
  "terraform": "..."
}
```

## Test

```sh
go test ./...
```
