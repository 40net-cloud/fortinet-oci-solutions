# FortiSandbox Standalone Deployment on Oracle Cloud Infrastructure

This folder contains a standalone FortiSandbox deployment template for Oracle Cloud Infrastructure (OCI), modeled on the existing FortiADC standalone pattern in this repository.

## Included assets

- [Standalone/terraform](Standalone/terraform) — Terraform stack, marketplace metadata, and deployment documentation
- [Standalone/readme.md](Standalone/readme.md) — product-specific deployment guide

## Deployment model

The template uses a single-primary-VNIC layout with OCI Marketplace image subscription support, variable-driven networking, and a Marketplace UI-friendly configuration file.

## Workflow support

- [.github/workflows/fsb-tf-standalone.yml](.github/workflows/fsb-tf-standalone.yml) — validates, packages, and publishes the FortiSandbox standalone stack
- [.github/workflows/imageautomation.yml](.github/workflows/imageautomation.yml) — includes FortiSandbox in the generated marketplace listing sync
