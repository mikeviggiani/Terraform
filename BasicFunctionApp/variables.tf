# terraform/variables.tf

variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type        = string
  description = "Azure region to deploy module to"
}

variable "shortloc" {
  type        = string
  description = "abbreviation of location for names "
}

variable "storagename" {
  type        = string
  description = "Storage Account Name"
}

variable "createdby" {
  type        = string
  description = "Tag: CreatedBy"
}

variable "ownedby" {
  type        = string
  description = "Tag: OwnedBy"
}

variable "tagappname" {
  type        = string
  description = "Tag: ApplicationName"
}