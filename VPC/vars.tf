variable "vpc-cidr" { type = string }
variable "vpc-network-map" {
  type = map(object(
    {
      public-subnet  = string
      private-subnet = string
      az             = string
    }
  ))
}