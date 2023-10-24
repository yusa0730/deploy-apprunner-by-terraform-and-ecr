resource "aws_vpc" "main" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name      = "${var.project_name}-${var.env}-vpc",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

# Subnet
resource "aws_subnet" "interface_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name      = "${var.project_name}-${var.env}-interface-private-a-sbn",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "interface_private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name      = "${var.project_name}-${var.env}-interface-private-c-sbn",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

# RDS
resource "aws_subnet" "aurola_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.5.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name      = "${var.project_name}-${var.env}-aurola-private-a-sbn",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "aurola_private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.6.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name      = "${var.project_name}-${var.env}-aurola-private-c-sbn",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "ec2_public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.2.10.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-${var.env}-ec2-public-a-sbn",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_subnet" "aws_batch_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.12.0/24"
  availability_zone = "${var.region}a"
  # map_public_ip_on_launch = true

  tags = {
    Name      = "${var.project_name}-${var.env}-aws-batch-public-a-sbn",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "${var.project_name}-${var.env}-internet-gateway",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

# # route_table
resource "aws_route_table" "public_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name      = "${var.project_name}-${var.env}-public-a-route-table",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

# resource "aws_route_table" "public_c" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
#   tags = {
#     Name = "${var.env}-lambda-public-c-route-table"
#   }
# }

resource "aws_route_table_association" "ec2_public_1a" {
  subnet_id      = aws_subnet.ec2_public_a.id
  route_table_id = aws_route_table.public_a.id
}

# resource "aws_route_table_association" "public_1c" {
#   subnet_id      = aws_subnet.lambda_public_c.id
#   route_table_id = aws_route_table.public_c.id
# }

resource "aws_route_table_association" "aws_batch_private_1a" {
  subnet_id      = aws_subnet.aws_batch_private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_1a.id
  # }

  tags = {
    Name      = "${var.project_name}-${var.env}-private-a-route-table",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_1c.id
  # }
  tags = {
    Name      = "${var.project_name}-${var.env}-private-c-route-table",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_route_table_association" "interface_private_1a" {
  subnet_id      = aws_subnet.interface_private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "interface_private_1c" {
  subnet_id      = aws_subnet.interface_private_c.id
  route_table_id = aws_route_table.private_c.id
}

resource "aws_route_table_association" "aurola_private_1a" {
  subnet_id      = aws_subnet.aurola_private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "aurola_private_1c" {
  subnet_id      = aws_subnet.aurola_private_c.id
  route_table_id = aws_route_table.private_c.id
}

# security_group
resource "aws_security_group" "interface_sg" {
  name        = "${var.project_name}-${var.env}-interface-sg"
  description = "${var.project_name}-${var.env}-interface-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic from App Runner"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-interface-sg",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "${var.project_name}-${var.env}-ec2-sg"
  description = "${var.project_name}-${var.env}-ec2-sg"
  vpc_id      = aws_vpc.main.id

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-ec2-sg",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "aurora_sg" {
  name        = "${var.project_name}-${var.env}-aurora-sg"
  description = "${var.project_name}-${var.env}-aurora-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow inbound traffic from App Runner"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [
      aws_security_group.ec2_sg.id,
      aws_security_group.interface_sg.id
    ]
  }

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-aurora-sg",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "aws_batch_sg" {
  name        = "${var.project_name}-${var.env}-public-aws-batch-sg"
  description = "${var.project_name}-${var.env}-public-aws-batch-sg"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-aws-batch-sg-sg",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "vpc_endpoint_cloudwatch_logs_sg" {
  name        = "${var.env}-vpc-endpoint-cloudwatch-logs-sg"
  description = "${var.env}-vpc-endpoint-cloudwatch-logs-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "from public AWS Batch"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.aws_batch_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-vpce-clougwatch-logs-sg",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_security_group" "vpc_endpoint_ecr_sg" {
  name        = "${var.env}-vpc-endpoint-ecr-sg"
  description = "${var.env}-vpc-endpoint-ecr-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "from AWS Batch"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = ["${aws_security_group.aws_batch_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-${var.env}-vpce-ecr-sg",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_endpoint" "apprunner" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.apprunner.requests"
  vpc_endpoint_type = "Interface"

  subnet_ids = [
    aws_subnet.interface_private_a.id,
    aws_subnet.interface_private_c.id,
  ]

  security_group_ids = [
    aws_security_group.interface_sg.id,
  ]

  private_dns_enabled = false

  tags = {
    Name      = "${var.project_name}-${var.env}-apprunner-vpc-endpoint",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

### ECRのVPC Endpoint
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.aws_batch_private_a.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoint_ecr_sg.id]
  private_dns_enabled = true

  tags = {
    Name      = "${var.project_name}-${var.env}-endpoint-ecr-dkr",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.aws_batch_private_a.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoint_ecr_sg.id]
  private_dns_enabled = true

  tags = {
    Name      = "${var.project_name}-${var.env}-endpoint-ecr-api",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_endpoint" "cloudwatch_logs" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.logs"
  vpc_endpoint_type = "Interface"
  subnet_ids = [
    aws_subnet.aws_batch_private_a.id
  ]
  security_group_ids  = [aws_security_group.vpc_endpoint_cloudwatch_logs_sg.id]
  private_dns_enabled = true

  tags = {
    Name      = "${var.project_name}-${var.env}-endpoint-cloudwatch-logs",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_a.id, aws_route_table.private_c.id]

  tags = {
    Name      = "${var.project_name}-${var.env}-endpoint-s3",
    Env       = var.env,
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc_endpoint_route_table_association" "private_a_s3" {
  route_table_id  = aws_route_table.private_a.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "private_c_s3" {
  route_table_id  = aws_route_table.private_c.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}
