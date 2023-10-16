resource "aws_s3_bucket" "redirection_bucket" {
  bucket = "${var.origin_name}.com"
  acl = "public-read"
  policy = "${data.aws_iam_policy_document.iam_policy.json}"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
 
  routing_rules = <<EOF
[{
  "Condition": {
    "HttpErrorCodeReturnedEquals": "404"
  },
  "Redirect": {
    "HostName": "${var.destination_url}"
  }
}]
EOF
  }

server_side_encryption_configuration {
  rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

output "bucket_name" {
  value = "${aws_s3_bucket.redirection_bucket.id}"
}
 
