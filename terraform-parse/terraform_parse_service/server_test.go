package main

import (
	"encoding/base64"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRenderTerraformCreatesFileAndReturnsBase64(t *testing.T) {
	outputDir := t.TempDir()
	app := newApp(Server{
		templatePath: filepath.Join("templates", "s3_bucket.tf.tmpl"),
		outputDir:    outputDir,
	})

	body := `{
		"payload": {
			"properties": {
				"aws-region": "eu-west-1",
				"acl": "private",
				"bucket-name": "tripla-bucket"
			}
		}
	}`
	req := httptest.NewRequest(http.MethodPost, "/terraform", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("test request failed: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("expected status %d, got %d", http.StatusCreated, resp.StatusCode)
	}

	var got renderResponse
	if err := json.NewDecoder(resp.Body).Decode(&got); err != nil {
		t.Fatalf("decode response: %v", err)
	}

	terraform := decodeTerraformBase64(t, got.TerraformBase64)
	assertContains(t, terraform, `provider "aws"`)
	assertContains(t, terraform, `region = "eu-west-1"`)
	assertContains(t, terraform, `resource "aws_s3_bucket" "tripla-bucket"`)
	assertContains(t, terraform, `object_ownership = "BucketOwnerPreferred"`)
	assertContains(t, terraform, `acl        = "private"`)

	expectedFile := filepath.Join(outputDir, "tripla-bucket.tf")
	written, err := os.ReadFile(expectedFile)
	if err != nil {
		t.Fatalf("expected terraform file to be written: %v", err)
	}
	if string(written) != terraform {
		t.Fatal("written terraform file does not match response body")
	}
}

func TestRenderTerraformUsesRequestedObjectOwnership(t *testing.T) {
	app := newApp(Server{
		templatePath: filepath.Join("templates", "s3_bucket.tf.tmpl"),
		outputDir:    t.TempDir(),
	})

	body := `{
		"payload": {
			"properties": {
				"aws-region": "eu-west-1",
				"acl": "private",
				"bucket-name": "tripla-bucket",
				"object-ownership": "ObjectWriter"
			}
		}
	}`
	req := httptest.NewRequest(http.MethodPost, "/terraform", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("test request failed: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("expected status %d, got %d", http.StatusCreated, resp.StatusCode)
	}

	var got renderResponse
	if err := json.NewDecoder(resp.Body).Decode(&got); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	terraform := decodeTerraformBase64(t, got.TerraformBase64)
	assertContains(t, terraform, `object_ownership = "ObjectWriter"`)
}

func TestRenderTerraformUsesConfiguredDefaultObjectOwnership(t *testing.T) {
	app := newApp(Server{
		templatePath:           filepath.Join("templates", "s3_bucket.tf.tmpl"),
		outputDir:              t.TempDir(),
		defaultObjectOwnership: "ObjectWriter",
	})

	body := `{
		"payload": {
			"properties": {
				"aws-region": "eu-west-1",
				"acl": "private",
				"bucket-name": "tripla-bucket"
			}
		}
	}`
	req := httptest.NewRequest(http.MethodPost, "/terraform", strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req)
	if err != nil {
		t.Fatalf("test request failed: %v", err)
	}
	if resp.StatusCode != http.StatusCreated {
		t.Fatalf("expected status %d, got %d", http.StatusCreated, resp.StatusCode)
	}

	var got renderResponse
	if err := json.NewDecoder(resp.Body).Decode(&got); err != nil {
		t.Fatalf("decode response: %v", err)
	}
	terraform := decodeTerraformBase64(t, got.TerraformBase64)
	assertContains(t, terraform, `object_ownership = "ObjectWriter"`)
}

func decodeTerraformBase64(t *testing.T, value string) string {
	t.Helper()

	decoded, err := base64.StdEncoding.DecodeString(value)
	if err != nil {
		t.Fatalf("decode terraform_base64: %v", err)
	}
	return string(decoded)
}

func assertContains(t *testing.T, value, want string) {
	t.Helper()
	if !strings.Contains(value, want) {
		t.Fatalf("expected %q to contain %q", value, want)
	}
}
