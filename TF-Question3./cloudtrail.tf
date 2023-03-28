data "aws_caller_identity" "current" {}

resource "aws_cloudtrail" "cloudtrail_log" {
  name                          = "tf-trail-${var.app_name}"
  s3_bucket_name                = aws_s3_bucket.s3-cloudtrail.id
  s3_key_prefix                 = "prefix"
  include_global_service_events = true
}

resource "aws_s3_bucket" "s3-cloudtrail" {
  bucket        = "tf-${var.app_name}-${var.app_environment}-trail"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3-cloudtrail" {
  bucket = aws_s3_bucket.s3-cloudtrail.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::tf-${var.app_name}-${var.app_environment}-trail"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::tf-${var.app_name}-${var.app_environment}-trail/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}