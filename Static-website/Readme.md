# 🌍 Deploying a Static Website on AWS with Terraform

This Terraform project allows you to deploy a static website on AWS using S3 and CloudFront with secure permissions.

## 🚀 Features
- Secure S3 bucket creation
- Uploading static files (`index.html`, `index.css`, `logo.png`)
- Blocking direct public access to the S3 bucket
- Configuring an Origin Access Control (OAC) for CloudFront
- Creating a CloudFront distribution

---

## 📌 CloudFront Architecture Diagram
![CloudFront Architecture](cloudfront.drawio.svg)


## 🛠️ Deployment with Terraform
### 1️⃣ Create an S3 Bucket
```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-cloudfront-secure-bucket"
}
```

### 2️⃣ Upload Static Files
```hcl
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = "./mirecloud-code/index.html"
  etag         = filemd5("./mirecloud-code/index.html")
  content_type = "text/html"
}
```
*(Repeated for `index.css` and `logo.png`)*

### 3️⃣ Block Direct Public Access to S3
```hcl
resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 4️⃣ Add an S3 Policy for CloudFront
```hcl
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
```

### 5️⃣ Configure an Origin Access Control (OAC) for CloudFront
```hcl
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "MyOAC"
  description                       = "OAC for CloudFront to access S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```

### 6️⃣ Deploy a CloudFront Distribution
```hcl
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
```

### 7️⃣ Display the CloudFront URL After Deployment
```hcl
output "cloudfront_url" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
  description = "CloudFront URL to access S3 files"
}
```

---

## 📌 Usage Instructions
1. **Initialize Terraform**
   ```bash
   terraform init
   ```
2. **Plan the Deployment**
   ```bash
   terraform plan
   ```
3. **Apply Changes**
   ```bash
   terraform apply
   ```
4. **Get the CloudFront URL**
   ```bash
   terraform output cloudfront_url
   ```
5. **Access the Static Website via the Displayed URL**
   
   🔗 **The website will be accessible at:**
   - S3 Bucket: `my-cloudfront-secure-bucket`
   - CloudFront URL (Example): [EXAMPLE_CLOUDFRONT_URL](https://EXAMPLE_CLOUDFRONT_URL/index.html)

---

## 📜 Notes
- **S3 is private** and only accessible via CloudFront.
- **CloudFront ensures fast and secure distribution of files.**
- **Static files must be stored in the `mirecloud-code` folder.**

