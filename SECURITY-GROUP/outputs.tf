output "ec2-sg-ids" {
  value = aws_security_group.ec2-sg.id
}
output "alb-sg-ids" {
  value = aws_security_group.alb-sg.id
}
output "ec2-sg-name" {
  value = aws_security_group.ec2-sg.name
}
output "alb-sg-name" {
  value = aws_security_group.alb-sg.name
}