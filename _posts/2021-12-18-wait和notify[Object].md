---
layout: post
date: 2021-12-18 23:33:54 +0800
author: solitaryclown
categories: java
tags: 多线程
permalink: /:categories/:title.html
excerpt: "wait/notify方法的理解以及wait和sleep的区别"
---
* content
{:toc}


# wait(),notify(),notifyAll()
* `obj.wait()`：让进入object监视器的线程到waitSet
* `obj.notify()`：~~从obj关联的监视器的waitSet中挑一个线程唤醒~~，首先，锁对象关联的waitSet是一个队列，既然是队列，必然遵守先进先出的规则，所以`notify()`实际上是将waitSet头部元素（线程）出队并加入到entryList等待，但entryList中的线程去竞争锁是随机的，最终导致从waitSet中先出来的线程不一定先拿到锁，我们就会看到线程的执行顺序是随机的。
* `obj.notifyAll()`：唤醒waitSet中所有的线程

只有获得了锁才能调用这些方法，换言之，只有锁对象关联的monitor的owner才能调用。



## wait(long n)和sleep(long n)区别和共同点
### 区别
1. sleep是Thread类的方法，wait()是Object类的方法
2. sleep不需要在synchronized方法/代码块内部使用
3. 线程调用sleep，如果已经获得锁不会释放会继续持有，而线程调用wait()则会进入waitSet并释放锁给其他线程竞争。

### 共同点
 线程调用`sleep(long n)`和调用`wait(long n)`后的状态都是TIMED_WAITING。

