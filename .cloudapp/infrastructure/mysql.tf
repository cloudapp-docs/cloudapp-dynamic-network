# 这里声明 mysql 

resource "tencentcloud_mysql_instance" "mysql" {
  availability_zone = var.network_source == "exist" ? var.app_network_vpc.availability_zone : var.app_zone.zone
  vpc_id            = var.network_source == "exist" ? var.app_network_vpc.vpc.id : tencentcloud_vpc.main.id
  subnet_id         = var.network_source == "exist" ? var.app_network_vpc.subnet.id : tencentcloud_subnet.main.id
  cpu               = 4
  mem_size          = 8000
  volume_size       = 150
  instance_name     = "${var.app_name}-mysql"
  engine_version    = "5.7"
  root_password     = random_password.password_for_db.result
  security_groups   = [var.network_source == "exist" ? var.app_network_vpc.subnet.id : tencentcloud_subnet.main.id]
  internet_service  = 1
  slave_deploy_mode = "0"
  slave_sync_mode   = "0"
  intranet_port     = 3306
  charge_type       = var.charge_type
  prepaid_period    = var.charge_perpaid_period
  auto_renew_flag   = var.charge_perpaid_auto_renew == true ? 1 : 0
}
