---
layout: post
date: 2022-04-19 12:22:49 +0800
author: solitaryclown
title: RabbitMQ
categories: 
tags: 消息队列
# permalink: /:categories/:title.html
excerpt: ""
---
* content
{:toc}


# 1. RabbitMQ
## 1.1. 安装(CentOS 7)
1. 下载安装包：
    <https://www.aliyundrive.com/s/MqUNrwcKHHW>，或者去官网下载也可以
2. rpm安装
3. 开放远程登录

   在/etc/rabbimq目录下创建rabbitmq.conf文件，写入内容：
   ```conf
   loopback_users = none
   ```

4. 启动服务
   - 前台启动：执行rabbitmq-server
   - 服务方式启动：执行systemctl start rabbitmq-server.service

5. 测试
   
   web管理端默认关闭，将rabbitmq_management插件打开：`rabbitmq-plugins enable rabbitmq_management `
   ，重启服务，测试登录是否成功。
   （默认username和password都是guest，可以通过rabbitmqctl命令修改）
   [![L02stf.png](https://s1.ax1x.com/2022/04/19/L02stf.png)](https://imgtu.com/i/L02stf)