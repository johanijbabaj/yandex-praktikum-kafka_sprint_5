variable "yc_token" {}
variable "yc_cloud_id" {}
variable "yc_folder_id" {}
variable "network_id" {}
variable "local_ip" {}
variable "subnet_id_a" {
  description = "ID подсети для ru-central1-a"
  type        = string
}

variable "subnet_id_b" {
  description = "ID подсети для ru-central1-b"
  type        = string
}

variable "subnet_id_d" {
  description = "ID подсети для ru-central1-d"
  type        = string
}
variable "kafka_user" {
  description = "Kafka user"
  type        = string
  sensitive   = true  
}

variable "kafka_user_password" {
  description = "Password for the Kafka user"
  type        = string
  sensitive   = true  
}

variable "kafka_admin" {
  description = "Kafka admin"
  type        = string
  sensitive   = true
}

variable "kafka_admin_password" {
  description = "Password for the Kafka admin"
  type        = string
  sensitive   = true
}
