variable "rules" {
  description = "Creation of Ingress SG Rules default"
  default = {
    "ssh"   = [22, 22, "tcp", "secure shell", ["127.0.0.1/32"]]
    "https" = [443, 443, "tcp", "http secured", ["127.0.0.1/32"]]
    "ssh1"   = [22, 22, "tcp", "secure shell", ["12.0.0.1/32"]]
  }
}
variable "sgrules" {
  type = map(any)
  default = {
    sg-0a6c2222209394c4c = ["ssh","https"]
    sg-0a6cd223309394c4c = ["ssh1","https"]
  }
}
locals {
  sgrulesall = flatten([
    for sgname, rules in var.sgrules : [
      for ru in rules : {
        security_group_id = sgname
        sg_rules          = ru
      }
    ]
  ])
}
resource "aws_security_group_rule" "ingress" {
  for_each = {
    for rusg in local.sgrulesall : "${rusg.security_group_id}.${rusg.sg_rules}" => rusg
  }
  security_group_id = each.value.security_group_id
  type              = "ingress"
  from_port         = element(var.rules[each.value.sg_rules], 0)
  to_port           = element(var.rules[each.value.sg_rules], 1)
  protocol          = element(var.rules[each.value.sg_rules], 2)
  description       = element(var.rules[each.value.sg_rules], 3)
  cidr_blocks       = element(var.rules[each.value.sg_rules], 4)
}