# Creating a S3 bucket for storing the processe records
resource "aws_s3_bucket" "kinesis_s3_bucket" {
  bucket = "madmax-kinesis"
  force_destroy = true
}

# Creating kinesis data stream service
resource "aws_kinesis_stream" "kinesis_stream" {
  name        = "kinesis_stream"
  shard_count = 1
}

# IAM Role for Firehose
resource "aws_iam_role" "firehose_role" {
  name = "firehose_delivery_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "firehose_policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.kinesis_s3_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:DescribeStream",
          "kinesis:GetShardIterator",
          "kinesis:GetRecords",
          "kinesis:ListStreams"
        ]
        Resource = "${aws_kinesis_stream.kinesis_stream.arn}"
      },
      {
        Effect   = "Allow"
        Action   = "logs:*"
        Resource = "*"
      }
    ]
  })
}

# Kinesis Firehose configuration
resource "aws_kinesis_firehose_delivery_stream" "firehose_to_s3" {
  name        = "example-firehose-to-s3"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.kinesis_s3_bucket.arn
    buffering_size     = 5
    buffering_interval = 300
    compression_format = "GZIP"
  }

  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.kinesis_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }
}
