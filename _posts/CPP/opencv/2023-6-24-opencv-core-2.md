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

# 操作像素

在opencv中，使用查找表（look up table）的思想进行像素批量替换，具体使用`cv::LUT()`函数：
```cpp
CV_EXPORTS_W void LUT(InputArray src, InputArray lut, OutputArray dst);
```

## LUT使用例子
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

