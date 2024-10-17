resource "aws_instance" "yolo5" {
  count = 2  
  ami = "ami-08eb150f611ca277f"
  instance_type = var.instance_type
  key_name = var.key_name

  subnet_id                   = var.subnet_id[count.index % length(var.subnet_id)]
  vpc_security_group_ids      = [aws_security_group.yolo5-sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "yolo5"
  }
}

resource "aws_security_group" "yolo5-sg" {
  name        = "yolo5-sg"  
  description = "Allow SSH and HTTP traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }  

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}
#------------------------------------------------------------------------
# AWS
resource "aws_placement_group" "yolo5-pg" {
  name     = "test"
  strategy = "spread"
}

resource "aws_launch_template" "yolo5-template" {
  name          = "yolo5-launch-templete"
  image_id      = "ami-0c55b159cbfafe1f0"  # Replace with your AMI ID
  instance_type = "t2.micro"
  key_name      = "my-key-pair"
  iam_instance_profile {
    name = aws_iam_instance_profile.profile-yolo5.name
  }
}       

resource "aws_autoscaling_group" "yolo5-asg" {
  launch_template {
    id      = aws_launch_template.yolo5-template.id
    version = "$Latest"  
  }
  name                      = "yolo5-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  force_delete              = true
  placement_group           = aws_placement_group.yolo5-pg.id
  vpc_zone_identifier       = var.subnet_id

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }
}

#-----------------------------------------------------------------------------------
# IAM policy and IAM role being created

resource "aws_iam_role" "yolo5-role" {
  name = "yolo5-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"  
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "yolo5-policy" {
  name        = "yolo5-policy"
  description = "Policy to allow access to DynamoDB, S3, SQS, and Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:UpdateItem"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "sqs:*"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_yolo5-policy" {
  role       = aws_iam_role.yolo5-role.name
  policy_arn = aws_iam_policy.yolo5-policy.arn
}