FROM golang:1.25-alpine AS build

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /bin/terraform-parse-service .

FROM alpine:3.22

WORKDIR /app
COPY --from=build /bin/terraform-parse-service /app/terraform-parse-service
COPY templates /app/templates

ENV PORT=3000
ENV TEMPLATE_PATH=templates/s3_bucket.tf.tmpl
ENV OUTPUT_DIR=generated

EXPOSE 3000
ENTRYPOINT ["/app/terraform-parse-service"]
