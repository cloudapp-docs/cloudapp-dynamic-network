resource "tencentcloud_security_group" "sg" {
  name        = "${var.app_name}_security_group"
  description = "cloudapp"
  count       = var.network_source == "exist" ? 0 : 1
}
resource "tencentcloud_security_group_rule" "ingress" {
  security_group_id = tencentcloud_security_group.sg.id
  type              = "ingress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "ACCEPT"
  description       = "ingress all"
  count             = var.network_source == "exist" ? 0 : 1
}

resource "tencentcloud_security_group_rule" "egress" {
  security_group_id = tencentcloud_security_group.sg.id
  type              = "egress"
  cidr_ip           = "0.0.0.0/0"
  ip_protocol       = "ALL"
  policy            = "ACCEPT"
  description       = "egress all"
  count             = var.network_source == "exist" ? 0 : 1
}
