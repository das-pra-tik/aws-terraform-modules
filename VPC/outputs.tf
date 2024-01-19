output "vpc-id" {
  value = aws_vpc.demo-vpc.id
}
output "Public-subnet-IDs" {
  value = [for x in aws_subnet.Public-subnet : x.id]
}
/*
output "public-subnet-count" {
  value = length(aws_subnet.Public-subnet.*.id)
}
output "vpc-cidr" {
  value = aws_vpc.aws-rd-gateway-vpc.cidr_block
}
output "Public-subnet-IDs" {
  value = [for x in aws_subnet.Public-subnet : x.id]
}
output "Private-subnet-IDs" {
  value = [for x in aws_subnet.Private-subnet : x.id]
}
output "public-subnet-cidr" {
  value = [for x in aws_subnet.Public-subnet : x.cidr_block]
}
output "private-subnet-cidr" {
  value = [for x in aws_subnet.Private-subnet : x.cidr_block]
}*/
