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
效果：
[![pCNUg4H.jpg](https://s1.ax1x.com/2023/06/25/pCNUg4H.jpg)](https://imgse.com/i/pCNUg4H)

## 3.3. 线性混合操作
线性混合操作是典型的二元像素操作，理论公式如下：**g(x)=(1-a)f0(x)+af1(x)**

通过改变alpha的值（0-1之间），来对两张图像或两段视频产生时间上的叠化效果，例如幻灯片翻页时的过渡叠加特效。
在OpenCV中，使用`addWeighted()`函数进行线性混合操作。

```cpp
/** @brief Calculates the weighted sum of two arrays.

The function addWeighted calculates the weighted sum of two arrays as follows:
\f[\texttt{dst} (I)= \texttt{saturate} ( \texttt{src1} (I)* \texttt{alpha} +  \texttt{src2} (I)* \texttt{beta} +  \texttt{gamma} )\f]
where I is a multi-dimensional index of array elements. In case of multi-channel arrays, each
channel is processed independently.
The function can be replaced with a matrix expression:
@code{.cpp}
    dst = src1*alpha + src2*beta + gamma;
@endcode
@note Saturation is not applied when the output array has the depth CV_32S. You may even get
result of an incorrect sign in the case of overflow.
@param src1 first input array.
@param alpha weight of the first array elements.
@param src2 second input array of the same size and channel number as src1.
@param beta weight of the second array elements.
@param gamma scalar added to each sum.
@param dst output array that has the same size and number of channels as the input arrays.
@param dtype optional depth of the output array; when both input arrays have the same depth, dtype
can be set to -1, which will be equivalent to src1.depth().
@sa  add, subtract, scaleAdd, Mat::convertTo
*/
CV_EXPORTS_W void addWeighted(InputArray src1, double alpha, InputArray src2,
                              double beta, double gamma, OutputArray dst, int dtype = -1);
```
功能：计算两个数组的**加权和**
参数：
* src1:第一个数组
* alpha：第一个数组的权重
* src:第二个数组，需要和第一个数组一样的尺寸和通道数
* beta：第二个数组的权重
* gamma:加到权重和上的一个常量
* dst:目标数组
* dtype:输出阵列的深度，默认值为-1

addWeighted()实际运算公式为：
**dst=src1[I]\*alpha+src2[I]\*beta+gamma**
其中：
+ I是多维数组的索引，当数组为多通道，每个通道单独处理
+ 
[![pCNfMod.png](https://s1.ax1x.com/2023/06/25/pCNfMod.png)](https://imgse.com/i/pCNfMod)

### 3.3.1. 例子
```cpp
#include<opencv2/opencv.hpp>

using namespace cv;
bool LinearBlending()
{
	double alphaValue = 0.5;
	double betaValue;
	Mat src1, src2, dst;
	src1 = imread("E:\\temp\\3.jpg");
	src2 = imread("E:\\temp\\4.jpg");

	if (!src1.data) {
		std::cout << "读取src1失败" << std::endl;
		return false;
	}
	if (!src2.data) {
		std::cout << "读取src1失败" << std::endl;
		return false;

	}
	betaValue = (1.0 - alphaValue);
	addWeighted(src1, alphaValue, src2, betaValue, 0.0, dst);
	const char* windowName = "线性混合示例";
	namedWindow(windowName);
	imshow(windowName, dst);
	return true;
}
int main()
{
	LinearBlending();
	waitKey(0);
}
```

## 3.4. 颜色通道分离、混合
### 3.4.1. cv::split()分离多通道
```cpp
CV_EXPORTS_W void split(InputArray m, OutputArrayOfArrays mv);
```

**注意**：为什么`OutputArrayOfArrays`类型的参数能接收`std::vector<>`类型的实参呢？因为c++的**隐式构造函数**机制，简单来说`OutputArrayOfArrays`是`_OutputArray`的别名，而`_OutputArray`有一个构造函数接收`std::vector<>`类型的参数，故函数`split()`可以接收`std::vector`的实例；


#### 3.4.1.1. 例子
```cpp
#include<opencv2/opencv.hpp>

using namespace cv;
int main()
{
	Mat src(500, 500,CV_8UC3, Scalar(50, 100, 0));
	std::vector<Mat> vec;
	cv::split(src, vec);
	Mat B = vec[0];
	Mat G = vec[1];
	Mat R = vec[2];



	std::vector<Mat> vec1;
	Mat dstMerge;
	//注意push_back的顺序应该按照B、G、R的顺序，否则图像效果会跟分解之前不一样。
	vec1.push_back(G);
	vec1.push_back(R);
	vec1.push_back(B);
	cv::merge(vec1,dstMerge);
	imshow("split", src);
	imshow("merge", dstMerge);
	waitKey(0);
}
```

效果：
[![pCUixlq.png](https://s1.ax1x.com/2023/06/26/pCUixlq.png)](https://imgse.com/i/pCUixlq)

## 3.5. 对比度、亮度调整
理论公式：**g**(x)=gain*f(x)+bias**


### 3.5.1. 例子
```cpp
#include<opencv2/opencv.hpp>

using namespace cv;

const char* windowName = "对比度和亮度调整";
Mat src, dst;
int gContrast, gBright;

void onContrastAndBrightChange(int, void*)
{
	for (int i = 0; i < src.rows; i++) {
		for (int j = 0; j < src.cols; j++) {
			int channel = 3;
			for (int k = 0; k < channel; k++) {
				dst.at<Vec3b>(i, j)[k] = saturate_cast<uchar>(gContrast * 0.01 * src.at<Vec3b>(i, j)[k] + gBright);
			}
		}
	}
	imshow(windowName,dst);
}


int main()
{
	//初始化
	gContrast = 80;
	gBright = 80;
	
	const char* bar1Name = "对比度";
	const char* bar2Name = "亮度";
	namedWindow(windowName);
	const char* path = "E:\\test.jpg";
	src = imread(path);
	dst = Mat::zeros(src.size(), src.type());

	cv::createTrackbar(bar1Name, windowName, &gContrast, 300, onContrastAndBrightChange);
	cv::createTrackbar(bar2Name, windowName, &gBright,200, onContrastAndBrightChange);
	imshow(windowName, src);

	while (waitKey(1)!='q')
	{
		;
	}
	return 0;

}
```

效果：
[![pCUmRzQ.png](https://s1.ax1x.com/2023/06/26/pCUmRzQ.png)](https://imgse.com/i/pCUmRzQ)

## 3.6. 傅里叶变换
Discrete Fourier Transform，DFT，离散傅里叶变换

**概念**：傅里叶变换在时域和频域上都呈现离散的形式，将时域信号的采样变换为在离散时间内傅里叶变换频域的采样

## XML和YAML读写
