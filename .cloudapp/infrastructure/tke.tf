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
