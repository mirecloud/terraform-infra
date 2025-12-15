
locals {
  env           = var.environment
  bucket_name   = "${var.channel}-bucket-${var.environment}-${var.region}"
  vpc_name      = "${var.channel}-vpc-${var.environment}-${var.region}"
  instance_name = "${var.channel}-instance-${var.environment}-${var.region}"

}
