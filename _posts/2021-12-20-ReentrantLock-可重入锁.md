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
4. 支持多个条件变量(可以理解为多个waitSet)
ReentrantLock和`synchronized`一样，都支持**可重入**
>可重入：即线程已经获取了一个对象的锁，仍然可以继续获得该对象的锁。

## 使用方法

```java
reentrantLock.lock();
try{
    doSomething...
}finally{
    reentrantLock.unlock();
}
```

### 重入
```java
package com.huangbei.test;

import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.locks.ReentrantLock;

/*
可重入锁的可重入性
 */
@Slf4j(topic = "c.Test-ReentrantLock")
public class Test30 {
    final static ReentrantLock lock=new ReentrantLock();
    public static void main(String[] args) {

        lock.lock();
        try {
            log.debug("in main...");
            m1();
        }finally{
            lock.unlock();
        }

    }
   static private void m1(){
        lock.lock();
        try {
            log.debug("in method1...");
        }finally{
            lock.unlock();
        }
    }
}
```

结果：
```
16:52:20.749 [main] c.Test-ReentrantLock - in main...
16:52:20.753 [main] c.Test-ReentrantLock - in method1...
```

### 中断加锁阻塞
线程调用`reentrantLock.lockInterruptibly()`，会尝试竞争锁，如果竞争不到则进入entryList等待，而其他线程可以调用`interrupt()`，这时`lockInterruptibly()`会抛出`java.lang.InterruptedException`，此时线程也停止了获取锁的操作（加锁失败），继续向后执行。

```java
package com.huangbei.test;

import com.huangbei.util.Sleeper;
import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.locks.ReentrantLock;

/*
可重入锁的可打断性
 */
@Slf4j(topic = "c.Test-ReentrantLock")
public class Test31 {
    final static ReentrantLock lock=new ReentrantLock();
    public static void main(String[] args) {
        //新建一个线程t1，加锁时使用可打断锁方法
        Thread t1 = new Thread(() -> {
            try {
                log.debug("尝试获取锁");
                lock.lockInterruptibly();
            } catch (InterruptedException e) {
                log.debug("此线程在等待锁，但被打断.");
                e.printStackTrace();
                return;
            }
            try {
                log.debug("拿到锁了.");
            }finally {
                lock.unlock();
            }
        }, "t1");

        //主线程先获取lock锁，t1启动时拿不到锁
        lock.lock();
        t1.start();
        Sleeper.sleep(1);
        t1.interrupt();
    }

}
```

### 限时获取锁
`boolean tryLock(long timeout, TimeUnit unit)`:在timeout的时间内如果获得锁，返回true，否则返回false。如果tryLock()不带参数，线程会尝试获得锁，如果获取不到，直接返回false不会等待获取锁。

```java
package com.huangbei.test;

import com.huangbei.util.Sleeper;
import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

/*
可重入锁的限时获取锁
 */
@Slf4j(topic = "c.Test-ReentrantLock-tryLock")
public class Test32 {
    final static ReentrantLock lock=new ReentrantLock();
    public static void main(String[] args) {
        //新建一个线程t1，使用tryLock()尝试获得锁
        //主线程先对lock加锁，观察tryLock返回值
        Thread t1 = new Thread(() -> {

            try {
                if (!lock.tryLock(2, TimeUnit.SECONDS)) {
                    log.debug("获取锁失败.");
                    return;
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            try {
                log.debug("拿到锁了.");
            }finally {
                lock.unlock();
            }

        }, "t1");

        log.debug("拿到锁了.");
        lock.lock();
        t1.start();
        Sleeper.sleep(3);
        log.debug("释放了锁.");
        lock.unlock();
    }
}

```

#### 使用tryLock()解决哲学家就餐死锁问题
[哲学家就餐问题](/2021/12/19/线程活跃性分析/#哲学家就餐问题dining-philosopher-problem)

```java
@Override
public void run() {
    while (true) {
        /*synchronized (left) {
            synchronized (right) {
                eat();
            }
        }*/
        //Chopstick继承ReentrantLock
        if(left.tryLock()){
            try{
                if(right.tryLock()){
                    try {
                        eat();
                    }finally {
                        right.unlock();
                    }
                }
            }finally {
                left.unlock();
            }
        }
    }
}   
```

### 公平策略
`new ReentrantLock(boolean fair)`：fair为`true`时使用公平策略，在entryList里面的线程，先进入的先获得锁。

**注意**：使用公平策略会降低并发度。

### 多个条件变量
`Condition condition=reentrantLock.newCondition()`
Condition是一个接口，`newCondition()`返回的是它的一个实现：`ConditionObject`，对象condition可以调用`await()`、`signal()`、`signalAll()`来让线程等待、唤醒、唤醒所有等待线程，但对这些线程的操作都是绑定在这个ConditionObject对象上的，多个condition的操作互不干扰。

condition的使用和`wait()`、`notify()`是差不多的：
+ `await()`：让当前线程进入当前condition的等待区，当前对象释放锁。
+ `signal()`：唤醒当前condition对象等等待区的一个线程
+ `signalAll()`：唤醒……所有……

#### 例子
```java
package com.huangbei.test;

import com.huangbei.util.Sleeper;
import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.ReentrantLock;

@Slf4j(topic = "c.Test-Condition")
public class Test35 {
    static boolean c1;
    static boolean c2;

    static ReentrantLock lock = new ReentrantLock();
    static Condition condition1 = lock.newCondition();
    static Condition condition2 = lock.newCondition();

    public static void main(String[] args) {

        Thread t1 = new Thread(() -> {
            try {
                lock.lock();
                while (!c1) {
                    log.debug("我需要等打印机才能继续工作");
                    condition1.await();
                }
                log.debug("我可以继续工作了！");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }

        }, "等待者A");
        Thread t2 = new Thread(() -> {
            try {
                lock.lock();
                while (!c2) {
                    log.debug("我需要等扫描仪才能继续工作");
                    condition2.await();
                }
                log.debug("我可以继续工作了！");
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }

        }, "等待者B");


        t1.start();
        t2.start();

        Sleeper.sleep(1);
        new Thread(()->{
            try {
                lock.lock();
                c1=true;
                condition1.signal();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }

        }).start();
        new Thread(()->{
            try {
                lock.lock();
                c2=true;
                condition2.signal();
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                lock.unlock();

            }

        }).start();
    }
}

```