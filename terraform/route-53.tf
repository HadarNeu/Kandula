#####A record for Jenkins Server########
resource "aws_route53_record" "jenkins-dns" {
  zone_id = data.aws_route53_zone.hosted-zone-hadar.zone_id
  name    = var.jenkins-ui-url
  type    = "A"

  alias {
    name                   = aws_lb.jenkins_alb.dns_name
    zone_id                = aws_lb.jenkins_alb.zone_id
    evaluate_target_health = true
  }
}