resource "aws_flow_log" "flow-log" {
  iam_role_arn    = aws_iam_role.flow-log.arn
  log_destination = aws_cloudwatch_log_group.flow-log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.Application-Plane-VPC.id
}

resource "aws_cloudwatch_log_group" "flow-log" {
  name = "flow-log"
}

resource "aws_iam_role" "flow-log" {
  name = "flow-log"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "flow-log" {
  name = "flow-log"
  role = aws_iam_role.flow-log.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}