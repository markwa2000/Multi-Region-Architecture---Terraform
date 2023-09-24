output "availability_zones" {
  value = data.aws_availability_zones.available.names
}

output "rds_endpoint" {
  value = aws_db_instance.mum_db.endpoint
}

output "alb_endpoint" {
  value = aws_lb.mum-alb.arn
}

output "subnet_ids" {
  value = aws_subnet.private[*].id
}