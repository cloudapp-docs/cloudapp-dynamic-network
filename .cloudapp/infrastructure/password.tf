# 这里定义用到的密码

resource "random_password" "password_for_db" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}

resource "random_password" "password_for_cvm" {
  length           = 16
  override_special = "_+-&=!@#$%^*()"
}