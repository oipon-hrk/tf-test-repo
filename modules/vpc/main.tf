provider "aws" {
  region = "ap-northeast-1"
}

locals{
    system_name = "tf-test"
    name_prefix = "${local.system_name}"
}

resource "aws_vpc" "tf-test_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

resource "aws_subnet" "web_subnet-01" {
  vpc_id = aws_vpc.tf-test_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "${local.name_prefix}-web-subnet-${var.env}-01"
  }
}

resource "aws_subnet" "api_subnet-01" {
  vpc_id = aws_vpc.tf-test_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.10.0/24"

  tags = {
    Name = "${local.name_prefix}-api-subnet-${var.env}-01"
  }
}

resource "aws_subnet" "api_subnet-02" {
  vpc_id = aws_vpc.tf-test_vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block = "10.0.20.0/24"

  tags = {
    Name = "${local.name_prefix}-api-subnet-${var.env}-02"
  }
}

resource "aws_subnet" "alb_subnet-01" {
  vpc_id = aws_vpc.tf-test_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.30.0/24"

  tags = {
    Name = "${local.name_prefix}-alb-subnet-${var.env}-01"
  }
}

resource "aws_subnet" "alb_subnet-02" {
  vpc_id = aws_vpc.tf-test_vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block = "10.0.40.0/24"

  tags = {
    Name = "${local.name_prefix}-alb-subnet-${var.env}-02"
  }
}

resource "aws_subnet" "rds_subnet-01" {
  vpc_id = aws_vpc.tf-test_vpc.id
  availability_zone = "ap-northeast-1a"
  cidr_block = "10.0.50.0/24"

  tags = {
    Name = "${local.name_prefix}-rds-subnet-${var.env}-01"
  }
}

resource "aws_subnet" "rds_subnet-02" {
  vpc_id = aws_vpc.tf-test_vpc.id
  availability_zone = "ap-northeast-1c"
  cidr_block = "10.0.60.0/24"

  tags = {
    Name = "${local.name_prefix}-rds-subnet-${var.env}-02"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "tf-test_igw" {
  vpc_id = aws_vpc.tf-test_vpc.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# RouteTable(web)
resource "aws_route_table" "web_rtb" {
  vpc_id = aws_vpc.tf-test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-test_igw.id
  }

  tags = {
    Name = "${local.name_prefix}-web-rtb"
  }
}

resource "aws_route_table_association" "web_rtb_assoc" {
  for_each = {
    subnet_01 = aws_subnet.web_subnet-01.id
    subnet_02 = aws_subnet.alb_subnet-01.id
    subnet_03 = aws_subnet.alb_subnet-02.id
  }
  subnet_id = each.value
  route_table_id = aws_route_table.web_rtb.id
}

# RouteTable(api)
resource "aws_route_table" "api_rtb" {
  vpc_id = aws_vpc.tf-test_vpc.id

  tags = {
    Name = "${local.name_prefix}-api-rtb"
  }
}

resource "aws_route_table_association" "api_rtb_assoc" {
  for_each = {
    subnet_01      = aws_subnet.api_subnet-01.id
    subnet_02      = aws_subnet.api_subnet-02.id
  }
  subnet_id = each.value
  route_table_id = aws_route_table.api_rtb.id
}

# RouteTable(rds)
resource "aws_route_table" "rds_rtb" {
  vpc_id = aws_vpc.tf-test_vpc.id

  tags = {
    Name = "${local.name_prefix}-rds-rtb"
  }
}

resource "aws_route_table_association" "rds_rtb_assoc" {
  for_each = {
    subnet_01      = aws_subnet.rds_subnet-01.id
    subnet_02      = aws_subnet.rds_subnet-02.id
  }
  subnet_id = each.value
  route_table_id = aws_route_table.rds_rtb.id
}