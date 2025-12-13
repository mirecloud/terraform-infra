
output "bucket_name" {
  value = aws_s3_bucket.first_bucket.bucket
}

output "vpc_id" {
  value = aws_vpc.first_mirecloud_vpc.id
}

output "instance_id" {
  value = aws_instance.first_instance.id
}
