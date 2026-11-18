package main

import rego.v1

deny contains msg if {
    some name, bucket in input.resource.aws_s3_bucket
    not bucket[0].tags.Owner
    msg := sprintf("aws_s3_bucket.%s no té el tag de propietari", [name])
}