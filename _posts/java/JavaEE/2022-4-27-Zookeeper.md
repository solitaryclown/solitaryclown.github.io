---
layout: post
date: 2022-04-27 14:09:14 +0800
author: solitaryclown
title: Zookeeper
categories: 
tags: 
# permalink: /:categories/:title.html
excerpt: "Zookeeper的介绍和使用"
---
* content
{:toc}


# 1. Zookeeper
## 1.1. 介绍
Zookeeper是Apache软件基金会下的一个顶级项目，是由雅虎公司开发团队开发。
Zookeeper是Apache软件基金会下的一个顶级项目，是由雅虎公司开发团队开发。 是一个面向分布式应用程序的分布式开源协调服务。它公开了一组简单的原语，分布式应用程序可以基于这些原语来实现更高级别的服务，以实现同步、配置维护以及组和命名。众所周知，协调服务很难做好。他们特别容易出错，比如竞争条件和死锁。ZooKeeper 背后的动机是减轻分布式应用程序从零开始实现协调服务的责任

- 开发语言：Java
- 官方文档：<https://zookeeper.apache.org/doc/current/zookeeperOver.html>

Zookeeper提供的服务如下：
- 命名服务
- 配置管理
- 集群管理
- leader选举
- 锁和同步服务
- 高可靠的数据注册


## 1.2. 安装
1. 下载安装包  

   <https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/>
2. 解压  
    tar -zxvf xxx
3. 修改配置  
    进入解压目录/conf，将zoo_sample.cfg重命名为zoo.cfg，并将文件中的dataDir设置为自定义的目录，一般是在解压目录下新建一个data/目录。

4. 启动服务  
    bin/zkServer.sh start

5. 客户端连接  
    bin/zkCli.sh

## 1.3. 使用
zookeeper常用命令教程：
    <https://zookeeper.apache.org/doc/current/zookeeperCLI.html>

### 1.3.1. Java客户端
zookeeper官方提供了一套zookeeper Java客户端API，但不好用，netflix开发了一套客户端Curator，现在是Apache的一个顶级项目，推荐使用。

**在使用Curator时注意和zookeeper server的版本兼容问题。**

##### 1.3.1.0.1. 遇到的问题
在使用Curator连接Zookeeper服务器时，发现每次都要10s左右，这个时间是很长的，经过debug，发现耗时的代码在org.apache.curator.HandleHolder.closeAndReset()这个方法中：
```java
 void closeAndReset() throws Exception
    {
        internalClose();

        // first helper is synchronized when getZooKeeper is called. Subsequent calls
        // are not synchronized.
        helper = new Helper()
        {
            private volatile ZooKeeper zooKeeperHandle = null;
            private volatile String connectionString = null;

            @Override
            public ZooKeeper getZooKeeper() throws Exception
            {
                synchronized(this)
                {
                    if ( zooKeeperHandle == null )
                    {
                        connectionString = ensembleProvider.getConnectionString();
                        //下面这个方法耗时很久
                        zooKeeperHandle = zookeeperFactory.newZooKeeper(connectionString, sessionTimeout, watcher, canBeReadOnly);
                    }

                    helper = new Helper()
                    {
                        @Override
                        public ZooKeeper getZooKeeper() throws Exception
                        {
                            return zooKeeperHandle;
                        }

                        @Override
                        public String getConnectionString()
                        {
                            return connectionString;
                        }

                        @Override
                        public int getNegotiatedSessionTimeoutMs()
                        {
                            return (zooKeeperHandle != null) ? zooKeeperHandle.getSessionTimeout() : 0;
                        }
                    };

                    return zooKeeperHandle;
                }
            }

            @Override
            public String getConnectionString()
            {
                return connectionString;
            }

            @Override
            public int getNegotiatedSessionTimeoutMs()
            {
                return (zooKeeperHandle != null) ? zooKeeperHandle.getSessionTimeout() : 0;
            }
        };
    }

 
```

解决方法参考：<https://www.cnblogs.com/dehai/p/14258728.html>