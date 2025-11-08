# 所有类库的实现函数

## 阅读须知：

本篇文章仅适用于开发者，不适用于用户和使用者。在使用本类库时，你需要注意以下几点：

1. 在以下函数表示，字符串均用 char\*，数字均用 int，指针均用 &xxx，bool 也用 int 但是只会使用 0 和 1 两个返回值！，为了兼容 C99！
2. 目前本类库暂时无需指定结构体的，各位大可放心！所有 JSON 均使用字符串返回，不使用结构体！
3. 下载 Release 中的 dll 或者 dylib 又或者 so，随后将其绑定至您的程序，再然后请按需求调用以下函数即可！

> 请先在程序开头写上这样一串话：
> ```c
> #define C_BOOL int
> ```
> 以将 C_BOOL 类型转成 int！

## Easytier 网络相关

1. 获取 Easytier 的下载 URL

> 下载逻辑需要你们自行实现！

```c
// 默认获取最新版的 github release 下载链接
__declspec(dllimport) char* __stdcall GetEasytierUrl();
```

2. 获取 Easytier 官方的节点列表

> 参数列表：
> 
> page：页数\
> pageSize：页面大小
>
> 返回值：\
> 以字符串的 JSON List 形式返回，包含如下信息：
> ```json
> [
>   {
>     "version": "<STRING>", // 支持的 Easytier 版本
>     "nodeName": "<STRING>", // 节点名称简介
>     "nodeHost": "<STRING>", // 节点主机
>     "nodePort": 0, // 节点端口
>     "nodeURL": "<STRING>", // 节点全称地址
>     "maxConnect": 0, // 最大连接数
>     "curConnect": 0, // 当前连接数
>     "mcRelaySupport": false, // 是否支持 MC 中继
>     "description": "<STRING>", // 节点描述
>   }
> ]
> ```
>
> 打个比方，我调用这个函数，传的参数是：3, 50，那么，就会顺延到第三页，这个页数大小是50！\
> 返回值我大概做一个示例：
> ```json
> [
>   {
>     "version": "2.4.5",
>     "nodeName": "官方公共服务器-湖北浪浪云",
>     "nodeHost": "public.easytier.cn",
>     "nodePort": 11010,
>     "nodeURL": "tcp://public.easytier.cn:11010",
>     "maxConnect": 100,
>     "curConnect": 167,
>     "mcRelaySupport": false,
>     "description": "限速 50KB/s。"
>   }
> ]
> ```

```c
__declspec(dllimport) char* __stdcall GetEasytierNode(int page, int pageSize);
```

## 密码相关

1. 随机生成邀请码：

```c
__declspec(dllimport) char* __stdcall RandomRoomId();
```

2. 校验邀请码：

```c
__declspec(dllimport) C_BOOL __stdcall ValidateRoomId(char* roomId);
```

3. 获取本机识别码

> 这里简单说一下获取识别码的逻辑：\
> Windows：调用 wmic csproduct get UUID 并对返回值进行 MD5 加密后得到\
> macOS：调用 system_profiler SPHardwareDataType | grep Hardware UUID 并对返回值进行 MD5 加密后得到\
> Linux：调用 cat /etc/machine-id 并对返回值进行 MD5 加密后得到\
> FreeBSD 调用 cat /etc/machine-id 并对返回值进行 MD5 加密后得到

```c
__declspec(dllimport) char* __stdcall GetMachineCode();
```

## MC 相关

1. 获取当前正在启动的 MC 实例（并且打开了局域网开放）的端口：

> 如果返回空，则说明要么是用户没有启动 MC，要么是用户的 UDP 连接协议较旧。\
> 注意，该函数会导致主线程至少停滞一分钟，用于检测 MC 端口！因此，请新开一个线程执行该函数！不要直接使用主线程！【除非你写的是 cli 程序】\
> 可以自行转换成 Integer！只会返回 1024 - 65535 之间的值！如果出现不属于这里面的值，或者在 转换成 Integer 时出错了，那就直接告诉用户读取失败，并让用户手动输入端口！

```c
__declspec(dllimport) char* __stdcall GetMCPort();
```

2. 销毁当前启动的 MC 实例（扫描进程并杀死所有 java 和 javaw 的 PID 进程）

> [!WARNING]
> 可能会误杀掉 Spring Boot 启动的项目，甚至是 HMCL 启动器！请不要乱用！\
> 整个 dll 唯二无返回值的函数！

```c
__declspec(dllimport) void __stdcall KillJavaInstance();
```

## Easytier 程序相关

1. 创建 Easytier 网络（并尝试打开 TCP 连接）：

> 参数列表：\
> corePath: easytier-core 的路径\
> mcPort: MC 局域网端口，可以通过上述函数获取，也可以自己获取！\
> roomId: 房间邀请码，可以通过上述函数获取，也可以自己获取！\
> nodeUrl: 节点URL列表（可以通过上方 GetEasytierNode 获取）。
> 返回值：\
> Result：返回虚拟联机大厅的 IP 和 端口（如果获取失败将返回错误信息，你可以判断返回值里面是否包含冒号来判断是否出错！）

> [!WARNING]
> nodeURL 传入的 nodeUrl 列表格式是 `["<node1>","<node2>","node3"]` 的 JSON 形式！如果只有一个 URL 的话，也要传入列表！如果你需要传入官方的节点列表或者自建列表，也可以在这里面新增！
>

