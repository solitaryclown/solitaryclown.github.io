---
layout: post
date: 2023-06-24 14:30:47 +0800
title: opencv-core
author: solitaryclown
categories: opencv
tags: 
excerpt: ""
---
* content
{:toc}

# opencv-core
## opencv数据结构和基本绘图
* 容器Mat的用法
* 基础绘图操作
* 常用数据结构
* opencv的多种格式化输出操作


### Mat类
OpenCV从2.0版本开始使用Mat作为图像存储类。

#### Mat复制
**Mat类有自动管理内存的功能**
Mat类由矩阵头和指向存储像素的矩阵的指针组成，它的赋值运算符和拷贝构造函数在复制对象时只会复制矩阵头和矩阵指针，不会复制矩阵，保证了高效率。

如果需要复制矩阵本身，可以使用函数`clone()`或`copyTo()`。

#### 显示创建Mat实例
1. 构造函数
   ```cpp
    #include<opencv2/opencv.hpp>
    using namespace cv;
    int main()
    {
        Mat mat(2, 2,CV_8UC3, Scalar(0, 0, 255));
        std::cout << mat;
        std::cin.get();
    }
   ```

   >[  0,   0, 255,   0,   0, 255;
   0,   0, 255,   0,   0, 255]

### 格式化输出
```cpp
#include<opencv2/opencv.hpp>

using namespace cv;

int main()
{
	Point2f p1(1.1, 2);
	std::cout << "p1="<<p1<<std::endl;

	Point3f p2(8, 2, 1);
	std::cout << "p2=" << p2<<std::endl;
	//基于Mat的vector
	std::vector<float> v;
	v.push_back(1);
	v.push_back(3);
	v.push_back(5);
	std::cout << "Mat(v)=" << Mat(v) << std::endl;

	//存放Point的vector
	std::vector<Point2f> pointsV(20);
	for (size_t i = 0; i < pointsV.size(); i++)
	{
		pointsV[i] = Point2f((float)(i * 5), (float)(i % 7));
	}
	std::cout << "pointsV=" << pointsV;
	std::cin.get();
}
```

>p1=[1.1, 2]
p2=[8, 2, 1]
Mat(v)=[1;
 3;
 5]
pointsV=[0, 0;
 5, 1;
 10, 2;
 15, 3;
 20, 4;
 25, 5;
 30, 6;
 35, 0;
 40, 1;
 45, 2;
 50, 3;
 55, 4;
 60, 5;
 65, 6;
 70, 0;
 75, 1;
 80, 2;
 85, 3;
 90, 4;
 95, 5]




