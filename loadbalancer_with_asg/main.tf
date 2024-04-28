provider "aws" {
   region = "eu-west-1"
}



resource "aws_security_group" "MyAsgSecGrp" {
    ingress {
        from_port = "0"
        to_port = "0"
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "tcp"
    }

    egress {
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
        protocol = "-1"
    }
    tags = {
      Name = "MySecGrpAsg"
    }
}


data "aws_vpc" "default" {
   default = true
}

data "aws_subnets" "default" {

    filter {
      name = "vpc-id"
      values = [ data.aws_vpc.default.id ]
    }
  
}

resource "aws_launch_configuration" "MyAsgLaunchConfiguration" {
    image_id = "ami-0d421d84814b7d51c"
    instance_type = "t2.micro"
    security_groups = [ aws_security_group.MyAsgSecGrp.id ]

    name = "MyAsgLaunchConfiguration"

    user_data = <<-EOF
        #!/bin/bash
        sudo yum update busybox
        echo "Hello world" > index.html
        sudo nohup busybox httpd -f -p ${var.allowed_port} &
    EOF

    lifecycle {
      create_before_destroy = true
    }
}


resource "aws_lb_target_group" "appTargetGrp" {
   name = "webTargetGrp"
   port = var.allowed_port
   protocol = "HTTP"
   vpc_id = data.aws_vpc.default.id

   health_check {
     path = "/"
     protocol = "HTTP"
     matcher = "200"
     interval = 15
     timeout = 3
     healthy_threshold = 2
     unhealthy_threshold = 2
   }
}

resource "aws_autoscaling_group" "MyAutoScalingGrp" {
   min_size = 2
   max_size = 5
   launch_configuration = aws_launch_configuration.MyAsgLaunchConfiguration.name
   vpc_zone_identifier = data.aws_subnets.default.ids
   target_group_arns = [ aws_lb_target_group.appTargetGrp.arn ]
   health_check_type = "ELB"

   tag  {
     key = "Name"
     value = "Asg"
     propagate_at_launch = true
   }
   depends_on = [ aws_launch_configuration.MyAsgLaunchConfiguration ]
}


resource "aws_lb_listener" "appLbListener" {
    load_balancer_arn = aws_lb.appLB.arn
    port = 80
    protocol = "HTTP"
    default_action {
      type = "fixed-response"
      fixed_response {
        content_type = "text/plain"
        message_body = "Default text returned by the load_balancer"
        status_code = 404
      }
    }
}

resource "aws_security_group" "secGrpWeb" {
   name = "MySecGrp"
   
   ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }

}


resource "aws_lb_listener_rule" "appLbListener" {
   listener_arn = aws_lb_listener.appLbListener.arn
   priority = 100

   action {
     type = "forward"
     target_group_arn = aws_lb_target_group.appTargetGrp.arn
   }

   condition {
     path_pattern {
       values = ["*"]
     }
   }
}

resource "aws_lb" "appLB" {
   name = "web-load-balancer"
   load_balancer_type = "application"
   subnets = data.aws_subnets.default.ids
   security_groups = [ aws_security_group.secGrpWeb.id ]
   
}

