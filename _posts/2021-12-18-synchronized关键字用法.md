---
layout: post
date: 2021-12-18 23:03:25 +0800
author: solitaryclown
categories: java 
tags: java 线程安全 临界区
permalink: /:categories/:title.html
excerpt: "synchronized关键字的用法和原理"
---

* content
{:toc}

# synchronized关键字

用synchronized修饰的代码块或者方法，代表里面的代码具有原子性，不可分割。

对于普通方法，当线程执行时，获取对应的锁—（this）。

```java
    public synchronized void increase() {
            count++;
    }
    //等效于下面的代码
/*

    public void increase() {
        synchronized (this) {
            count++;
        }
    }
*/
```

对于static方法，获取的锁为类.class

```java
static synchronized void method(){
    do something...
}
等效于
static  void method(){
    synchronized(当前类.class){
   		 do something...
    }
}

```

