package main

import (
	"bytes"
	"encoding/base64"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"

	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/logger"
)

const (
	defaultTemplatePath    = "templates/s3_bucket.tf.tmpl"
	defaultOutputDir       = "generated"
	defaultObjectOwnership = "BucketOwnerPreferred"
)

type Server struct {
	templatePath           string
	outputDir              string
	defaultObjectOwnership string
}

type terraformRequest struct {
	Payload struct {
		Properties terraformProperties `json:"properties"`
	} `json:"payload"`
}

type terraformProperties struct {
	AWSRegion       string `json:"aws-region"`
	ACL             string `json:"acl"`
	BucketName      string `json:"bucket-name"`
	ObjectOwnership string `json:"object-ownership"`
}

type terraformTemplateData struct {
	AWSRegion       string
	ACL             string
	BucketName      string
	ObjectOwnership string
	ResourceName    string
}

type renderResponse struct {
	TerraformBase64 string `json:"terraform_base64"`
}

type errorResponse struct {
	Error string `json:"error"`
}

func main() {
	server := Server{
		templatePath:           envOrDefault("TEMPLATE_PATH", defaultTemplatePath),
		outputDir:              envOrDefault("OUTPUT_DIR", defaultOutputDir),
		defaultObjectOwnership: envOrDefault("DEFAULT_OBJECT_OWNERSHIP", defaultObjectOwnership),
	}

	port := envOrDefault("PORT", "3000")

	app := server.App()
	err := app.Listen(":" + port)
	log.Fatal(err)
}

func newApp(server Server) *fiber.App {
	return server.App()
}

func (s Server) App() *fiber.App {
	app := fiber.New()

	app.Use(logger.New())

	app.Get("/healthz", func(c fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})
	app.Post("/terraform", s.handleTerraform)

	return app
}

func (s Server) handleTerraform(c fiber.Ctx) error {
	var req terraformRequest
	if err := c.Bind().Body(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(errorResponse{Error: "invalid JSON request body"})
	}

	content, err := s.renderTerraform(req.Payload.Properties)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(errorResponse{Error: err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(renderResponse{
		TerraformBase64: base64.StdEncoding.EncodeToString(content),
	})
}

func (s Server) renderTerraform(props terraformProperties) ([]byte, error) {
	data := s.buildTemplateData(props)

	tmpl, err := template.ParseFiles(s.templatePath)
	if err != nil {
		return nil, fmt.Errorf("load terraform template: %w", err)
	}

	var rendered bytes.Buffer
	if err := tmpl.ExecuteTemplate(&rendered, filepath.Base(s.templatePath), data); err != nil {
		return nil, fmt.Errorf("render terraform template: %w", err)
	}

	if err := os.MkdirAll(s.outputDir, 0o755); err != nil {
		return nil, fmt.Errorf("create output directory: %w", err)
	}

	filename := filepath.Join(s.outputDir, data.ResourceName+".tf")
	if err := os.WriteFile(filename, rendered.Bytes(), 0o644); err != nil {
		return nil, fmt.Errorf("write terraform file: %w", err)
	}

	return rendered.Bytes(), nil
}

func (s Server) buildTemplateData(props terraformProperties) terraformTemplateData {
	return terraformTemplateData{
		AWSRegion:       strings.TrimSpace(props.AWSRegion),
		ACL:             strings.TrimSpace(props.ACL),
		BucketName:      strings.TrimSpace(props.BucketName),
		ObjectOwnership: s.objectOwnershipOrDefault(props.ObjectOwnership),
		ResourceName:    strings.TrimSpace(props.BucketName),
	}
}

func (s Server) objectOwnershipOrDefault(objectOwnership string) string {
	objectOwnership = strings.TrimSpace(objectOwnership)
	if objectOwnership != "" {
		return objectOwnership
	}
	if strings.TrimSpace(s.defaultObjectOwnership) == "" {
		return defaultObjectOwnership
	}
	return strings.TrimSpace(s.defaultObjectOwnership)
}

func terraformResourceName(bucketName string) string {
	name := strings.TrimSpace(bucketName)
	name = strings.NewReplacer(".", "_", "-", "_").Replace(name)
	return regexp.MustCompile(`[^a-z0-9.-]`).ReplaceAllString(name, "_")
}

func envOrDefault(key, fallback string) string {
	value := strings.TrimSpace(os.Getenv(key))
	if value == "" {
		return fallback
	}
	return value
}
