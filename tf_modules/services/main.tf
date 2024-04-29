resource "aws_vpc" "MyTestVpc" {
   cidr_block = var.vpc_cidr
   enable_dns_support = true
   enable_dns_hostnames = true

   tags = {
      Name = var.env_name
   }
}


resource "aws_internet_gateway" "vpc_igw" {
   vpc_id = aws_vpc.MyTestVpc.id
   tags = {
     Name = "${var.env_name}_igw"
   }
}




resource "aws_route_table" "MyPublicRt" {
   vpc_id = aws_vpc.MyTestVpc.id 
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
   }
}

resource "aws_route_table_association" "rt_association" {
  route_table_id = aws_route_table.MyPublicRt.id 
  subnet_id = aws_subnet.MyPublicSubnet.id
}

resource "aws_subnet" "MyPublicSubnet" {
   vpc_id = aws_vpc.MyTestVpc.id
   cidr_block = "10.0.1.0/24"
   map_public_ip_on_launch = true 

   tags = {
     Name = "${var.env_name}_public_subnet"
   }
}


resource "aws_route_table" "MyCustomRouteTable" {
   vpc_id = aws_vpc.MyTestVpc.id
   route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.MyNatGW.id
   }

    tags = {
    Name = "${var.env_name}_private_route_table_association"
  }
}

resource "aws_route_table_association" "MyCustomRouteTableAssociation" {
   route_table_id = aws_route_table.MyCustomRouteTable.id
   subnet_id = aws_subnet.MyPrivateSubnet.id
}


resource "aws_subnet" "MyPrivateSubnet" {
  vpc_id = aws_vpc.MyTestVpc.id
  cidr_block = "10.0.2.0/24"


  tags = {
    Name = "${var.env_name}_private_subnet"
  }
}

resource "aws_eip" "MyEip" {
   tags = {
     Name = "${var.env_name}_eip"
   }
}

resource "aws_nat_gateway" "MyNatGW" {
   subnet_id = aws_subnet.MyPublicSubnet.id
   allocation_id = aws_eip.MyEip.id

   tags = {
     Name  = "${var.env_name}_NAT GW"
   }
}


resource "aws_instance" "MyPrivateEC2" {
    instance_type = var.instance_type
    ami = var.ami
    subnet_id = aws_subnet.MyPrivateSubnet.id
    key_name = "my_key"
    vpc_security_group_ids = [ aws_security_group.MyPubSecGrp.id ]

    tags = {
      Name = "private_${var.env_name}_ec2"
    }
}

resource "aws_security_group" "MyPubSecGrp" {
    name = "MyPublicSecGrp"
    vpc_id = aws_vpc.MyTestVpc.id

    ingress {
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "-1"
    }

    egress {
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "-1"
    }
  
}


resource "aws_instance" "MyPublicInstance" {
   instance_type = var.instance_type
   ami = var.ami
   subnet_id = aws_subnet.MyPublicSubnet.id
   key_name = "my_key"
   vpc_security_group_ids = [ aws_security_group.MyPubSecGrp.id ]

   tags = {
     Name = "public_${var.env_name}_ec2"
   }
}

