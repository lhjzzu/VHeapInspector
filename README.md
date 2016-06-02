# VHeapInspector
一个简单的监测内存的工具，监测`UIViewController`以及`UITableviewCell`，`UICollectionViewCell`是否被释放.

#  Usage

直接将`sdk`中的文件拉入工程中即可。只有`debug`模式下能够使用，当把控制器`dismiss`或者`pop`掉后的1s后会开始监测，如果监测到`UIViewController`以及`UITableviewCell`，`UICollectionViewCell`，有未释放的对象会弹出一个提示框。


注意:在`VHeapInspectorManager.m`的`init`方法中修改要监测的类名的前缀(数组)，以及在这些前缀下要忽略检测的类名。例如单例控制器

    -(instancetype)init
     {
      self = [super init];
      if (self) {
         [VHeapStackInspector addClassPrefixesToRecord:@[@"V"]];
         [VHeapStackInspector ignoreClassNamesToRecord:@[@"Vxxxxxxxxxx"]];
         }
        return self;
    }


 


