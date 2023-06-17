resource "aws_db_instance" "postgres" {
  engine               = "postgres"
  engine_version       = "14.6"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  identifier           = "rds-postgres-kandula"
  db_name              = "kandula"
  username             = "postgres"
  password             = var.rds_password
  port                 = 5432
  publicly_accessible = false
  skip_final_snapshot = true
#   final_snapshot_identifier = "rds-postgres-final-snapshot-kandula"
#   multi_az = true

  vpc_security_group_ids = [aws_security_group.postgres.id]

  tags = {
    Name = "rds-postgres-kandula"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "rds"
    "service" = "db"
    "consul" = "false"
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet-group-postgres-kandula"
  subnet_ids = [module.kandula-vpc.private_subnets_id[0], module.kandula-vpc.private_subnets_id[1]]  # Replace with your subnet IDs

  tags = {
    Name = "subnet-group-postgres-kandula"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "subnet-group"
    "service" = "db"
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name        = "parameter-group-postgres-kandula"
  family      = "postgres14"
  description = "postgres 14 DB Parameter Group - kandula"

  tags = {
    Name = "parameter-group-postgres-kandula"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "parameter-group"
    "service" = "db"
  }
}

resource "aws_db_option_group" "option_group" {
  name        = "option-group-postgres-kandula"
  engine_name = "postgres"
  major_engine_version = "14"

  tags = {
    Name = "option-group-postgres-kandula"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "option-group"
    "service" = "db"
  }
}

resource "aws_security_group" "postgres" {
  name        = "postgres-sg-kandula"
  description = "Security group for RDS PostgreSQL"
  
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "postgres-sg-${var.project_name}"
    "project" = "kandula"
    "owner" = "hadar"
    "env" = "prd"
    "resource" = "sg"
  }
}