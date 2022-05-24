---
layout: post
date: 2021-12-19 12:21:43 +0800
author: solitaryclown   
categories: java
tags: 多线程
# permalink: /:categories/:title.html
excerpt: "juc包下的LockSupport类提供的方法"
---
* content
{:toc}


# 1. park&unpark
## 1.1. 基本使用
* `LockSupport.park()`：暂停当前线程的执行(线程状态变成WAITING)
* `LockSupport.unpark(Thread t)`：如果线程t在暂停，让线程继续执行，否则当下一次线程t调用park()时，线程t不会暂停。

## 1.2. 测试

### 1.2.1. unpark在park之后执行
#### 1.2.1.1. 测试类
```java
@Slf4j(topic = "c.Test-park&unpark")
public class Test26 {
    public static void main(String[] args) {
        //创建一个线程t1，休眠1s后调用park方法
        Thread t1 = new Thread(() -> {
            log.debug("开始.");
            Sleeper.sleep(1);
            log.debug("暂停.");
            LockSupport.park();
            log.debug("继续执行.");

        }, "t1");
        t1.start();
        //主线程休眠2s，然后调用unpark(t1)
        Sleeper.sleep(2);
        log.debug("恢复t1执行.");
        LockSupport.unpark(t1);
    }
}
```
#### 1.2.1.2. 测试结果
    12:36:30.232 [t1] c.Test-park&unpark - 开始.
    12:36:31.250 [t1] c.Test-park&unpark - 暂停.
    12:36:32.224 [main] c.Test-park&unpark - 恢复t1执行.
    12:36:32.224 [t1] c.Test-park&unpark - 继续执行.

### 1.2.2. 2.unpark在park之前执行
#### 1.2.2.1. 测试类
```java
@Slf4j(topic = "c.Test-park&unpark")
public class Test26 {
    public static void main(String[] args) {
        //创建一个线程t1，休眠1s后调用park方法
        Thread t1 = new Thread(() -> {
            log.debug("开始.");
            Sleeper.sleep(2);
            log.debug("暂停.");
            LockSupport.park();
            log.debug("继续执行.");

        }, "t1");
        t1.start();
        //主线程休眠2s，然后调用unpark(t1)
        Sleeper.sleep(1);
        log.debug("恢复t1执行.");
        LockSupport.unpark(t1);
    }
}

```
#### 1.2.2.2. 测试结果
    13:00:58.253 [t1] c.Test-park&unpark - 开始.
    13:00:59.266 [main] c.Test-park&unpark - 恢复t1执行.
    13:01:00.269 [t1] c.Test-park&unpark - 暂停.
    13:01:00.269 [t1] c.Test-park&unpark - 继续执行.


## 1.3. 与wait-notify-notifyAll的不同
* `wait`和`notify`的调用者是锁对象关联的monitor的owner，所以线程必须获得锁对象才能调用，即必须在synchronized代码块内部调用，而park()和unpark()不需要。
* `park`和`unpark`以线程为单位暂停和唤醒，精确度高。线程调用`wait()`后，`notify()`会随机通知waitSet中的一个线程，而`notifyAll()`会通知waitSet中的所有线程。
* `unpark`可以在`park`之前调用，会让下一次调用`park`时线程继续执行，`notify`和`notifyAll`在`wait`之前调用，下一次`wait`依然会让线程进入waitSet。
  