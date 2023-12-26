provider "aws" {
  region = "eu-west-1"
}


resource "aws_vpc" "vpc_eu_west_1" {
   cidr_block = var.vpc_cidr_block
   tags = {
     Name = "vpc_eu_west_1"
   }
}


resource "aws_internet_gateway" "gateway_vpc_eu_west_1" {
   vpc_id = aws_vpc.vpc_eu_west_1.id
   tags = {
     Name = "aws_vpc_gateway"
   }
}



resource "aws_subnet" "public_subnet_vpc_eu_west_1a" {
   vpc_id = aws_vpc.vpc_eu_west_1.id
   cidr_block = "10.0.0.0/24"
   availability_zone = "eu-west-1a"
   map_public_ip_on_launch = true
   tags = {
     Name = "public_subnet"
   }
}


resource "aws_subnet" "private_subnet_vpc_eu_west_1b" {
   vpc_id = aws_vpc.vpc_eu_west_1.id
   cidr_block = "10.0.1.0/24"
   availability_zone = "eu-west-1b"
   map_public_ip_on_launch = false
   tags = {
     Name = "private_subnet"
   }
}



resource "aws_route_table" "public_route_table_subnet_vpc_eu_west_1a" {
   vpc_id = aws_vpc.vpc_eu_west_1.id
   
   route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway_vpc_eu_west_1.id
   }

   tags = {
     Name = "public_route_table_subnet_vpc_eu_west_1a"
   }
}


resource "aws_route_table_association" "public_route_table_subnet_vpc_eu_west_1a_association" {
    route_table_id = aws_route_table.public_route_table_subnet_vpc_eu_west_1a.id
    subnet_id = aws_subnet.public_subnet_vpc_eu_west_1a.id
}

resource "aws_route_table" "private_route_table_subnet_vpc_eu_west_1a" {
   vpc_id = aws_vpc.vpc_eu_west_1.id
   route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = aws_nat_gateway.ng.id
   }
   tags = {
     Name = "public_route_table_subnet_vpc_eu_west_1a"
   }
}

resource "aws_route_table_association" "private_route_table_subnet_vpc_eu_west_1a_association" {
   route_table_id = aws_route_table.private_route_table_subnet_vpc_eu_west_1a.id 
   subnet_id = aws_subnet.private_subnet_vpc_eu_west_1b.id
}



resource "aws_security_group" "MyPublicSecGrp" {
    name = "my_sec_grp"
    vpc_id = aws_vpc.vpc_eu_west_1.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "PublicSecGrp"
    }
  
}

resource "aws_instance" "PublicInstance" {
    ami = lookup(var.ami_id,var.aws_region,"")
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.MyPublicSecGrp.id ]
    subnet_id = aws_subnet.public_subnet_vpc_eu_west_1a.id

    key_name = var.key_name

    tags = {
      Name = "PublicInstance"
    }
  
}

resource "aws_instance" "PrivateInstance" {
    ami = lookup(var.ami_id,var.aws_region,"")
    instance_type = "t2.micro"
    vpc_security_group_ids = [ aws_security_group.MyPublicSecGrp.id ]
    subnet_id = aws_subnet.private_subnet_vpc_eu_west_1b.id

    key_name = var.key_name

    tags = {
      Name = "PrivateInstance"
    }
  
}

resource "aws_eip" "nat_gateway_ip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "ng" {
   allocation_id = aws_eip.nat_gateway_ip.id
   subnet_id = aws_subnet.public_subnet_vpc_eu_west_1a.id
   tags = {
     Name = "MyNatGateway"
   }

  depends_on = [ aws_internet_gateway.gateway_vpc_eu_west_1 ]
}