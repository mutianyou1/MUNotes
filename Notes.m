//
//  Notes.m
//  TabBarDemo
//
//  Created by 潘元荣(外包) on 16/7/4.
//  Copyright © 2016年 潘元荣(外包). All rights reserved.
//

//import <Foundation/Foundation.h>
// MUNotes
//-------------设备耗时性能调试-------------------
//：准备工作：Product->Profile，环境：生产环境，真机调试
// 勾选右边Call Tree中Separate Thread和Hide System Libraries
// 调试参考经验：
// 1、NSDateFormatter新建属性为33ms，设置属性达到30ms
// 2、imagedNamed初始化，imageNamed默认加载图片成功后会内存中缓存图片,这个方法用一个指定的名字在系统缓存中查找并返回一个图片对象.如果缓存中没有找到相应的图片对象,则从指定地方加载图片然后缓存对象，并返回这个图片对象.
//   imageWithContentsOfFile则仅只加载图片,不缓存.
// 3、单个view 尽量不要在viewWillAppear费时的操作


//-------------SDWebImage-----------------------
/**
 网上问题：SDWebImage默认缓存存png图片如果不是png格式默认缓存为jpeg格式，转换为data，png会丢失exif信息（包含作者时期压缩比等等）
同时缓存超过最大时刚加入的缓存对象会在io线程写入文件前被释放。
 
 
 笔记问题一：
 SDWebImageDownloaderOperation 类继承了NSOperation 重写了start 但是，全局搜索没有发现其他类调用的start
 这个问题困扰了一天终于在网上找到答案：

 如果你也熟悉Java，NSOperation就和java.lang.Runnable接口很相似。和Java的Runnable一样，NSOperation也是设计用来扩展的，只需继承重写NSOperation的一个方法main。相当与java 中Runnalbe的Run方法。然后把NSOperation子类的对象放入NSOperationQueue队列中，该队列就会启动并开始处理它。
 同时：实现main方法, 线程串行执行; 实现start方法, 线程并发执行. 
 所以加入线程 那么就会启动，一般情况下可以使用系统提供的子类
 
 苹果官方的解释如下：
 The NSOperation class is an abstract class you use to encapsulate the code and data associated with a single task. Because it is abstract, you do not use this class directly but instead subclass or use one of the system-defined subclasses (NSInvocationOperation or BlockOperation) to perform the actual task. Despite being abstract, the base implementation of NSOperation does include significant logic to coordinate the safe execution of your task. The presence of this built-in logic allows you to focus on the actual implementation of your task, rather than on the glue code needed to ensure it works correctly with other system objects.
NSOperation是抽象类
 

笔记问题二：
SDWebImageManagerDelegate 在SDWebImageManager类里面有判断是否相应，但是其他类没有代理赋值，请问这个代理如何去使用的？
 
 
 
 
 
 
 
 */