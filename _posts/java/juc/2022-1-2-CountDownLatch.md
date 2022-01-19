---
layout: post
date: 2022-01-02 17:27:03 +0800
author: solitaryclown
title: CountdownLatch
categories: java
tags: AQS
# permalink: /:categories/:title.html
excerpt: "CountdownLatch的使用"
---
* content
{:toc}

# CountdownLatch
countdown，倒计时;latch，锁.
CountdownLatch，倒计时锁。
## 结构
[![TTdP81.png](https://s4.ax1x.com/2022/01/02/TTdP81.png)](https://imgtu.com/i/TTdP81)
## 使用
使用构造方法直接构造对象，参数为线程数量。

CountDownLatch允许一个或多个线程等待直到一组线程结束。

+ `await()`：当前线程进入等待直到latch减到0；如果被中断会停止await()并抛出异常(interrupt会打断park)。
+ `countDown()`：state--，是CAS操作。


### CountDownLatch和join()比较
+ join()必须等待线程结束，等待的线程才能继续运行
+ CountDownLatch只要计数减到0就会唤醒等待的线程
线程池中的线程执行完任务不会马上结束，在这种场景下join()不适用，而CountDownLatch适用。

### 例子

```java
package com.huangbei.test2;

import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.CountDownLatch;

import static com.huangbei.util.Sleeper.sleep;

@Slf4j(topic = "c.Test-CountdownLatch")
public class Test22 {

    public static void main(String[] args) {
        CountDownLatch latch = new CountDownLatch(3);
        new Thread(() -> {
            try {
                log.debug("开始等待.....");
                latch.await();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            log.debug("恢复运行");
        },"等待线程").start();

        sleep(0.5);
        for (int i = 0; i < 10; i++) {
            new Thread(() -> {
                log.debug("执行任务...");
                latch.countDown();
            }).start();
            sleep(1);
        }


    }
}

```
### 结果

```
17:25:37.297 [等待线程] c.Test-CountdownLatch - 开始等待.....
17:25:37.797 [Thread-0] c.Test-CountdownLatch - 执行任务...
17:25:38.804 [Thread-1] c.Test-CountdownLatch - 执行任务...
17:25:39.818 [Thread-2] c.Test-CountdownLatch - 执行任务...
17:25:39.819 [等待线程] c.Test-CountdownLatch - 恢复运行
17:25:40.829 [Thread-3] c.Test-CountdownLatch - 执行任务...
17:25:41.838 [Thread-4] c.Test-CountdownLatch - 执行任务...
17:25:42.844 [Thread-5] c.Test-CountdownLatch - 执行任务...
17:25:43.845 [Thread-6] c.Test-CountdownLatch - 执行任务...
17:25:44.847 [Thread-7] c.Test-CountdownLatch - 执行任务...
17:25:45.856 [Thread-8] c.Test-CountdownLatch - 执行任务...
17:25:46.861 [Thread-9] c.Test-CountdownLatch - 执行任务...

Process finished with exit code 0
```

