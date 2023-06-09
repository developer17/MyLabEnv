variable "cidr_block" {
  type = list(string)
  default = [ "172.20.0.0/16","172.20.10.0/24" ]
}

variable "ports" {
  type = list(number)
  default = [ 22,80,443,8080,8081 ]
  #443 -> HTTPS , 8080 -> Jenkins, 8081 -> Nexus
}

variable "ami" {
  type = string
  default = "ami-06a0cd9728546d178"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}
variable "instance_type_for_nexus" {
  type = string
  default = "t2.medium"
}