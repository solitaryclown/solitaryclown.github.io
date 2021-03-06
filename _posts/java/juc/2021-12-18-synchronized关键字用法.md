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

# 1. synchronized关键字

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

## 1.1. synchronized原理
synchronized锁的机制是**非公平锁**

### 1.1.1. synchronized在释放锁时唤醒entryList里面的线程是有序的吗？
答：有序。

我不知道下面这个例子是否有说服力。

#### 1.1.1.1. 例子
```java
package com.huangbei.test2;

import lombok.extern.slf4j.Slf4j;
import static com.huangbei.util.Sleeper.sleep;

@Slf4j(topic = "c.Test19")
public class Test19 {
    public static void main(String[] args) {

        new Thread(()->{
            synchronized (Test19.class){
                log.debug("我要占用锁11s.");
                sleep(11);
                log.debug("我要释放锁了！");
            }
        }).start();


        for (int i = 0; i < 100; i++) {
            int id=i;

            new Thread(()->{
                synchronized (Test19.class){
                    log.debug("我是线程 "+id);
                }
            },id+"").start();
            sleep(0.1);
        }
    }
}

```

#### 1.1.1.2. 结果
```
19:53:57.737 [Thread-0] c.Test19 - 我要占用锁11s.
19:54:08.749 [Thread-0] c.Test19 - 我要释放锁了！
19:54:08.749 [99] c.Test19 - 我是线程 99
19:54:08.750 [98] c.Test19 - 我是线程 98
19:54:08.751 [97] c.Test19 - 我是线程 97
19:54:08.751 [96] c.Test19 - 我是线程 96
19:54:08.751 [95] c.Test19 - 我是线程 95
19:54:08.752 [94] c.Test19 - 我是线程 94
19:54:08.752 [93] c.Test19 - 我是线程 93
19:54:08.752 [92] c.Test19 - 我是线程 92
19:54:08.752 [91] c.Test19 - 我是线程 91
19:54:08.753 [90] c.Test19 - 我是线程 90
19:54:08.753 [89] c.Test19 - 我是线程 89
19:54:08.753 [88] c.Test19 - 我是线程 88
19:54:08.754 [87] c.Test19 - 我是线程 87
19:54:08.754 [86] c.Test19 - 我是线程 86
19:54:08.754 [85] c.Test19 - 我是线程 85
19:54:08.754 [84] c.Test19 - 我是线程 84
19:54:08.755 [83] c.Test19 - 我是线程 83
19:54:08.755 [82] c.Test19 - 我是线程 82
19:54:08.755 [81] c.Test19 - 我是线程 81
19:54:08.755 [80] c.Test19 - 我是线程 80
19:54:08.756 [79] c.Test19 - 我是线程 79
19:54:08.756 [78] c.Test19 - 我是线程 78
19:54:08.756 [77] c.Test19 - 我是线程 77
19:54:08.757 [76] c.Test19 - 我是线程 76
19:54:08.757 [75] c.Test19 - 我是线程 75
19:54:08.757 [74] c.Test19 - 我是线程 74
19:54:08.757 [73] c.Test19 - 我是线程 73
19:54:08.757 [72] c.Test19 - 我是线程 72
19:54:08.757 [71] c.Test19 - 我是线程 71
19:54:08.757 [70] c.Test19 - 我是线程 70
19:54:08.758 [69] c.Test19 - 我是线程 69
19:54:08.758 [68] c.Test19 - 我是线程 68
19:54:08.758 [67] c.Test19 - 我是线程 67
19:54:08.758 [66] c.Test19 - 我是线程 66
19:54:08.758 [65] c.Test19 - 我是线程 65
19:54:08.758 [64] c.Test19 - 我是线程 64
19:54:08.761 [63] c.Test19 - 我是线程 63
19:54:08.762 [62] c.Test19 - 我是线程 62
19:54:08.762 [61] c.Test19 - 我是线程 61
19:54:08.762 [60] c.Test19 - 我是线程 60
19:54:08.762 [59] c.Test19 - 我是线程 59
19:54:08.763 [58] c.Test19 - 我是线程 58
19:54:08.763 [57] c.Test19 - 我是线程 57
19:54:08.763 [56] c.Test19 - 我是线程 56
19:54:08.763 [55] c.Test19 - 我是线程 55
19:54:08.763 [54] c.Test19 - 我是线程 54
19:54:08.763 [53] c.Test19 - 我是线程 53
19:54:08.763 [52] c.Test19 - 我是线程 52
19:54:08.763 [51] c.Test19 - 我是线程 51
19:54:08.763 [50] c.Test19 - 我是线程 50
19:54:08.764 [49] c.Test19 - 我是线程 49
19:54:08.764 [48] c.Test19 - 我是线程 48
19:54:08.764 [47] c.Test19 - 我是线程 47
19:54:08.764 [46] c.Test19 - 我是线程 46
19:54:08.764 [45] c.Test19 - 我是线程 45
19:54:08.764 [44] c.Test19 - 我是线程 44
19:54:08.764 [43] c.Test19 - 我是线程 43
19:54:08.766 [42] c.Test19 - 我是线程 42
19:54:08.766 [41] c.Test19 - 我是线程 41
19:54:08.766 [40] c.Test19 - 我是线程 40
19:54:08.767 [39] c.Test19 - 我是线程 39
19:54:08.767 [38] c.Test19 - 我是线程 38
19:54:08.767 [37] c.Test19 - 我是线程 37
19:54:08.767 [36] c.Test19 - 我是线程 36
19:54:08.768 [35] c.Test19 - 我是线程 35
19:54:08.768 [34] c.Test19 - 我是线程 34
19:54:08.768 [33] c.Test19 - 我是线程 33
19:54:08.768 [32] c.Test19 - 我是线程 32
19:54:08.768 [31] c.Test19 - 我是线程 31
19:54:08.768 [30] c.Test19 - 我是线程 30
19:54:08.768 [29] c.Test19 - 我是线程 29
19:54:08.769 [28] c.Test19 - 我是线程 28
19:54:08.769 [27] c.Test19 - 我是线程 27
19:54:08.769 [26] c.Test19 - 我是线程 26
19:54:08.769 [25] c.Test19 - 我是线程 25
19:54:08.769 [24] c.Test19 - 我是线程 24
19:54:08.769 [23] c.Test19 - 我是线程 23
19:54:08.770 [22] c.Test19 - 我是线程 22
19:54:08.770 [21] c.Test19 - 我是线程 21
19:54:08.770 [20] c.Test19 - 我是线程 20
19:54:08.770 [19] c.Test19 - 我是线程 19
19:54:08.770 [18] c.Test19 - 我是线程 18
19:54:08.770 [17] c.Test19 - 我是线程 17
19:54:08.770 [16] c.Test19 - 我是线程 16
19:54:08.770 [15] c.Test19 - 我是线程 15
19:54:08.770 [14] c.Test19 - 我是线程 14
19:54:08.773 [13] c.Test19 - 我是线程 13
19:54:08.773 [12] c.Test19 - 我是线程 12
19:54:08.774 [11] c.Test19 - 我是线程 11
19:54:08.774 [10] c.Test19 - 我是线程 10
19:54:08.774 [9] c.Test19 - 我是线程 9
19:54:08.774 [8] c.Test19 - 我是线程 8
19:54:08.774 [7] c.Test19 - 我是线程 7
19:54:08.774 [6] c.Test19 - 我是线程 6
19:54:08.774 [5] c.Test19 - 我是线程 5
19:54:08.774 [4] c.Test19 - 我是线程 4
19:54:08.774 [3] c.Test19 - 我是线程 3
19:54:08.774 [2] c.Test19 - 我是线程 2
19:54:08.774 [1] c.Test19 - 我是线程 1
19:54:08.774 [0] c.Test19 - 我是线程 0
```

设想可能：_EntryList用的插入方法是头插法，后来阻塞的线程会被排在前面。