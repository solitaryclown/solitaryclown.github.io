---
layout: post
date: 2021-12-26 15:49:44 +0800
author: solitaryclown
categories: java
tags: 线程池
# permalink: /:categories/:title.html
excerpt: "jdk的线程池的应用"
---
* content
{:toc}


# 线程池

## 前言
**任务**是逻辑上的工作单元，**线程**让是工作异步执行的机制，对于这两种线程执行任务的策略——所有任务在单一线程中顺序执行和每个任务在单独的线程中执行，都会有自己的局限性。

+ 单一线程顺序执行：响应慢，吞吐量低
+ 一个线程执行一个任务：给资源管理带来麻烦

## 为什么使用线程池？
1. 降低资源消耗：通过重复利用已创建的线程降低线程创建和销毁造成的消耗。
2. 提高响应速度：先把线程创建好，当任务到达时就可以立即执行。
3. 提高线程的可管理性： 线程是稀缺资源，如果无限制地创建，不仅会消耗系统资源，还会降低系统的稳定性，使用线程池可以进行统一分配、调优和监控

## Executor
Executor是个接口，但它为一个灵活而强大的框架创造了基础，这个框架可以用于异步任务执行，而且支持很多不同类型的任务执行策略。
它还为任务提交和任务执行之间的解耦提供了标准的方法，为使用`Runnable`描述任务提供了通用的方式。

