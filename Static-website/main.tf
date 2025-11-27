########################
# S3 BUCKET
########################

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-cloudfront-secure-bucket-mirecloud-2025"
}

########################
# S3 OBJECTS
########################

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = "./mirecloud-code/index.html"
  etag         = filemd5("./mirecloud-code/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "index_css" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.css"
  source       = "./mirecloud-code/index.css"
  etag         = filemd5("./mirecloud-code/index.css")
  content_type = "text/css"
}

resource "aws_s3_object" "logo_png" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "logo.png"
  source       = "./mirecloud-code/logo.png"
  etag         = filemd5("./mirecloud-code/logo.png")
  content_type = "image/png"
}

########################
# OUTPUT
########################

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

########################
# BLOCK PUBLIC ACCESS
########################

resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

########################
# ORIGIN ACCESS CONTROL
########################

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "MyOAC"
  description                       = "OAC for CloudFront to access S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

########################
# CLOUD FRONT
########################

resource "aws_cloudfront_distribution" "my_distribution" {

  origin {
    domain_name              = aws_s3_bucket.my_bucket.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "S3Origin"
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

########################
# S3 POLICY FOR CLOUDFRONT
########################

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.my_bucket.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.my_distribution.arn
          }
        }
      }
    ]
  })
}

########################
# OUTPUT CLOUDFRONT URL
########################

output "cloudfront_url" {
  value       = aws_cloudfront_distribution.my_distribution.domain_name
  description = "URL CloudFront pour accéder aux fichiers S3"
}
