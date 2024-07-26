# 声明一个 Helm 容器编排，指定编排到的容器集群在 eks.tf 中声明了

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