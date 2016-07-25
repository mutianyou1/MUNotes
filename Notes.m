//
//  Notes.m
//  TabBarDemo
//
//  Created by 潘元荣(外包) on 16/7/4.
//  Copyright © 2016年 潘元荣(外包). All rights reserved.
//

//#import <Foundation/Foundation.h>
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
答：这个是做外部类遵守实现的。
SDWebImageDownloaderOperation都遵循了SDWebImageOperation的协议有实
答：这样做主要是为了让大家统一接口。因为SDWebImageDownLoaderOperation是继承NSOperation，但是SDWebImageCombinedOperation不是，但是大家都可以实现自己的cancel。
    同时这是个外部protocal文件所以不用赋值，只要实现即可
 */
//-------------runtime-----------------------
/*
 objective-C 程序与runtime系统有三种交互级别：
 1、通过objective-C源码
 2、通过fundation库中的nsobject方法
 3、直接调用runtime方法
 
 第一步：+ (BOOL)resolveInstanceMethod:(SEL)sel实现方法，指定是否动态添加方法。若返回NO，则进入下一步，若返回YES，则通过class_addMethod函数动态地添加方法，消息得到处理，此流程完毕。
 第二步：在第一步返回的是NO时，就会进入- (id)forwardingTargetForSelector:(SEL)aSelector方法，这是运行时给我们的第二次机会，用于指定哪个对象响应这个selector。不能指定为self。若返回nil，表示没有响应者，则会进入第三步。若返回某个对象，则会调用该对象的方法。
 第三步：若第二步返回的是nil，则我们首先要通过- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector指定方法签名，若返回nil，则表示不处理。若返回方法签名，则会进入下一步。
 第四步：当第三步返回方法方法签名后，就会调用- (void)forwardInvocation:(NSInvocation *)anInvocation方法，我们可以通过anInvocation对象做很多处理，比如修改实现方法，修改响应对象等
 第五步：若没有实现- (void)forwardInvocation:(NSInvocation *)anInvocation方法，那么会进入- (void)doesNotRecognizeSelector:(SEL)aSelector方法。若我们没有实现这个方法，那么就会crash，然后提示打不到响应的方法。到此，动态解析的流程就结束了。
 
//-------------AFNetworking-----------------------
问题一： NSURLSessionDataTask 由两种方法产生
 1、NSURLSession dataTaskWithRequest :
 2、NSURLSession dataTaskWithRequest : completionHandler:
 注意：NSURLSession 是抽象类不能直接实例化
 
 继承关系  NSURLSessionUploadTask －－>  NSURLSessionDataTask --> NSURLSessionTask
 
          NSURLSessionDownloadTask -->NSURLSessionTask
 
 当一个 NSURLSessionDataTask 完成时，它会带有相关联的数据，而一个 NSURLSessionDownloadTask 任务结束时，它会带回已下载文件的一个临时的文件路径（还记得前面的location吧）。因为一般来说，服务端对于一个上传任务的响应也会有相关数据返回，所以NSURLSessionUploadTask 继承自 NSURLSessionDataTask。
 
 问题二：HTTP协议之multipart/form-data请求分析
 OPTIONS、GET、HEAD、POST、PUT、DELETE、TRACE等，那为为何我们还会有multipart/form-data请求之说呢？这就要从头来说了。
 1、multipart/form-data是由post组合而成的
 2、multipart/form-data与post不同的在于请求头、请求体
 2.1 请求头：必须包含一个特殊头信息 content－type 值必须为multipart/form-data，同时还规定了一个内容分隔符号分隔post请求多个内容，具体请求头格式如下：Content-Type: multipart/form-data; boundary=${bound}
     ${bound}就是所谓的占位符号分隔用
 2.2 请求体：post是简单的name ＝ value方式 而本类请求如下：
 --${bound}
 Content-Disposition: form-data; name="Filename"
 
 HTTP.pdf
 --${bound}
 Content-Disposition: form-data; name="file000"; filename="HTTP协议详解.pdf"
 Content-Type: application/octet-stream
 
 %PDF-1.5
 file content
 %%EOF
 
 --${bound}
 Content-Disposition: form-data; name="Upload"
 
 Submit Query
 --${bound}--
 添加了分隔符的构造体
 
 //-------------上帝模式和农名模式-----------------------
 前言：看了唐巧的技术博客http://blog.devtang.com/2016/07/20/programming-worlds-farmer-and-god/
 分享了关于上帝模式和农名模式的区别和提高：
 1、上帝模式
 简而言之就是对架构的思考
 包括：类之间的组织和信息传递、构思好每个类大概怎么实现，这个过程又会利用了如何命名、DRY 原则、单一职责原则等编程知识。
 都是在毫无干扰的情况下完成的最好关掉电脑，在纸上完成。
 提高：参考《设计模式》、《重构》、《代码大全》并且结合实际的代码经验完成，或者优秀的开源软件的架构
 
 2、农名模式
 即代码的实现
 难点：避免思维的打断
 应该采用宽度优先、而不是深度优先
 例如：在自定义的tableView中我们利用上帝模式思考出需要 VC tableView Model cache等类思考相关关系、命名、命名成员变量、方法名
 然后转到农名模式思考完成各个类的实现。每个类完成了休息一定时间（番茄工作法：每个25分钟为一个番茄时间，不要被打扰，番茄时间结束后休息5分钟）
 这就是宽度优先。
 
 深度优先：先写一个VC 继而写着写着去写tableView 然后思考是不是要有个model啊，然后写model，最后想是不是写个缓存啊，这样思路容易打乱。
 
 
 
 
 
 
 **/
