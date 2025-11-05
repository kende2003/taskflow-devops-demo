output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "public_a_subnet_id" {
  value = aws_subnet.public_a.id
}

output "public_a_subnet_cidr_block" {
  value = aws_subnet.public_a.cidr_block
}

output "private_a_subnet_id" {
  value = aws_subnet.private_a.id
}

output "private_a_subnet_cidr_block" {
  value = aws_subnet.private_a.cidr_block
}

output "private_b_subnet_id" {
  value = aws_subnet.private_b.id
}

output "private_b_subnet_cidr_block" {
  value = aws_subnet.private_b.cidr_block
}

output "private_db_subnet_ids" {
  value = [
    aws_subnet.private_db_a.id,
    aws_subnet.private_db_b.id,
    aws_subnet.private_db_c.id
  ]
}

output "private_db_subnet_cidr_blocks" {
  value = [
    aws_subnet.private_db_a.cidr_block,
    aws_subnet.private_db_b.cidr_block,
    aws_subnet.private_db_c.cidr_block
  ]
}