```c
__declspec(dllimport) char* __stdcall CreateEasytier(char* corePath, char* roomId, char* nodeUrl, char* mcPort);
```

> 调用完了之后，会在本机开放 TCP 连接，后面你需要自己循环对协议内容进行ping和校验。这边建议查看一下协议：[Scaffolding](https://github.com/Scaffolding-MC/Scaffolding-MC)\
> 协议内容待会说

2. 加入 Easytier 网络（请在加入完成之后立即发送 c:player_ping），库会帮你校验协议内容的！

> 参数列表描述和返回值与上述一致，只是唯一一点不同的就是，加入方无需对本机开放 TCP 连接！\
> 该函数将不会附带 mcPort！

```c
__declspec(dllimport) char* __stdcall JoinEasytier(char* corePath, char* roomId, char* nodeUrl);
```

3. 获取 Easytier node 内容：

> 参数列表：\
> cliPath: easytier-cli 的路径\
> 返回值：\
> Result: 如果正确 node 到，将会返回一个 JSON 格式的字符串，其中包括：\
> ```json
> {
>   "inst_id": "<STRING>", // Easytier ID
>   "hostname": "<STRING>", // 主机名
>   "ipv4_addr": "<STRING>" // 当前 IPv4 地址
> }
> ```
> 如果返回空字符串，则说明你做错了！你需要先调用 CreateEasytier 或者 JoinEasytier 之后再说！

```c
__declspec(dllimport) char* __stdcall GetEasytierNode(char* cliPath);
```

4. 销毁 Easytier 实例（并取消 TCP 组播）！

> 参数列表：空\
> 返回值：空\
> 整个 dll 唯二无返回值的函数！\
> 如果没有进行 CreateEasytier 或是 JoinEasytier，则什么也不会发生。。

```c
__declspec(dllimport) void __stdcall KillEasytierInstance();
```

## 协议相关

> 在上述函数中，已经给了各位如何获取本机识别码的信息了。这里将不再赘述！\
> 以下调用均需要在本机已经开启 TCP 之后才能调用，否则不予调用！不仅会返回一次值，还会向 TCP 服务器广播一次！也就是说，你必须调用一次 CreateEasytier 或者 JoinEasytier 之后才能使用下列函数\
> 以下函数均需要房主和房客共同调用（如果出现任何调用失败，将会返回空字符串！不会抛出报错！

1. c:player_ping

> 在协商协议之前请立即发送一次心跳包！\
> 参数列表：\
> ip: 传入上方的 IP 地址！\
> playerName：把你启动 MC 参数里面的 PlayerName 拿出来就可以了！（或者也可以填入上面的 hostname）\
> machineId: 在上述获取~\
> etInstId: 获取上述 node，之后提取出里面的 inst_id，填到这里\
> 返回值：\
> Result: 如果返回 false，则说明联机中心已退出，或者你网断了。。否则全部都是返回 true！\
> 当返回值但凡出现为 false，请立刻销毁 Easytier 实例，随后弹出弹窗警告用户！

```c
__declspec(dllimport) C_BOOL __stdcall CPlayerPing(char* ip, char* playerName, char* machineId, char* etInstId);
```

2. c:ping

> 提示：房主可以不用 ping，但是玩家必须ping

> 参数列表:\
> ip: 同上\
> str: 任意字符串\
> 返回值:\
> Result: 传什么就会得到什么。。

```c
__declspec(dllimport) char* __stdcall CPing(char* ip, char* str);
```

3. c:protocols

> 参数列表：\
> ip: 同上\
> 不用填协议列表，因为 Sandwich 默认支持 Scaffolding 的所有协议！\
> 返回值：\
> Result: 返回联机中心的所有支持的协议！由 \0 切割

```c
__declspec(dllimport) char* __stdcall CProtocol(char* ip);
```

4. c:server_port

> 由于 房主端 在前面 Create 的时候，已经输入了一次 mcPort，因此房主也可以请求这个，获得 MC 的端口！\
> 不过这个通常是由 房客端 在 Join 的时候，未知端口是多少，随后请求一次这个，得到服务器地址是：127.0.0.1:<端口>

> 参数列表：\
> ip: 同上\
> 返回值：\
> Result: 返回 MC 的端口（需要自行转换成 int）

```c
__declspec(dllimport) char* __stdcall CServerPort(char* ip);
```

5. c:player_profile_list

> 在心跳包的基础上，获取玩家列表！\
> 该函数会停滞，直到该房间内所有玩家均发送了心跳包，随后搜集所有心跳包，包装成列表并返回！（所有包的末尾会根据 hostname 自动判断是房客还是房主！）\
> 参数列表：\
> ip: 同上\
> 返回值：\
> Result: 参见上方c:player_ping心跳包，在末尾加上是房主还是房客，随后包装的列表字符串！

```c
__declspec(dllimport) char* __stdcall CPlayerProfileList(char* ip);
```

6. c:player_easytier_id

> 返回 Easytier ID，用于上方的 player ping 调用！当然，其他房客也可以通过这个函数获取到您的 easyter id！\
> 参数列表：\
> ip: 同上\
> 返回值：\
> Result: 返回 Easytier ID

```c
__declspec(dllimport) char* __stdcall CPlayerEasytierID(char* ip);
```
