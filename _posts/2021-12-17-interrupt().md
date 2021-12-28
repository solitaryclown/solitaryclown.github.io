---
layout: post
date: 2021-12-27 23:01:04 +0800
author: solitaryclown
categories: java
tags: 线程
# permalink: /:categories/:title.html
excerpt: "Thread类的interrupt()方法的使用"
---
* content
{:toc}


# interrupt
对于正常运行的线程t1，调用`t1.interrupt()`只会设置其打断标记为true，不会影响其继续执行。

如果想要线程被调用`interrupt()`后结束，可以通过`isInterrupted()`判断打断标记。
```java
package com.huangbei.test;
/*
interrupt()

 */
import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.FutureTask;

@Slf4j(topic = "c.Test-interrupt")
public class TestInterrupt {


    public static void main(String[] args) {
        Thread t1 = new Thread(() -> {
            log.debug("死循环...");
            while (!Thread.currentThread().isInterrupted()){

            }
            log.debug("线程结束.");
            /*try {
                Thread.sleep(5000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
*/
        },"t1");

        t1.start();
        try {
            Thread.sleep(500);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }

        t1.interrupt();
        log.debug("t1被打断了.");
        log.debug("{}",t1.isInterrupted());

    }
}

```

而对于处于sleep、wait状态的线程，调用`interrupt()`会抛出异常且打断标记不会被设置为真，所以，如果想要