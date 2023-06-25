---
layout: post
date: 2023-06-24 23:31:38 +0800
title: opencv-core-2
author: solitaryclown
categories: 
tags: 
excerpt: ""
---
* content
{:toc}

# 1. 颜色空间缩减（批量替换像素）

在opencv中，使用查找表（look up table）的思想进行像素批量替换，具体使用`cv::LUT()`函数：
```cpp
CV_EXPORTS_W void LUT(InputArray src, InputArray lut, OutputArray dst);
```

## 1.1. LUT使用例子
步骤：建立一个1行256列的查找表，对一个8位深度的灰度图应用LUT函数，观察得到的目标图像。

```cpp
#include<opencv2/opencv.hpp>

using namespace cv;
int main()
{
	//建立查找表lut
	int devideWidth = 50;
	uchar table[256];
	for (int i = 0; i < 256; i++)
	{
		table[i] = devideWidth * (i / devideWidth);
	}
	Mat lut(1, 256, CV_8U);
	uchar* p = lut.data;
	for (int i = 0; i < 256; i++)
	{
		p[i] = table[i];
	}

	//图像
	Mat src = imread("E:\\test.jpg");
	Mat dst;
	int times = 1;
	for (int i = 0; i < times; i++)
	{
		cv::LUT(src, lut, dst);
	}
	imshow("原图", src);
	imshow("LUT", dst);
	std::cout << lut << std::endl;

	waitKey(0);
}
```

效果：
可以看到，应用LUT后，图像效果很明显的变化是**对比度加强了**，因为查找表压缩了像素范围。
[![pCNPI0g.png](https://s1.ax1x.com/2023/06/25/pCNPI0g.png)](https://imgse.com/i/pCNPI0g)


# 2. 访问像素
主要有3种形式：
1. 指针访问：操作符[]
2. 迭代器iterator
3. 动态地址计算


# 3. 感兴趣区域（ROI,region of interest）和图像混合

## 3.1. 定义感兴趣区域
opencv中，ROI用`Rect`定义
```cpp
#include<opencv2/opencv.hpp>


using namespace cv;
int main()
{
	Mat img = imread("E:\\temp\\2.jpg");
	Mat imgROI = img(Rect(0, 0, 100, 100));
	
	imshow("ROI",imgROI);

	waitKey(0);
}
```
## 3.2. 图像混合
```cpp
#include<opencv2/opencv.hpp>


using namespace cv;
int main()
{
	Mat src = imread("E:\\1.jpg");
	Mat logo = imread("E:\\2.jpg");
	Mat mask = imread("E:\\2.jpg",0);

	Mat imgROI = src(Rect(100, 100, logo.cols, logo.rows));


	logo.copyTo(imgROI, mask);
	imshow("ROI", src);
	imwrite("E:\\叠加.jpg", src);
	waitKey(0);
}
```