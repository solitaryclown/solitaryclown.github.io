---
layout: post
date: 2022-01-04 12:44:25 +0800
author: solitaryclown
title: CopyOnWriteArrayList/Set
categories: java
tags: JUC
# permalink: /:categories/:title.html
excerpt: "CopyOnWriteArrayList/Set的介绍"
---
* content
{:toc}


# CopyOnWriteArrayList
## 特点：  
+ 写入时拷贝
+ 并发读、并发读写，同步写写（互斥）

## 原理：  
`add(E e)`操作加了锁（jdk8版本使用ReentrantLock，11版本使用synchronized），保证添加时只能有一个线程操作。
在add方法中，在获取到锁后，先将原数组复制一份，在新数组基础上进行添加元素，然后将原数组替换为新数组，完成添加元素的方法。

## 应用场景
CopyOnWriteArrayList适用于**读多写少**的场景，因为写操作（包括add、remove）涉及到数组的的拷贝，比较耗时。

## 问题
弱一致性。
**注意**：**并发高**和**数据一致性**是矛盾的。

# CopyOnWriteArraySet
CopyOnWriteArraySet内部使用CopyOnWriteArrayList对象，所有的操作都是在这个对象上的。
[![Tqv9r4.png](https://s4.ax1x.com/2022/01/04/Tqv9r4.png)](https://imgtu.com/i/Tqv9r4)
[![TqvpMF.png](https://s4.ax1x.com/2022/01/04/TqvpMF.png)](https://imgtu.com/i/TqvpMF)