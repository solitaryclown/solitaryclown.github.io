---
layout: post
date: 2023-06-23 22:04:35 +0800
title: opencv-HighGUI
author: solitaryclown
categories: opencv
tags: 
excerpt: "opencv的HightGUI模块详解"
---
* content
{:toc}


# 1. HighGUI

* 媒体输入输出
* 视频捕捉
* 图像和视频的编、解码
* 图形交互界面接口

常用类：`VideoCapture`



## 1.1. TrackBar的创建和使用
### 1.1.1. 创建TrackBar

```cpp
CV_EXPORTS int createTrackbar(const String& trackbarname, const String& winname,
                              int* value, int count,
                              TrackbarCallback onChange = 0,
                              void* userdata = 0);
```

* trackbarname:轨迹条名称
* winname:窗口名称，表示轨迹条附加到哪个窗口上
* value:滑块的初始位置
* count:轨迹条的最大值
* onChange:回调函数指针，每当滑块位置改变，会调用这个函数
  ```cpp
  /** @brief Callback function for Trackbar see cv::createTrackbar
    @param pos current position of the specified trackbar.
    @param userdata The optional parameter.
    */
    typedef void (*TrackbarCallback)(int pos, void* userdata);
  ```
* userdata:用户数据，用来作为回调函数的参数


### 1.1.2. 例子
```cpp
#include<opencv2/opencv.hpp>


#define WINDOW_NAME "[线性混合示例]"

using namespace cv;
const int g_nMaxAlphaValue = 100;
int g_nAlphaValueSlider;

double g_dAlphaValue;
double g_dBetaValue;

Mat g_srcImg1;
Mat g_srcImg2;
Mat g_dstImg;
void on_Trackbar(int, void*) 
{
	g_dAlphaValue = (double)g_nAlphaValueSlider / g_nMaxAlphaValue;
	//beta值等于1-alpha
	g_dBetaValue = 1.0 - g_dAlphaValue;
	//根据alpha和beta进行线性混合
	cv::addWeighted(g_srcImg1, g_dAlphaValue, g_srcImg2, g_dBetaValue, 0.0, g_dstImg);
	imshow(WINDOW_NAME, g_dstImg);
}
#define _CRT_SECURE_NO_WARNINGS
int main()
{
	//读取图片
	g_srcImg1 = imread("E:\\temp\\1.jpg");
	g_srcImg2 = imread("E:\\temp\\2.jpg");
	
	g_nAlphaValueSlider = 70;

	namedWindow(WINDOW_NAME, 1);
	char trackbarName[50];
	sprintf_s(trackbarName, "透明值 %d", g_nMaxAlphaValue);

	cv::createTrackbar(trackbarName, WINDOW_NAME,&g_nAlphaValueSlider,g_nMaxAlphaValue,on_Trackbar);
	//on_Trackbar(g_nAlphaValueSlider, 0);
	//
	waitKey(0);
	
	
}
```

效果：

## 1.2. 鼠标操作
和TrackBar的操作类似，opencv提供的窗口鼠标交互也是通过回调函数实现。

### 1.2.1. 设定回调函数
```cpp
/** @example samples/cpp/create_mask.cpp
This program demonstrates using mouse events and how to make and use a mask image (black and white) .
*/
/** @brief Sets mouse handler for the specified window

@param winname Name of the window.
@param onMouse Callback function for mouse events. See OpenCV samples on how to specify and use the callback.
@param userdata The optional parameter passed to the callback.
 */
CV_EXPORTS void setMouseCallback(const String& winname, MouseCallback onMouse, void* userdata = 0);
```

回调函数原型：
```cpp
/** @brief Callback function for mouse events. see cv::setMouseCallback
@param event one of the cv::MouseEventTypes constants.
@param x The x-coordinate of the mouse event.
@param y The y-coordinate of the mouse event.
@param flags one of the cv::MouseEventFlags constants.
@param userdata The optional parameter.
 */
typedef void (*MouseCallback)(int event, int x, int y, int flags, void* userdata);
```

