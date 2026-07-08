package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

func TestRenderTerraformCreatesFile(t *testing.T) {
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

	expectedFile := filepath.Join(outputDir, "tripla-bucket.tf")
	if got.Filename != expectedFile {
		t.Fatalf("expected filename %q, got %q", expectedFile, got.Filename)
	}
	assertContains(t, got.Terraform, `provider "aws"`)
	assertContains(t, got.Terraform, `region = "eu-west-1"`)
	assertContains(t, got.Terraform, `resource "aws_s3_bucket" "tripla-bucket"`)
	assertContains(t, got.Terraform, `object_ownership = "BucketOwnerPreferred"`)
	assertContains(t, got.Terraform, `acl        = "private"`)

	written, err := os.ReadFile(expectedFile)
	if err != nil {
		t.Fatalf("expected terraform file to be written: %v", err)
	}
	if string(written) != got.Terraform {
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
	assertContains(t, got.Terraform, `object_ownership = "ObjectWriter"`)
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
	assertContains(t, got.Terraform, `object_ownership = "ObjectWriter"`)
}

func assertContains(t *testing.T, value, want string) {
	t.Helper()
	if !strings.Contains(value, want) {
		t.Fatalf("expected %q to contain %q", value, want)
	}
}
