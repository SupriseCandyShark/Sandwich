# 所有类库的实现函数

## 阅读须知：

本篇文章仅适用于开发者，不适用于用户和使用者。在使用本类库时，你需要注意以下几点：

1. 在以下函数表示，字符串均用 PChar（C 语言里是 char\*），数字均用 Integer（C 语言里是 int），指针均用 var xxx（C 语言里是 &xxx）
2. 目前本类库暂时无需指定结构体的，各位大可放心~
3. 下载 Release 中的 dll 或者 dylib 又或者 so，随后将其绑定至您的程序，再然后请按需求调用以下函数即可！

## 下载 Easytier

1. 获取 Easytier 的下载 URL

```pascal
// 默认获取最新版的 github release 下载链接
function GetEasytierUrl(): PChar; stdcall;
```

## 密码相关

1. 随机生成邀请码：

```pascal
function RandomRoomId(): PChar; stdcall;
```

2. 校验邀请码：

```pascal
function ValidateRoomId(roomId: PChar): Boolean; stdcall;
```

3. 获取本机识别码

> 这里简单说一下获取识别码的逻辑：
> Windows： 调用 wmic csproduct get UUID 并对返回值进行 MD5 加密后得到
> macOS：调用 system_profiler SPHardwareDataType | grep Hardware UUID 并对返回值进行 MD5 加密后得到
> Linux：调用 cat /etc/machine-id 并对返回值进行 MD5 加密后得到
> FreeBSD 调用 cat /etc/machine-id 并对返回值进行 MD5 加密后得到

```pascal
function GetMachineCode(): PChar; stdcall;
```

## MC 相关

1. 获取当前正在启动的 MC 实例（并且打开了局域网开放）的端口：

> 如果返回空，则说明要么是用户没有启动 MC，要么是用户的 UDP 连接协议较旧。

```pascal
function GetMCPort(): PChar; stdcall;
```

2. 销毁当前启动的 MC 实例（扫描进程并杀死所有 java 和 javaw 的 PID 进程）

> [!WARNING]
> 可能会误杀掉 Spring Boot 启动的项目，甚至是 HMCL 启动器！请不要乱用！

```pascal
procedure KillJavaInstance(); stdcall;
```

## easytier 相关

1. 创建 easytier 网络（并尝试打开 TCP 连接）：

> 参数列表：
> corePath: easytier-core 的路径
> mcPort: MC 局域网端口，可以通过上述函数获取，也可以自己获取！
> roomId: 房间邀请码，可以通过上述函数获取，也可以自己获取！
> 返回值：
> Result：返回虚拟联机大厅的 IP 和 端口（如果获取失败将返回错误信息，你可以判断返回值里面是否包含冒号来判断是否出错！）

```pascal
function CreateEasytier(corePath, mcPort, roomId: PChar): PChar; stdcall;
```

> 调用完了之后，会在本机开放 TCP 连接，后面你需要自己循环对协议内容进行ping和校验。这边建议查看一下协议：[Scaffolding](https://github.com/Scaffolding-MC/Scaffolding-MC)
> 协议内容待会说

2. 加入 easytier 网络（请在加入完成之后立即发送 c:player_ping），库会帮你校验协议内容的！

> 参数列表描述和返回值与上述一致，只是唯一一点不同的就是，加入方无需对本机开放 TCP 连接！
> 该函数将不会附带 mcPort！

```pascal
function JoinEasytier(corePath, roomId: PChar): PChar; stdcall;
```

3. 获取 easytier node 内容：

> 参数列表：
> cliPath: easytier-cli 的路径
> 返回值：
> Result: 如果正确 node 到，将会返回一个 JSON 格式的字符串，其中包括：
> {
> "inst_id": "<STRING>",
> "hostname": "<STRING>",
> "ipv4_addr": "<STRING>"
> }
> 如果返回空字符串，则说明你做错了！你需要先调用 CreateEasytier 或者 JoinEasytier 之后再说！

```pascal
function GetEasytierNode(cliPath: PChar); PChar; stdcall;
```

## 协议相关

> 1. 在上述函数中，已经给了各位如何获取本机识别码的信息了。这里将不再赘述！
> 2. 以下调用均需要在本机已经开启 TCP 之后才能调用，否则不予调用！不仅会返回一次值，还会向 TCP 服务器广播一次！也就是说，你必须调用一次 CreateEasytier 或者 JoinEasytier 之后才能使用下列函数
> 3. 以下函数均需要房主和房客共同调用（如果出现任何调用失败，将会返回空字符串！不会抛出报错！

1. c:player_ping

> 在协商协议之前请立即发送一次心跳包！
> 参数列表：
> ip: 传入上方的 IP 地址！
> playerName：把你启动 MC 参数里面的 PlayerName 拿出来就可以了！（或者也可以填入上面的 hostname）
> machineId: 在上述获取~
> etInstId: 获取上述 node，之后提取出里面的 inst_id，填到这里
> 返回值：
> Result: 如果返回 false，则说明联机中心已退出，或者你网断了。。否则全部都是返回 true！

```pascal
function CPlayerPing(ip, playerName, machineId, etInstId: PChar): Boolean; stdcall;
```

2. c:ping

> 提示：房主可以不用 ping，但是玩家必须ping

> 参数列表:
> ip: 同上
> str: 任意字符串
> 返回值:
> Result: 传什么就会得到什么。。

```pascal
function CPing(ip, str: PChar): PChar; stdcall;
```

3. c:protocols

> 参数列表：
> ip: 同上
> 不用填协议列表，因为 Sandwich 默认支持 Scaffolding 的所有协议！
> 返回值：
> Result: 返回联机中心的所有支持的协议！由 \0 切割

```pascal
function CProtocol(ip: PChar): PChar; stdcall;
```

4. c:server_port

> 由于 房主端 在前面 Create 的时候，已经输入了一次 mcPort，因此房主也可以请求这个，获得 MC 的端口！
> 不过这个通常是由 房客端 在 Join 的时候，未知端口是多少，随后请求一次这个，得到服务器地址是：127.0.0.1:<端口>

> 参数列表：
> ip: 同上
> 返回值：
> Result: 返回 MC 的端口

5. c:player_profile_list

> 在心跳包的基础上，获取玩家列表！
> 该函数会停滞，直到该房间内所有玩家均发送了心跳包，随后搜集所有心跳包，包装成列表并返回！（所有包的末尾会根据 hostname 自动判断是房客还是房主！）
> 参数列表：
> ip: 同上
> 返回值：
> Result: 参见上方c:player_ping心跳包，在末尾加上是房主还是房客，随后包装的列表字符串！

```pascal
function CPlayerProfileList(ip: PChar): PChar; stdcall;
```

6. c:player_easytier_id

> 返回 Easytier ID，用于上方的 player ping 调用！当然，其他房客也可以通过这个函数获取到您的 easyter id！
> 返回值：返回 Easytier ID

```pascal
function CPlayerEasytierID(ip: PChar): PChar; stdcall;
```
