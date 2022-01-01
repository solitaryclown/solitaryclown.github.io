---
layout: post
date: 2021-12-30 21:52:55 +0800
author: solitaryclown
categories: java
tags: 多线程 并行
# permalink: /:categories/:title.html
excerpt: "ForkJoinPool是一个支持并行计算的线程池。"
---
* content
{:toc}


# Fork/Join框架
Fork/Join framework is a framework for parallel task execution provided by Java 7
## 继承关系
[![TfP2vR.png](https://s4.ax1x.com/2021/12/31/TfP2vR.png)](https://imgtu.com/i/TfP2vR)
## example

## 理解
ForkJoinPool是用来执行`ForkJoinTask<V>`这种任务的线程池。

## fork()和join()

**重点**：
`ForkJoinTask<V>`中的join()不同于`Thread`中的join()！！！
<strong>
`Thread`的join()是让当前线程阻塞等待被调用join()的线程结束，而`ForkJoinTask`中的`join()`是让当前线程去执行别的任务，一定要搞清楚这个区别。


</strong>