Executor的实现还提供了对生命周期的支持以及钩子函数，可以添加诸如统计收集、应用管理机制和监视器等扩展。
## juc包下的的线程池`ThreadPoolExecutor`
### 继承关系
![TwgefA.png](https://s4.ax1x.com/2021/12/26/TwgefA.png)

### 主要成员
`private final AtomicInteger ctl = new AtomicInteger(ctlOf(RUNNING, 0))`：线程池控制状态，
包含两个概念：
+ workerCount：表示有效线程的数量，用ctl的低29位表示
+ runState：表示线程池状态，用ctl的高3位表示，`ThreadPoolExecutor`定义了5种状态
    ```java
    private static final int RUNNING    = -1 << COUNT_BITS;
    private static final int SHUTDOWN   =  0 << COUNT_BITS;
    private static final int STOP       =  1 << COUNT_BITS;
    private static final int TIDYING    =  2 << COUNT_BITS;
    private static final int TERMINATED =  3 << COUNT_BITS;
    ```


`private volatile int corePoolSize`：核心线程数

`private volatile int maximumPoolSize`：最大线程数

`private volatile long keepAliveTime`：当线程数大于corePoolSize，多余的线程在结束前等待新任务的最长时间。

`private volatile ThreadFactory threadFactory`：线程工厂

`private volatile RejectedExecutionHandler handler`：拒绝策略，默认为`AbortPolicy`，ThreadPoolExecutor定义了4种拒绝策略：
+ AbortPolicy：直接抛出异常`RejectedExecutionException`
+ CallerRunsPolicy：直接在调用`execute()`的线程中执行task
+ DiscardPolicy：直接丢弃（不执行）
+ DiscardOldestPolicy：丢弃最久未被处理的任务（即任务队列的队头元素），然后重试执行task

### ThreadPoolExecutor工作流程
这里主要是说明一下corePoolSize和maxiumPoolSize的关系，不会讲解线程池获取、执行任务的细节。

当线程池中线程数量不超过corePoolSize，创建新的线程，直接执行任务。

当线程数量等于corePoolSize且每个线程都繁忙，此时有新任务到来，判断：
+ 任务队列未满，将新任务添加到任务队列
+ 否则，即任务队列已满，创建新的线程并执行任务

当线程池中的线程数量达到maxiumPoolSize，并且每个线程都是繁忙的，此时有新任务到来
+ 任务队列未满，将新任务添加到任务队列
+ 否则，任务队列已满，此时已不能创建新的线程，只能对新的任务执行定义好的拒绝策略。


### 执行任务
+ `public void execute(Runnable command)`：执行的任务不需要返回值
+ `public <T> Future<T> submit(Callable<T> task)`：执行有返回值的任务
+ `public <T> List<Future<T>> invokeAll(Collection<? extends Callable<T>> tasks)`：执行Callble集合中的所有任务，当所有的任务都执行完毕，返回Future<T>集合。
+ `public <T> T invokeAny(Collection<? extends Callable<T>> tasks)`：执行Callble集合中的所有任务，最先执行完成的任务结果被返回并停止执行集合中其他的任务。
+ `public <T> T invokeAny(Collection<? extends Callable<T>> tasks，long timeout, TimeUnit unit)`：执行Callble集合中的所有任务，返回timeOut时间内执行完成的线程的结果，如果超时还没有任务被执行结束，抛出异常TimeoutException并停止执行集合中其他的任务。

### 关闭线程池
`void shutdown()`：已经提交的任务会被执行完，新的任务不会被接受，同时调用方法的线程不会被阻塞。

`List<Runnable> shutdownNow()`：停止所有活动的任务，同时返回任务队列中的任务集合（同时任务队列被中的所有任务被移除）。

**注意**：shutdownNow()原理是调用`interrupt()`，所以如果任务没有对中断做出响应，线程可能永远不会结束。（interrupt只是发送中断指令，需要线程自行决定是否终止。对于阻塞或等待的线程，比如调用了sleep、wait，interrupt会使线程抛出异常）

#### 例子
```java
package com.huangbei.test2;


import lombok.extern.slf4j.Slf4j;

import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeoutException;


@Slf4j(topic = "c.Test-shutdownNow")
public class Test8 {
    public static void main(String[] args) throws InterruptedException, ExecutionException, TimeoutException {


//        ExecutorService fixedThreadPool = Executors.newFixedThreadPool(3);
        ExecutorService pool = Executors.newFixedThreadPool(2);

        pool.execute(() -> {
            log.debug("任务1开始...");
            while (true){
                ;
            }
        });
        pool.execute(() -> {
            log.debug("任务2开始...");
            try {
                Thread.sleep(3000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            log.debug("任务2结束.");
        });
        pool.execute(() -> {
            log.debug("任务3开始...");
            try {
                Thread.sleep(500);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            log.debug("任务3结束.");
        });

//        Thread.sleep(1000);
        log.debug("执行pool.shutdownNow()方法");
        pool.shutdownNow();
        if(pool.isShutdown()){
            log.debug("线程池已关闭");
        }
    }
}
```

使用debug进行调试，断点打在`pool.shutdownNow()`上，shutdownNow执行前，线程列表如下：    
![TrHRDU.md.png](https://s4.ax1x.com/2021/12/28/TrHRDU.md.png)

当执行完shutdownNow()，可以看到线程2已经结束，但线程1还在运行。

因为线程2处在sleep，shutdownNow()会调用interrupt()，因此线程2被打断并抛出异常，但线程1是死循环，interrupt()只会设置其打断标记，不会中断其执行，因此shutdownNow()只会移除线程并关闭线程池，但之前的线程是否结束需要自己定义对中断的响应。
![TrH2uT.md.png](https://s4.ax1x.com/2021/12/28/TrH2uT.md.png)

`boolean isShutdown()`：只要pool状态不为RUNNING，就返回true

## Executors-多种线程池
一个工厂类，定义了获取不同类型的线程池的方法。
+ `newFixedThreadPool()`：创建固定线程数量的线程池
特点：
    - 线程数量固定，即maxiumPoolSize和corePoolSize相等，没有任务时不会被移除。
    - 任务队列使用`LinkedBlockingQueue`

+ `newCachedThreadPool()`：corePoolSize为0，maxiumPoolSize为`Integer.MAX_VALUE`，当线程等待60s仍然没有任务，会结束并移除线程池。
特点：使用`SynchronousQueue<E>`，这种队列不存储任何对象，每一次`put(E)`必须等待一个`take()`操作。

    适用场景：大量短时间异步任务。
    ![TDBlpq.png](https://s4.ax1x.com/2021/12/27/TDBlpq.png)

+ `newSingleThreadExecutor()`：创建只有单一线程的线程池。

    任务队列：`LinkedBlockingQueue<E>`

    特点：
    + 与newFixedThreadPool(1)不同的是，`newSingleThreadExecutor()`直接返回的不是ThreadLocalPool对象，而是Executors中的一个静态类`FinalizableDelegatedExecutorService`，这个类对ThreadLocalPool类中的一些方法做了隐藏，比如`setCorePoolSize()`等方法。
    ```java
    public static ExecutorService newSingleThreadExecutor() {
            return new FinalizableDelegatedExecutorService
                (new ThreadPoolExecutor(1, 1,0L, TimeUnit.MILLISECONDS,
                    new LinkedBlockingQueue<Runnable>()));
    ```
    + 和自己创建单一的线程执行一系列任务不同，singleThreadPool中的唯一线程执行某个任务因为某些原因异常终止，线程池会自动创建一个新的线程顶替，继续执行后面的任务。

+ `newScheduledThreadPool()`：创建计划线程池，其中的任务可以延迟执行。
    和前面三种线程池不同的是，构造的对象的是`ScheduledThreadPoolExecutor`。
    ```java
    public class ScheduledThreadPoolExecutor 
    extends ThreadPoolExecutor 
    implements ScheduledExecutorService
    ```
    任务队列：`DelayedWorkQueue`，它继承AbstractQueue<Runnable>类，实现BlockingQueue<Runnable>接口

    ScheduledPoolExecutor相比Timer优点：
    - 任务之间的延时时间互不影响
    - 前面的任务异常不会影响后面任务的执行

    延时执行任务：
    ```java
    public ScheduledFuture<?> scheduleAtFixedRate(Runnable command,
                                                  long initialDelay,
                                                  long period,
                                                  TimeUnit unit)
    public ScheduledFuture<?> scheduleWithFixedDelay(Runnable command,
                                                     long initialDelay,
                                                     long delay,
                                                     TimeUnit unit);                                              
    ```
    区别和相同点：
    + 区别：scheduleWithFixedDelay()，第三个参数delay是从上一个任务结束到下一个任务开始之间的延时，不管任务执行需要多长时间，结束后都需要等待delay时间再开始下一个任务。
    而调用scheduleAtFixedRate()，如果任务执行的时间比第三个参数period还要长，当且仅当上一个任务结束就开始下一个任务，但不会并发执行。
    - 相同：两者执行的任务如果出现异常，那么后面的任务都会被取消执行。

## 线程池大小设置
线程池大小的确定并不需要多么精确，只需要避免过大和过小两种极端情况。
+ 过大：频繁发生线程上下文切换，对稀缺的CPU和内存资源的竞争造成内存的高使用量
+ 过小：可能存在可用的处理器资源没有工作，对吞吐量造成损失。

### 1.CPU密集型任务
通常：N_threads=N_CPU+1

### 2.I/O密集型任务
![线程池大小确认](https://s4.ax1x.com/2021/12/28/Tyx2NV.png)