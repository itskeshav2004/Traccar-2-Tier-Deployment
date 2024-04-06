variable "cidr_block" {
  type = list(string)
}

variable "db_cidr_block" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}

variable "subnet_name" {
  type = list(string)
}

variable "db_subnet_name" {
  type = list(string)
}

variable "port" {
  type = list(number)
}

variable "src_cidr" {
  type = list(string)
}