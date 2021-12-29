---
layout: post
date: 2021-12-29 20:33:47 +0800
author: solitaryclown
categories: java
tags: 线程池
# permalink: /:categories/:title.html
excerpt: "线程池中execute()和submit()区别"
---
* content
{:toc}



# 区别
先看ThreadPoolExecutor的继承关系图
![](https://s4.ax1x.com/2021/12/26/TwgefA.png)

## 1.定义上
 `void execute(Runnable command)`是`Executor`接口中定义的方法
`<T> Future<T> submit(Callable<T> task)`和`<T> Future<T> submit(Runnable task, T result)`是`ExecutorService`中定义的方法。

## 2.使用区别
execute()一般用来执行没有返回值的任务，而submit()用来执行需要返回值的任务

## 3.异常处理

execute()在执行过程中出现异常，如果任务没有定义对异常的处理，则会默认抛出。而submit()执行时发生异常，底层会对异常进行捕获并记录。只有使用返回值Future的`get()`方法时才会抛出记录的异常。

### 分析原因
execute(Runnable r)底层是调用了Runnable的`run()`方法，没有捕获异常。
submit()比较复杂，它首先将task封装成一个`FutureTask<V>`对象，然后对这个对象调用execute(Runnable r)：
```java
public Future<?> submit(Runnable task) {
        if (task == null) throw new NullPointerException();
        RunnableFuture<Void> ftask = newTaskFor(task, null);
        execute(ftask);
        return ftask;
    }

    /**
     * @throws RejectedExecutionException {@inheritDoc}
     * @throws NullPointerException       {@inheritDoc}
     */
    public <T> Future<T> submit(Runnable task, T result) {
        if (task == null) throw new NullPointerException();
        RunnableFuture<T> ftask = newTaskFor(task, result);
        execute(ftask);
        return ftask;
    }

    /**
     * @throws RejectedExecutionException {@inheritDoc}
     * @throws NullPointerException       {@inheritDoc}
     */
    public <T> Future<T> submit(Callable<T> task) {
        if (task == null) throw new NullPointerException();
        RunnableFuture<T> ftask = newTaskFor(task);
        execute(ftask);
        return ftask;
    }
```

在上面的代码中，可以看到submit()有三个重载方法，submit()也可以接收Runnable类型的参数，重点对Callable类型的submit()分析。

> 实际上，Executors类中使用了适配器模式，用Callable适配Runnable，用call()包装了run()。

在submit()内部，调用了`newTaskFor(task)`，返回了一个`RunnableFuture<T>`类型的引用ftask，接着调用了execute(ftask)，并且最终返回了ftask。

**注意：**

<strong>最终返回了`FutureTask<V>`对象，也就是说，将任务和任务的结果都封装在了这个对象中。</strong>

一步步分析：

1. 
`newTaskFor(task)`调用了FutureTask<V>的构造方法

    ```java
    protected <T> RunnableFuture<T> newTaskFor(Callable<T> callable) {
            return new FutureTask<T>(callable);
    }

    public FutureTask(Callable<V> callable) {
            if (callable == null)
                throw new NullPointerException();
            this.callable = callable;
            this.state = NEW;       // ensure visibility of callable
        }
    ```

    可以看到，callable被赋值给在了FutureTask里面的一个叫`callable`的属性。

2. newTaskFor()返回的是RunnableFuture<V>类型引用，这是个接口且FutureTask继承自这个接口。
    
    ```java
    public interface RunnableFuture<V> extends Runnable, Future<V> {
    /**
     * Sets this Future to the result of its computation
     * unless it has been cancelled.
     */
    void run();
    }
    ```
    Runnable方法中已经声明了一个run()，这里为什么还要定义一个run()，原因可能仅仅是作者为了提醒使用者。
    而FutureTask实现了RunnableFuture接口，这意味着它内部一定定义了run()方法。
3. 前面提到execute()的原理是调用run()方法且没有对异常进行默认捕获，而submit()内部是调用execute(Ftask)，所以submit()中对异常处理的关键之处就在`FutureTask<V>`对run()方法的定义。
    ```java
     public void run() {
        if (state != NEW ||
            !UNSAFE.compareAndSwapObject(this, runnerOffset,
                                         null, Thread.currentThread()))
            return;
        try {
            Callable<V> c = callable;
            if (c != null && state == NEW) {
                V result;
                boolean ran;
                try {
                    result = c.call();
                    ran = true;
                } catch (Throwable ex) {
                    result = null;
                    ran = false;
                    setException(ex);
                }
                if (ran)
                    set(result);
            }
        } finally {
            // runner must be non-null until state is settled to
            // prevent concurrent calls to run()
            runner = null;
            // state must be re-read after nulling runner to prevent
            // leaked interrupts
            int s = state;
            if (s >= INTERRUPTING)
                handlePossibleCancellationInterrupt(s);
        }
    }
    ```

    很明显，这里定义的run()方法调用了callable属性的call()方法。
    **关键之处**：对异常进行了捕获并记录了，可以看到对捕获的异常调用了setException(ex)，不妨看一下这个方法的源码：
    ```java
     protected void setException(Throwable t) {
        if (UNSAFE.compareAndSwapInt(this, stateOffset, NEW, COMPLETING)) {
            outcome = t;
            UNSAFE.putOrderedInt(this, stateOffset, EXCEPTIONAL); // final state
            finishCompletion();
        }
    }
    ```
    可以看到，这个方法的内部将异常对象赋值给一个名为outcome的属性，它是个Object类型的属性
    ```java
    /** The result to return or exception to throw from get() */
    private Object outcome; // non-volatile, protected by state reads/writes
    ```
    这个outcome的作用就是存储从get()方法返回的结果或者抛出的异常。
    从这里可以了解到，**假设任务抛出了异常，异常会被捕获并用outcome维护这个异常对象，等到调用get()才能得到这个异常对象**。

    OK，让我们看一下get()方法做了什么：
    ```java
    public V get() throws InterruptedException, ExecutionException {
        int s = state;
        if (s <= COMPLETING)
            s = awaitDone(false, 0L);
        return report(s);
    }
    ```
    get()调用了一个report()方法，它是私有的。
    ```java
    private V report(int s) throws ExecutionException {
        Object x = outcome;
        if (s == NORMAL)
            return (V)x;
        if (s >= CANCELLED)
            throw new CancellationException();
        throw new ExecutionException((Throwable)x);
    }
    ```
    到这里，我们的分析已经豁然开朗了！
    + 当任务没有异常，report()会返回outcome并强转为泛型类型。
    + 当任务出现异常，会将异常抛出！

### 结论
submit()执行的任务如果没有对异常进行处理，则会被捕获并封装到结果对象即`FutureTask<V>`类型的对象中，只有在调用它的get()方法时才会抛出。

如果使用submit()执行任务没有对异常进行处理**或者**没有调用结果对象的get()方法，就永远不知道发生了什么异常！

**建议**：对于没有返回值的任务，使用`execute()`执行。

# 联系
其实经过对submit()和execute()的区别的分析，可以知道它们的联系就是submit()方法内部调用了execute()。