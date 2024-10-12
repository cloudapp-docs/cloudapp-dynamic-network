#######################################
############# 1、网络和安全组 ##############
#######################################
resource "tencentcloud_vpc" "main" {
  name              = "${var.app_name}_vpc"
  availability_zone = var.network_source == "exist" ? var.app_network_vpc.availability_zone : var.app_zone.zone
  cidr_block        = var.vpc_cidr_block
  dns_servers       = ["183.60.82.98", "183.60.83.19"]
  is_multicast      = "false"
  count             = var.network_source == "exist" ? 0 : 1
}
resource "tencentcloud_subnet" "main" {
  name              = "${var.app_name}_subnet"
  availability_zone = var.network_source == "exist" ? var.app_network_vpc.availability_zone : var.app_zone.zone
  cidr_block        = var.subnet_cidr_block
  is_multicast      = "false"
  vpc_id            = tencentcloud_vpc.main.id
  count             = var.network_source == "exist" ? 0 : 1
}

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


########################################
########## 2、生成云资源需要的密码 #############
########################################
resource "random_password" "password_for_db" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

resource "random_password" "password_for_cvm" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

########################################
############### 3、声明 MySQL ##############
########################################
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

########################################
########## 4、声明容器服务 TKE #############
########################################
resource "tencentcloud_kubernetes_cluster" "tke-cluster" {
  availability_zone   = var.network_source == "exist" ? var.app_network_vpc.availability_zone : var.app_zone.zone
  vpc_id              = var.network_source == "exist" ? var.app_network_vpc.vpc.id : tencentcloud_vpc.main.id
  subnet_ids          = [var.network_source == "exist" ? var.app_network_vpc.subnet.id : tencentcloud_subnet.main.id]
  cluster_cidr        = var.cluster_cidr
  cluster_os          = "tlinux2.4(tkernel4)x86_64"
  cluster_os_type     = "GENERAL"
  cluster_ipvs        = true
  cluster_deploy_type = "MANAGED_CLUSTER"
  network_type        = "GR"
  container_runtime   = "containerd"

  # 后续按规模计算
  cluster_level           = "L20"
  cluster_max_pod_num     = 64
  cluster_max_service_num = 1024

  worker_config {
    password                                = random_password.password_for_cvm.result
    availability_zone                       = var.network_source == "exist" ? var.app_network_vpc.availability_zone : var.app_zone.zone
    subnet_id                               = var.network_source == "exist" ? var.app_network_vpc.subnet.id : tencentcloud_subnet.main.id
    img_id                                  = var.app_cvm_image.image_id
    instance_type                           = var.app_cvm.instance_type
    public_ip_assigned                      = false
    internet_max_bandwidth_out              = 0
    security_group_ids                      = [var.network_source == "exist" ? var.app_network_vpc.subnet.id : tencentcloud_subnet.main.id]
    cam_role_name                           = var.cloudapp_cam_role
    instance_charge_type                    = var.charge_type == "PREPAID" ? "PREPAID" : "POSTPAID_BY_HOUR"
    instance_charge_type_prepaid_period     = var.charge_perpaid_period
    instance_charge_type_prepaid_renew_flag = var.charge_perpaid_auto_renew == true ? "NOTIFY_AND_AUTO_RENEW" : "NOTIFY_AND_MANUAL_RENEW"

    count = 1

    system_disk_type = "CLOUD_BSSD"
    system_disk_size = 50
  }
}


########################################
####### 5、helm chart 编排的容器应用 ##########
########################################
resource "cloudapp_helm_app" "app" {
  cluster_id     = tencentcloud_kubernetes_cluster.tke-cluster.id
  chart_src      = "../software/chart"
  chart_username = var.cloudapp_repo_username
  chart_password = var.cloudapp_repo_password
  chart_values = {
    name                   = var.app_name
    cloudappTargetSubnetID = var.network_source == "exist" ? var.app_network_vpc.subnet.id : tencentcloud_subnet.main.id

    cloudappImageCredentials = {
      registry = var.cloudapp_repo_server
      username = var.cloudapp_repo_username
      password = var.cloudapp_repo_password
    }
    mysql = {
      host     = tencentcloud_mysql_instance.mysql.intranet_ip
      port     = tencentcloud_mysql_instance.mysql.intranet_port
      user     = "root"
      password = tencentcloud_mysql_instance.mysql.root_password
    }
    cam_role_name = var.cloudapp_cam_role
  }
}