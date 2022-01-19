---
layout: post
date: 2022-01-04 12:29:56 +0800
author: solitaryclown
title: ConcurrentLinkedQueue和LinkedBlockingQueue的区别
categories: java
tags: CAS 阻塞队列
# permalink: /:categories/:title.html
excerpt: "ConcurrentLinkedQueue和LinkedBlockingQueue的区别"
---
* content
{:toc}


## 区别
ConcurrentLinkedQueue和LinkedBlockingQueue的主要区别在于：  
LinkedBlockingQueue使用了两个ReentrantLock锁来分别对take和put进行同步控制。  
而ConcurrentLinkedQueue是无锁并发，没有使用synchronized或者juc里面的Lock，基于CAS操作。

[![Tqb0dP.md.png](https://s4.ax1x.com/2022/01/04/Tqb0dP.md.png)](https://imgtu.com/i/Tqb0dP)
[![TqbwZt.md.png](https://s4.ax1x.com/2022/01/04/TqbwZt.md.png)](https://imgtu.com/i/TqbwZt)


## 应用
ConcurrentLinkedQueue应用：
+ tomcat，Acceptor向Poller传递消息使用了ConcurrentLinedQueue