output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_app_subnet_ids" {
  description = "Private application subnet IDs."
  value       = [for subnet in aws_subnet.private_app : subnet.id]
}

output "private_db_subnet_ids" {
  description = "Private database subnet IDs."
  value       = [for subnet in aws_subnet.private_db : subnet.id]
}

output "public_route_table_id" {
  description = "Public route table ID."
  value       = aws_route_table.public.id
}

output "private_app_route_table_ids" {
  description = "Private application route table IDs."
  value       = [for route_table in aws_route_table.private_app : route_table.id]
}

output "private_db_route_table_id" {
  description = "Private database route table ID."
  value       = aws_route_table.private_db.id
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs."
  value       = [for nat in aws_nat_gateway.this : nat.id]
}
