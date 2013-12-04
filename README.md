ApkFuncCounter
==============

Android Apk Function Count by package

## 安装 ##

1.  需要预先配置jdk环境，测试 java -version保证其可以使用
2.  将目录下*.sh *.jar一共三个文件解压到任意文件夹（如 ~/temp）
3.  chmod +x ./countdex.sh

## 使用 ##

    ./countdex.sh test1.apk -d 5 viila

会进行以下步骤

1.  apk解包到out目录
2.  依据参数进行指定包的DEX方法数统计
3.  计算过滤后方法数总和

参数依次为

##### [APK]

test1.apk   APK地址

##### [DEPTH]

> -d 5
> 统计包的层数为 5

比如有apk文件包含 
    com.sample.app.a
    com.sample.app.b
    com.sample.lib.x
    com.sample.lib.y

选择层数 -d 3则过滤出以下两个包的反编译DEX方法数

    com.sample.app
    com.sample.lib

选择层数 -d 2则只有

    com.sample

比如项目命名空间是info.viila.android.test1.*表示各个模块，所以是-d 5

##### [DIFF]

> -diff test2.apk
> 与之前统计过的test2版本的方法进行比较

##### [FILTER]

> viila
> 过滤出包名中含有viila字样的包

* 过滤参数一直是最后一个
