---
layout: post
date: 2022-02-15 14:55:34 +0800
author: solitaryclown
title: SpringMVC
categories: Java
tags: 
# permalink: /:categories/:title.html
excerpt: "SpringMVC"
---
* content
{:toc}



# 1. SpringMVC
## 1.1. SpringMVC架构

## 1.2. 请求/响应
### 1.2.1. 请求
### 1.2.2. 响应

## 1.3. 拦截器
### 1.3.1. 原理
SpringMVC拦截器底层原理是**反射机制**，拦截器是Spring AOP思想的一种体现。


### 1.3.2. 使用
1. 创建拦截器类实现`HandlerInterceptor`接口，重写方法。
   ```java
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
       return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

    }
   ```
2. 配置拦截器
   ```xml
   <mvc:interceptors>
        <mvc:interceptor>
            <mvc:mapping path="/mav"/>
            <bean id="myInterceptor" class="com.huangbei.mvc.interceptor.MyInterceptor"></bean>
        </mvc:interceptor>
    </mvc:interceptors>
   ```