**注意**：参数x、y是图像坐标系的坐标
参数：
* event:鼠标事件
  ```cpp
  //! Mouse Events see cv::MouseCallback
    enum MouseEventTypes {
        EVENT_MOUSEMOVE      = 0, //!< indicates that the mouse pointer has moved over the window.
        EVENT_LBUTTONDOWN    = 1, //!< indicates that the left mouse button is pressed.
        EVENT_RBUTTONDOWN    = 2, //!< indicates that the right mouse button is pressed.
        EVENT_MBUTTONDOWN    = 3, //!< indicates that the middle mouse button is pressed.
        EVENT_LBUTTONUP      = 4, //!< indicates that left mouse button is released.
        EVENT_RBUTTONUP      = 5, //!< indicates that right mouse button is released.
        EVENT_MBUTTONUP      = 6, //!< indicates that middle mouse button is released.
        EVENT_LBUTTONDBLCLK  = 7, //!< indicates that left mouse button is double clicked.
        EVENT_RBUTTONDBLCLK  = 8, //!< indicates that right mouse button is double clicked.
        EVENT_MBUTTONDBLCLK  = 9, //!< indicates that middle mouse button is double clicked.
        EVENT_MOUSEWHEEL     = 10,//!< positive and negative values mean forward and backward scrolling, respectively.
        EVENT_MOUSEHWHEEL    = 11 //!< positive and negative values mean right and left scrolling, respectively.
        };
  ```
* x:鼠标当前的x坐标
* y:鼠标当前的y坐标
* userdata：用户数据



### 1.2.2. 例子
在opencv图形窗口中用鼠标绘制矩形框：

```cpp
#include<opencv2/opencv.hpp>
using namespace cv;

#define WINDOW_NAME "[程序窗口]"

//全局函数声明
void on_MouseHandle(int event, int x, int y, int flags, void* param);
void DrawRectangle(cv::Mat& img, cv::Rect box);
void ShowHelpText();

Rect g_rectangle;
bool g_bDrawingBox = false;
RNG g_rng(12345);
int main()
{
	g_rectangle = Rect(-1, -1, 0, 0);
	Mat srcImage(600, 800, CV_8UC3), tempImage;
	srcImage.copyTo(tempImage);

	g_rectangle = Rect(-1, -1, 0, 0);
	srcImage = Scalar::all(0);

	namedWindow(WINDOW_NAME);

	cv::setMouseCallback(WINDOW_NAME, on_MouseHandle, (void*)&srcImage);

	while (1)
	{
		srcImage.copyTo(tempImage);
		if (g_bDrawingBox) {
			DrawRectangle(tempImage, g_rectangle);
		}
		imshow(WINDOW_NAME, tempImage);
		if (waitKey(10) == 27) {
			//ESC
			break;
		}
	}
	return 0;
}

void on_MouseHandle(int event, int x, int y, int flags, void* param)
{
	Mat& img = *(cv::Mat*)param;
	switch (event)
	{
	case EVENT_MOUSEMOVE:
		if (g_bDrawingBox) {
			//记录长和宽
			g_rectangle.width = x - g_rectangle.x;
			g_rectangle.height = y - g_rectangle.y;
		}
		break;
	case EVENT_LBUTTONDOWN:
		g_bDrawingBox = true;
		g_rectangle = cv::Rect(x, y, 0, 0);
		break;
	case EVENT_LBUTTONUP:
		g_bDrawingBox = false;
		if (g_rectangle.width < 0)
		{
			g_rectangle.x += g_rectangle.width;
			g_rectangle.width *= -1;
		}
		if (g_rectangle.height < 0)
		{
			g_rectangle.y += g_rectangle.height;
			g_rectangle.height *= -1;
		}
		DrawRectangle(img, g_rectangle);
		break;
	default:
		break;
	}
}

void DrawRectangle(cv::Mat& img, cv::Rect box)
{
	cv::rectangle(img, box.tl(), box.br(), Scalar(g_rng.uniform(0, 255), g_rng.uniform(0, 255), g_rng.uniform(0, 255)));
}
void ShowHelpText()
{
}

```
效果：
[![pCtURY9.png](https://s1.ax1x.com/2023/06/24/pCtURY9.png)](https://imgse.com/i/pCtURY9)


