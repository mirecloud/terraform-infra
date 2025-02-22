# 🪣 1️⃣ Créer un bucket S3
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-cloudfront-secure-bucket"
}

# Upload individual files
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

# Output the bucket name
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

# 2️⃣ Activer le contrôle des accès publics pour bloquer l'accès direct S3
resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3️⃣ Créer une politique S3 pour autoriser CloudFront (OAC)
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipalReadOnly",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::my-cloudfront-secure-bucket/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "${aws_cloudfront_distribution.my_distribution.arn}"
                }
            }
        }
    ]
}
POLICY
}

# 🔐 4️⃣ Créer un Origin Access Control (OAC) pour CloudFront
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "MyOAC"
  description                       = "OAC for CloudFront to access S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 🌍 5️⃣ Créer une distribution CloudFront
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

# 🔎 6️⃣ Afficher l'URL CloudFront après le déploiement
output "cloudfront_url" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
  description = "URL CloudFront pour accéder aux fichiers S3"
}
