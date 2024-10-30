cloudapp-dynamic-network
==========

> 包含云资源：VPC、安全组、TKE

这是一个动态创建网络和安全组的示例应用，可以在安装应用的时候指定使用现有网络或者创建新的网络环境

## 使用说明

- 你需要修改 ```package.yaml``` 中的 ```id``` 为自己的云应用 ID
- 根据实际修改 `infrastructure/variable.tf` 中的变量，也可以在安装参数中定义，使用用户输入的内容
- 将 `software/chart` 中的 chart 应用替换成自己的 helm chart，或者在原有应用上修改


参考文档：

- [资源类型手册](https://cloud.tencent.com/document/product/1689/90938)
- [腾讯云云应用简介](https://cloud.tencent.com/document/product/1689/87047)
