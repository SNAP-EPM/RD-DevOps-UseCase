variable "prefix" {
  default = "pratikaksdemo"
}
variable "subscription_id" {
  type = string
}
variable "client_id" {
  type = string
}
variable "client_secret" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "location" {
  type = string
  default = "eastus2"
}
variable "agent_count"{
  default = 1
}