---
layout: post
date: 2021-12-20 15:00:34 +0800
author: solitaryclown
categories: java
tags: 锁 多线程
# permalink: /:categories/:title.html
excerpt: "ReentrantLock的介绍和使用"
---
* content
{:toc}

# ReentrantLock
## 特点
ReentrantLock具备`synchronized`没有的特性：
1. 可中断
2. 可以设置加锁超时时间
3. 可以设置公平锁策略
4. 支持多个条件变量(多个waitSet)
ReentrantLock和`synchronized`一样，都支持**可重入**
>可重入：即线程已经获取了一个对象的锁，仍然可以继续获得该对象的锁。

## 使用方法

```java
    reentrantLock.lock();
    try{
        doSomething...
    }catch(){
        reentrantLock.unlock();
    }
```