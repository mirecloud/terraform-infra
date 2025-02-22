# 🌍 Déploiement d'un site statique sur AWS avec Terraform

Ce projet Terraform permet de déployer un site statique sur AWS en utilisant S3 et CloudFront avec des permissions sécurisées.

## 🚀 Fonctionnalités
- Création d'un bucket S3 sécurisé
- Upload des fichiers statiques (`index.html`, `index.css`, `logo.png`)
- Blocage des accès publics directs au bucket S3
- Configuration d'un Origin Access Control (OAC) pour CloudFront
- Création d'une distribution CloudFront

---

## 🛠️ Déploiement avec Terraform
### 1️⃣ Créer un bucket S3
```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-cloudfront-secure-bucket"
}
```

### 2️⃣ Upload des fichiers statiques
```hcl
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.my_bucket.id
  key          = "index.html"
  source       = "./mirecloud-code/index.html"
  etag         = filemd5("./mirecloud-code/index.html")
  content_type = "text/html"
}
```
*(Répété pour `index.css` et `logo.png`)*

### 3️⃣ Bloquer l'accès public direct à S3
```hcl
resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  bucket = aws_s3_bucket.my_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 4️⃣ Ajouter une politique S3 pour CloudFront
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

### 5️⃣ Configurer un Origin Access Control (OAC) pour CloudFront
```hcl
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "MyOAC"
  description                       = "OAC for CloudFront to access S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```

### 6️⃣ Déployer une distribution CloudFront
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

### 7️⃣ Afficher l'URL CloudFront après le déploiement
```hcl
output "cloudfront_url" {
  value = aws_cloudfront_distribution.my_distribution.domain_name
  description = "URL CloudFront pour accéder aux fichiers S3"
}
```

---

## 📌 Instructions d'utilisation
1. **Initialiser Terraform**
   ```bash
   terraform init
   ```
2. **Planifier le déploiement**
   ```bash
   terraform plan
   ```
3. **Appliquer les changements**
   ```bash
   terraform apply
   ```
4. **Obtenir l'URL CloudFront**
   ```bash
   terraform output cloudfront_url
   ```
5. **Accéder au site statique via l'URL affichée**

---

## 📜 Notes
- **S3 est privé** et uniquement accessible via CloudFront.
- **CloudFront assure une distribution rapide et sécurisée des fichiers.**
- **Les fichiers statiques doivent être stockés dans le dossier `mirecloud-code`.**


🎉 **Votre site statique est maintenant accessible via CloudFront !** 🚀

