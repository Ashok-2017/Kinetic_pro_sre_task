data "aws_iam_policy_document" "iam_policy" {
  policy_id = "policy-for-${var.origin_name}"

  statement {
    sid       = "2"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.origin_name}.com/*"]

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

