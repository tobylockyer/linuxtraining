output "public_dns" {
    value = "${aws_instance.linux.public_dns}"
}
