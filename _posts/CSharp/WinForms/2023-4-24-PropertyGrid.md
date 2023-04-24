---
layout: post
date: 2023-04-24 09:30:16 +0800
title: PropertyGrid控件使用
author: solitaryclown
categories: WinForms
tags: WinForms
excerpt: ""
---
* content
{:toc}


## 1. 代码
1. Brand
```csharp
class Brand
    {
        [Category("属性")]
        [DisplayName("配方ID")]
        [ReadOnly(true)]
        public int Id { get; set; }
        [Category("属性")]
        [DisplayName("配方名称")]
        public string Name { get; set; }

        [Category("属性")]
        [DisplayName("配方说明")]
        public string Description { get; set; }

        //一般参数
        [Category("参数")]
        [DisplayName("极柱个数")]
        public int numOfPole
        {
            get;set;
        }
        public Brand()
        {
        }
        public Brand(int id, string name, string description)
        {
            Id = id;
            Name = name;
            Description = description;
        }
    }
```

2. Form 
```csharp
  public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
            Brand brand = new Brand();
            brand.Id = 1;
            brand.Name = "1P18";
            brand.Description = "1P18芯配方";
            this.propertyGrid1.SelectedObject = brand;
        }
    }
```
## 2. 运行效果
[![p9m8CtJ.png](https://s1.ax1x.com/2023/04/24/p9m8CtJ.png)](https://imgse.com/i/p9m8CtJ)



