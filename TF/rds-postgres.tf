

#Create database
resource "aws_db_subnet_group" "rds1-subnet-group" {
  name       = "rds1-subnet-group"
  #subnet_ids = [aws_subnet.database-subnet[0].id, aws_subnet.database-subnet[1].id]
  subnet_ids = [aws_subnet.db-private-subnets[0].id, aws_subnet.db-private-subnets[1].id]
  #subnet_ids = [aws_subnet.db-private-subnets[1].id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "RDS1" {
#   count                  = 1
  allocated_storage      = var.rds_postgres.allocated_storage
  db_subnet_group_name   = aws_db_subnet_group.rds1-subnet-group.id
  engine                 = var.rds_postgres.engine
  engine_version         = var.rds_postgres.engine_version
  instance_class         = var.rds_postgres.instance_class
  multi_az               = var.rds_postgres.multi_az
  db_name                = var.rds_postgres.name
  username               = var.user_information.username
  password               = var.user_information.password
  skip_final_snapshot    = var.rds_postgres.skip_final_snapshot
  vpc_security_group_ids = [aws_security_group.rds1-sg.id]
}

# Create WP Access Security Group
resource "aws_security_group" "rds1-sg" {
  name        = "rds1-sg"
  description = "rds1-sg"
  vpc_id      = aws_vpc.Application-Plane-VPC.id
  tags = {
    Name = "rds1-sg"
  }
}

# Create rules for WP Access Security Group
resource "aws_security_group_rule" "AllowPostgres" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  #cidr_blocks              = ["0.0.0.0/0"]
  source_security_group_id = aws_security_group.wp-server-sg.id
  security_group_id        = aws_security_group.rds1-sg.id
}

# Create rules for WP Access Security Group - Egress
resource "aws_security_group_rule" "RDSEgress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds1-sg.id
}