# 目录结构

<ul>
		<li>bin: 可运行的bin文件；</li>
		<li>bosc_XSTop_xxxx: RTL文件和必要的附件；</li>
		<li>env: 为vcs编译的difftest环境；</li>
		<li>ref: difftest参考模型；</li>
		<li>sim: 仿真目录；</li>
</ul>



# bin列表

| case名               | 描述                                       |
| -------------------- | ------------------------------------------ |
| coremark-2-iteration | coremark 2 次迭代                          |
| dhrystone            | dhrystone 一个整数benchmark 1000次迭代     |
| linux                | 启动linux并运行hello world                 |
| microbench           | 运行一些经典的轻量级算法题                 |
| whetstone            | whetstone 一个浮点benchmark 减少了迭代次数 |



# 仿真编译与运行

## Step 1 编译仿真工程

```bash
make simv
```

若使用spike作为golden model 则加上参数

```bash
make simv SPKIE=1
```

这个命令会读取env和RTL内的文件，并在sim目录下编译可执行文件



## Step 2 运行仿真

```
make run RUN_BIN=xxxx.bin
```
若使用spike作为golden model 跑仿真则加上参数

```bash
make run RUN_BIN=xxxx.bin SPKIE=1
```

这个命令将运行bin目录下的bin的文件，例如`make run RUN_BIN=linux.bin`，这会在会在sim目录下产生linux.bin目录，里面是log和波形等信息。



## 额外参数配置

如果希望修改仿真目录，修改Makefile中的`SIM_DIR`变量；如果希望关闭波形产生，运行仿真时加上`TRACE=0`。

## 编译自定义case

```bash
cd nexus-am
export AM_HOME=`pwd`
cd apps/coremark
make ARCH=riscv64-xs-nhv3
```
生成的bin文件在coremark/build下。

若要自定义case，将源代码放入apps里，代码组织参考coremark等case。
