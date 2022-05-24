---
layout: post
date: 2022-05-03 19:50:40 +0800
author: solitaryclown
title: JavaScript
categories: web
tags: JavaScript
# permalink: /:categories/:title.html
excerpt: "JavaScript"
---
* content
{:toc}


# 1. JavaScript
## 1.1. 创建对象

### 1.1.1. 工厂模式
```javascript
console.log("//------------------------------------------------");
console.log("工厂模式");
console.log("//------------------------------------------------");
function createPerson(name,age){
    
    var o=new Object();
    o.name=name;
    o.age=age;
    o.sayName=function(){
        console.log(this.name);
    }
    return o;
}

var p1=createPerson("孙悟空", 1000);
var p2=createPerson("唐僧", 2000);
p1.sayName();
p2.sayName();

console.log(p1.sayName==p2.sayName);


```
运行结果：

    //------------------------------------------------
    工厂模式
    //------------------------------------------------
    孙悟空
    唐僧
    false




这种方式创建对象的缺点：
1. 对象类型无法识别（instanceof ）
2. 每个对象的函数对象实例都不同


### 1.1.2. 构造函数模式

```javascript
function Person(name,age){
    this.name=name;
    this.age=age;
    this.sayName=function(){
        console.log(this.name);
    }
}


var p1=new Person("孙悟空", 1000);
var p2=new Person("唐僧", 2000);
p1.sayName();
p2.sayName();

console.log(p1.sayName==p2.sayName);
console.log(p1 instanceof Person);
console.log(p2 instanceof Person);
```

输出：
    //------------------------------------------------
    构造函数方式
    //------------------------------------------------
    孙悟空
    唐僧
    false
    true
    true

缺点：每个对象都创建了自己的函数实例

### 1.1.3. 原型模式

```javascript
console.log('//------------------------------------------------');
console.log('原型模式');
console.log('//------------------------------------------------');

function Person(){

};
//字面量方式创建，这种方式会重写原型对象
Person.prototype={
    constructor: Person,
    name: 'Niko',
    age: 23,
    pets:[],
    sayName: function(){
        console.log(this.name);
    }

}

var p1=new Person();
p1.name="孙悟空";
var p2=new Person();
p2.name="唐僧";
p1.sayName();
p2.sayName();

console.log(p1.sayName==p2.sayName);

console.log(p1.pets);
console.log(p2.pets);

var ps1=p1.pets;
ps1.push("旺财");

console.log(p1.pets);
console.log(p2.pets);
```

结果：

    //------------------------------------------------
    原型模式
    //------------------------------------------------
    孙悟空
    唐僧
    true
    []
    []
    [ '旺财' ]
    [ '旺财' ]

优缺点：解决了同一种对象的不同实例拥有不同的函数对象实例的问题，但还存在一个问题：对于引用数据类型，比如Array和其他的对象类型的属性，不同的实例拥有的是同一个引用类型属性的实例，一个对象实例对属性的修改会影响到其他对象实例的属性。



    
### 1.1.4. 组合使用构造函数模式-原型模式
```javascript
/**
 * 定义对象的广泛使用的方法：
 *  1. 使用构造函数定义属性
 *  2. 使用原型定义方法
 */

//定义属性
function Person(name,age,gender){
    this.name=name;
    this.age=age;
    this.gender=gender;
}

//定义方法
Person.prototype={
    sayName:function(){
        console.log(this.name);
    }
}

var p1=new Person("乔峰",44,"MALE");
var p2=new Person("段誉",30,"MALE");
p1.sayName();
p2.sayName();
console.log(p1.sayName==p2.sayName);
```

### 1.1.5. 动态原型模式
```javascript
//动态原型模式
function Person(name,age,gender){
    this.name=name;
    this.age=age;
    this.gender=gender;
    if( typeof Person.prototype.sayName !="function"){
        Person.prototype.sayName=function(){
            console.log(this.name);
        }
    }
}
```

动态原型模式将所有信息封装在构造函数中，包括原型的初始化信息，它通过在构造函数中检查某个应该存在的函数在原型对象中是否存在来决定是否初始化原型。


### 1.1.6. 寄生构造函数模式
```javascript
function Person(name,age,gender){
    var o=new Object();
    o.name=name;
    o.age=age;
    o.gender=gender;
    o.sayName=function(){
        console.log(this.name);
    }
    return o;
}
```

缺点：不能使用instanceof关键字判断实例的类型
### 1.1.7. 稳妥构造函数模式

## 1.2. JavaScript继承
