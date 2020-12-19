resource "aws_db_subnet_group" "private-db" {
  name       = "private-db"
  subnet_ids = aws_subnet.subnet.*.id
  tags = {
    Name = "private-db"
  }
}

resource "aws_db_parameter_group" "default" {
  name        = "rds-pg"
  family      = "mysql5.6"
  description = "Managed by Terraform"

  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

resource "aws_db_instance" "ambitious-db" {
  identifier             = "ambitious-db"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.21"
  instance_class         = "db.t3.micro"
  name                   = "ambitious"
  username               = "moizumi"
  password               = "base0210"
  vpc_security_group_ids = ["${aws_security_group.private-db-sg.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.private-db.name}"
  skip_final_snapshot    = true
}
