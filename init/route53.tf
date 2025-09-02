#resource "aws_route53_zone" "private" {
#  name = "internal-kz-li.sbx.hashidemos.io"
#
#  vpc {
#    vpc_id = aws_vpc.my_vpc.id
#  }
#}

#data "aws_route53_zone" "public" {
#  name = "kz-li.sbx.hashidemos.io"
#}
#
#resource "aws_route53_record" "boundary" {
#  zone_id = data.aws_route53_zone.public.zone_id
#  name    = "boundary.${data.aws_route53_zone.public.name}"
#  type    = "A"
#  ttl     = 300
#  records = [aws_eip.my_public_ip.public_ip]
#}