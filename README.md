# 这里是 Sandwich！一个使用 Free Pascal 打包的实现了 Scaffolding 的应用程序！

## 介绍

1. 该程序使用 `Free Pascal` 打包！如果你需要从源码构建，请自行下载 `FPC` 或者 `Lazarus`！
2. 本程序不支持 `Delphi` 构建！不支持 `Delphi` 构建！不支持 `Delphi` 构建！！！
3. 项目基于 `EasyTier` 开发，已实现 `Scaffolding` 的所有功能！并作为 `动态可执行文件` 嵌入到 `PCL.Nova.Plus` 里！

## 下载

1. 可以直接从 `Github Release` 下载，如果觉得缓慢，可以自行搜索 `Github 下载加速`。
2. 在 `Github Release` 上下载的一般是稳定版，如果你想体验开发版，可以自行去 `Github Actions` 界面上下载开发的二进制包~

## 许可

1. 本项目使用 `GPL-3.0` 协议，并无任何附加协议。也就是说，如果你要提供修改版的 `Sandwich`，你必须附带相同的协议！
2. 本程序在未经修改的情况下，可以动态或者静态链接到您的程序，但是您不允许链接修改后的，除非开源并且附带相同许可证！
3. 简而言之，你不允许在未经过作者同意的情况下，分发**修改**后的**可执行文件**！除非你的程序同样开源并且附带同样的 `GPL v3` 许可证

## 程序功能

请下载 `EXECUTE` 版本的 `Sandwich`！如果你要将其绑定到您的程序当中，你也可以下载 `DYNAMIC` 并参考[类库制作](./LibExample.md)文档里的内容！

下载并解压，你会得到文件：`sandwich.exe`(Windows) 或者 `sandwich`(Unix)，请自行根据操作系统运行程序。

双击并运行 `sandwich` 可执行文件，并根据指示进行下一步操作，放心，很容易懂的！

## 注意事项

当你在除了 `Windows x86_64` 系统上运行该程序时，很可能会因为没有 `openssl` 这个类库而产生报错！请自行先在下方安装一次 `openssl`：

因为 `Windows x86_64` 版本的 `libeay32.dll` 和 `ssleay32.dll` 已经被我自包含入可执行文件了！【在打开时自解压】所以一般不会发生报错。。

WinCE for arm：<br>
自行网上搜索下载安装

macOS：
```
brew install openssl
```

Linux：
```
sudo apt install openssl
sudo yum install openssl
sudo pkg install openssl
sudo apk install openssl
sudo pacman -S openssl
```

如果你处于 `Windows x86_64` 系统，并且你确信自己系统里有的 `openssl` 比我的版本高，更安全，你可以下载 `Sandwich-Windows-x86_64-no-openssl` 版本，并自行运行！

我们会发现，`no-openssl` 版本的 `EXE` 比有 `openSSL` 的库要小将近 `2MB`，还好~

或者请自行上网上找源码包自行编译，又或者是自行从网上找二进制包自己下。

## 注意事项（严重）

由于本程序目前暂时无法编译 `Windows arm64` 版本，只能通过本地交叉编译一份 `WinCE for arm (only 16 bits)` 版本，

因此，如果你实在有需求在 `Windows arm64` 上使用 `Sandwich` 的话，请尝试下载一次 `WinCE for arm` 版本的，如果运行不了，请耐心等待 `FPC` 支持 `Windows arm64`！当 `FPC` 支持 `Windows arm64` 时，才可以正常进行编译！

如果你想为 `Windows arm64` 做出贡献，只需要修改 `CI CD` 文件，让其支持 `Windows arm64` 即可！目前官网上的[每日构建](https://downloads.freepascal.org/fpc/snapshot/trunk/aarch64-win64/)已经有了 `Windows arm64` 的编译产物，但是当我运行的时候，发生了很严重的意外！它无限递归抛出报错！因此我暂时无法提供版本，如果你懂 `Free Pascal` 的编译原理和构建过程（比如在 `CI CD` 里直接下载源码，并自主构建 `FPC`！），你当然可以为该仓库做出贡献！

在使用 `WinCE for arm` 的过程中，你需要自主下载 `openssl`，因为 Sandwich 不会内置 `arm` 版本的 `openssl`。

其中 `WinCE for arm` 使用的是 `easytier-windows-arm64` 版本的 `easytier` 哦，但是很可能运行不了，因为 `WinCE for arm` 是 `16 bit` 的操作系统。。
