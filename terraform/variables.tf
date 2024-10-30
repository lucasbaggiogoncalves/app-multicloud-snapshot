variable "customer" {
  type = map(string)
}

variable "enviroment" {
  type = string
}

variable "location" {
  type = string
}

variable "projects" {
  type = map(string)
}

variable "tags" {
  type = map(string)
}

variable "tags-dev" {
  type = map(string)
}

variable "app-snapshot-aut-acc-runbooks" {
  type = map(string)
}

variable "app-snapshot-aut-acc-runbooks-py" {
  type = map(string)
}

variable "app-snapshot-aut-acc-connections" {
  type = map(map(string))
}

variable "app-snapshot-aut-acc-credentials" {
  type = map(map(string))
}

variable "app-snapshot-stg-acc-oci-auth" {
  type = string
}

variable "app-snapshot-stg-acc-oci-auth-sas" {
  type = string
}