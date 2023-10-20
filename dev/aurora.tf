resource "aws_rds_cluster" "aurora_cluster" {
  cluster_identifier = "${var.env}-aurora-cluster"
  engine = "aurora-mysql"
  database_name = "test"
  master_username = "ishizawa"
  master_password = "ishizawa0730"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot = true
  vpc_security_group_ids = [
    aws_security_group.aurora_sg.id
  ]
  db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
}

resource "aws_rds_cluster_instance" "aurora_cluster_instance" {
  identifier = "${var.env}-aurora-cluster-instance"
  cluster_identifier = aws_rds_cluster.aurora_cluster.cluster_identifier
  instance_class = "db.r5.large"
  engine = "aurora-mysql"
}

resource "aws_db_subnet_group" "aurora_subnet_group" {
  name = "${var.env}-aurora-subnet-group"
  subnet_ids = [
    aws_subnet.aurola_private_a.id,
    aws_subnet.aurola_private_c.id
  ]

  tags = {
    Name = "${var.env}-aurora-subnet-group"
  }
}