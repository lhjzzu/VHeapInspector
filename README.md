# VHeapInspectorManager
一个简单的控制器是否被释放的工具，监测`UIViewController`是否被释放.

# Usage

直接将`VHeapInspectorManager.h`,`VHeapInspectorManager.m`文件拉入工程中即可。只有`debug`模式下能够使用，当把控制器`dismiss`或者`pop`掉后的1.2s后会开始监测，如果监测到`UIViewController`有未释放的对象会弹出一个提示框。


注意:在`VHeapInspectorManager.m`的`init`方法中添加将被忽略的控制器（如单例控制器等）。例如单例控制器

    -(instancetype)init
     {
      self = [super init];
      if (self) {
         //忽略的控制器数组
        ignoreVCArr = @[@"OneViewController",@"TowViewController"];
       }
        return self;
    }


 


