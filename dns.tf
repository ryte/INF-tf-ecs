// data "aws_route53_zone" "zone" {
//   name = "${var.domain}."
// }
//
// resource "aws_route53_record" "record" {
//   alias {
//     evaluate_target_health = false
//     name                   = "${aws_alb.alb.dns_name}"
//     zone_id                = "${aws_alb.alb.zone_id}"
//   }
//
//   name    = "${var.domain}."
//   type    = "A"
//   zone_id = "${data.aws_route53_zone.zone.id}"
// }

