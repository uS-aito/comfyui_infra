resource "aws_s3_bucket" "output" {
  bucket = "output-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "output" {
  bucket = aws_s3_bucket.output.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_public_access_block" "output" {
  bucket                  = aws_s3_bucket.output.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_control" "output" {
  name                              = "output-${data.aws_caller_identity.current.account_id}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "output" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.output.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.output.id
    origin_access_control_id = aws_cloudfront_origin_access_control.output.id
  }

  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.output.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "output_bucket_policy" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.output.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.output.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "output" {
  bucket = aws_s3_bucket.output.id
  policy = data.aws_iam_policy_document.output_bucket_policy.json
}
