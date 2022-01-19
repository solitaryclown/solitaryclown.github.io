---
layout: post
date: 2022-01-02 11:59:09 +0800
author: solitaryclown
title: Semaphore
categories: java
tags: 信号量 AQS
# permalink: /:categories/:title.html
excerpt: "Semaphore的使用"
---
* content
{:toc}

# Semaphore
 * @since 1.5
 * @author Doug Lea

## 结构
[![TTV0i9.png](https://s4.ax1x.com/2022/01/02/TTV0i9.png)](https://imgtu.com/i/TTV0i9)

## 作用
Semaphore，信号量，用来限制访问共享资源的线程数量。

## 例子

```java
package com.huangbei.test2;

import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.Semaphore;

import static com.huangbei.util.Sleeper.sleep;

@Slf4j(topic = "c.TestSemaphore")
public class Test21 {
    public static void main(String[] args) {
        Data dataObject = new Data();
        int nThreads = 10;


        for (int i = 0; i < nThreads; i++) {
            new Thread(()->{
                log.debug("读取：{}",dataObject.read());
            }).start();
        }

    }

    static class Data {
        private Semaphore semaphore = new Semaphore(3);
        private String data = "Hello,Semaphore";


        public String read() {
            try {
                semaphore.acquire();
                sleep(1);
                return data;
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                semaphore.release();
            }
            return null;
        }


    }
    static class Counter{
        private int count;
        public void increment(){
            count++;
        }
        public int getCount(){
            return count;
        }
    }
}


```

### 结果：
```
//只能有三个线程同时访问Semephore控制的共享资源
15:33:54.085 [Thread-0] c.TestSemaphore - 读取：Hello,Semaphore
15:33:54.092 [Thread-2] c.TestSemaphore - 读取：Hello,Semaphore
15:33:54.093 [Thread-1] c.TestSemaphore - 读取：Hello,Semaphore
15:33:55.099 [Thread-5] c.TestSemaphore - 读取：Hello,Semaphore
15:33:55.099 [Thread-3] c.TestSemaphore - 读取：Hello,Semaphore
15:33:55.099 [Thread-4] c.TestSemaphore - 读取：Hello,Semaphore
15:33:56.101 [Thread-8] c.TestSemaphore - 读取：Hello,Semaphore
15:33:56.101 [Thread-6] c.TestSemaphore - 读取：Hello,Semaphore
15:33:56.101 [Thread-7] c.TestSemaphore - 读取：Hello,Semaphore
15:33:57.106 [Thread-9] c.TestSemaphore - 读取：Hello,Semaphore
```

## 原理
Semaphore本质是一种有限制的共享锁，它限制了`semaphore.acquire()`和`semaphore.release()`之间的运行的线程的数量。

