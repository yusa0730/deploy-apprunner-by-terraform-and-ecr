resource "aws_vpc" "main" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env}-vpc"
  }
}

# Subnet
resource "aws_subnet" "lambda_private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.0.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.env}-lambda-private-a-sbn"
  }
}

resource "aws_subnet" "lambda_private_c" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.2.1.0/24"
  availability_zone = "${var.region}c"

  tags = {
    Name = "${var.env}-lambda-private-c-sbn"
  }
}

# Internet Gateway
# resource "aws_internet_gateway" "main" {
#   vpc_id = aws_vpc.main.id

#   tags = {
#     Name = "${var.env}-internet-gateway"
#   }
# }

# # route_table
# resource "aws_route_table" "public_a" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.main.id
#   }
#   tags = {
#     Name = "${var.env}-lambda-public-a-route-table"
#   }
# }

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

# resource "aws_route_table_association" "public_1a" {
#   subnet_id      = aws_subnet.lambda_public_a.id
#   route_table_id = aws_route_table.public_a.id
# }

# resource "aws_route_table_association" "public_1c" {
#   subnet_id      = aws_subnet.lambda_public_c.id
#   route_table_id = aws_route_table.public_c.id
# }

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_1a.id
  # }
  tags = {
    Name = "${var.env}-lambda-private-a-route-table"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.main.id

  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nat_1c.id
  # }
  tags = {
    Name = "${var.env}-lambda-private-c-route-table"
  }
}

resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.lambda_private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_1c" {
  subnet_id      = aws_subnet.lambda_private_c.id
  route_table_id = aws_route_table.private_c.id
}

# security_group
resource "aws_security_group" "from_api_gateway_to_lambda_sg" {
  name        = "${var.env}-internal-lambda-sg"
  description = "${var.env}-internal-lambda-sg"
  vpc_id      = aws_vpc.main.id

  egress {
    description = ""
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_vpc_endpoint" "apprunner" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.ap-northeast-1.apprunner.requests"
  vpc_endpoint_type = "Interface"
  
  subnet_ids        = [
    aws_subnet.lambda_private_a.id,
    aws_subnet.lambda_private_c.id,
  ]

  security_group_ids = [
    aws_security_group.from_api_gateway_to_lambda_sg.id,
  ]

  private_dns_enabled = false
}
