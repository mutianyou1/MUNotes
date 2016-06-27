# MUNotes
# 设备耗时性能调试
#：准备工作：Product->Profile，环境：生产环境，真机调试
# 勾选右边Call Tree中Separate Thread和Hide System Libraries
# 调试参考经验：
# 1、NSDateFormatter新建属性为33ms，设置属性达到30ms
# 2、imagedNamed初始化，imageNamed默认加载图片成功后会内存中缓存图片,这个方法用一个指定的名字在系统缓存中查找并返回一个图片对象.如果缓存中没有找到相应的图片对象,则从指定地方加载图片然后缓存对象，并返回这个图片对象.
#   imageWithContentsOfFile则仅只加载图片,不缓存.
# 3、单个view 尽量不要在viewWillAppear费时的操作
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#