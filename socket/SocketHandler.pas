unit SocketHandler;

{$mode objfpc}{$H+}
interface

uses
  SysUtils, Classes, {$IFDEF WINDOWS}WinSock2, {$ENDIF}Sockets;

function GetMCPort(): String;
implementation

{$IF DEFINED(WINDOWS) OR DEFINED(DARWIN)}
const
  IPPROTO_IPV6 = 41;
{$ENDIF}
{$IF NOT DEFINED(LINUX)}
const
  IPV6_ADD_MEMBERSHIP = 12;
{$ENDIF}
{$IFDEF WINDOWS}
const
  IP_ADD_MEMBERSHIP = 12;
  IN6ADDR_ANY = 0;
{$ENDIF}

type
  Ip_Mreq = record
    imr_multiaddr: In_Addr;
    imr_interface: In_Addr;
  end;
  Ipv6_Mreq = record
    ipv6mr_multiaddr: In6_Addr;
    ipv6mr_interface: DWORD;
  end;
{$IFDEF WINDOWS}
function MAKEWORD(low, high: Byte): Word;
begin
  Result := high shl 8 + low;
end;
{$ENDIF}
function GetMCPort(): String;
var
  // Windows 相关
  {$IFDEF WINDOWS}
  WSAData: TWSAData;
  {$ENDIF}
  // IP 相关
  socket4: {$IFDEF WINDOWS}TSocket{$ELSE}LongInt{$ENDIF};
  socket6: LongInt;
  addr: {$IFDEF WINDOWS}SockAddr_In{$ELSE}TInetSockAddr{$ENDIF};
  addr6: {$IFDEF WINDOWS}SockAddr_In6{$ELSE}TInetSockAddr6{$ENDIF};
  mreq: Ip_Mreq;
  mreq6: Ipv6_Mreq;
  fromAddr: {$IFDEF WINDOWS}SockAddr_In{$ELSE}TInetSockAddr{$ENDIF};
  fromAddr6: {$IFDEF WINDOWS}SockAddr_In6{$ELSE}TInetSockAddr6{$ENDIF};
  // 辅助相关
  buffer: array [0..4095] of Char;
  fromLen: TSockLen;
  len: LongInt;
  ResultString: String;
  count: Integer;
begin
  Result := '';
  // Windows 相关
  {$IFDEF WINDOWS}
  if WSAStartup(MAKEWORD(2, 2), WSAData) <> 0 then
  begin
    Result := 'Z' + IntToStr(WSAGetLastError);
    Exit;
    // Writeln('WSAStartup failed. Error: ', WSAGetLastError);
    // Halt(1);
  end;
  {$ENDIF}
  try
    // 绑定固定端口，进行 Udp 连接
    socket4 := {$IFDEF WINDOWS}socket{$ELSE}fpSocket{$ENDIF}(AF_INET, SOCK_DGRAM, 0);
    if (socket4 < 0) then begin Result := 'A' + IntToStr(SocketError); Exit; end;
    // 开始 bind 链接
    addr.sin_family := AF_INET;
    addr.sin_port := hTons(4445);
    addr.sin_addr.s_addr := hTonl(INADDR_ANY);
    if {$IFDEF WINDOWS}bind{$ELSE}fpBind{$ENDIF}(socket4, @addr, SizeOf(addr)) < 0 then begin Result := 'B' + IntToStr(SocketError); Exit; end;
    // 加入到多播组
    mreq.imr_multiaddr := StrToNetAddr('224.0.2.60');
    mreq.imr_interface.s_addr := hTonl(INADDR_ANY);
    if {$IFDEF WINDOWS}setSockOpt{$ELSE}fpSetSockOpt{$ENDIF}(socket4, IPPROTO_IP, IP_ADD_MEMBERSHIP, @mreq, SizeOf(mreq)) < 0 then begin Result := 'C' + IntToStr(SocketError); Exit; end;
    // 下列 IPv6 同理
    socket6 := {$IFDEF WINDOWS}socket{$ELSE}fpSocket{$ENDIF}(AF_INET6, SOCK_DGRAM, 0);
    if (socket6 < 0) then begin Result := 'D' + IntToStr(SocketError); Exit; end;
    addr6.sin6_family := AF_INET6;
    addr6.sin6_port := hTons(4445);
    addr6.sin6_addr := StrToNetAddr6('::1');
    if {$IFDEF WINDOWS}bind{$ELSE}fpBind{$ENDIF}(socket6, @addr6, SizeOf(addr6)) < 0 then begin Result := 'F' + IntToStr(SocketError); Exit; end;
    mreq6.ipv6mr_interface := 0;
    mreq6.ipv6mr_multiaddr := StrToNetAddr6('ff75:230::60');
    if {$IFDEF WINDOWS}setSockOpt{$ELSE}fpSetSockOpt{$ENDIF}(socket6, IPPROTO_IPV6, IPV6_ADD_MEMBERSHIP, @mreq6, SizeOf(mreq6)) < 0 then begin Result := 'E' + IntToStr(SocketError); Exit; end;
    if SocketError <> 0 then begin Result := 'G' + IntToStr(SocketError); Exit; end;
    // 开始计数
    count := 0;
    // 开始监听信息
    while True do
    begin
      fromLen := SizeOf(fromAddr);
      len := {$IFDEF WINDOWS}recvFrom{$ELSE}fpRecvFrom{$ENDIF}(socket4, @buffer, SizeOf(buffer), 0, @fromAddr, @fromLen);
      if len > 0 then
      begin
        SetString(ResultString, buffer, len);
        Result := ResultString.SubString(ResultString.IndexOf('[AD]') + 4);
        Result := Result.SubString(0, Result.IndexOf('[/AD]'));
        Exit;
      end;
      fromLen := SizeOf(fromAddr6);
      len := {$IFDEF WINDOWS}recvFrom{$ELSE}fpRecvFrom{$ENDIF}(socket6, @buffer, SizeOf(buffer), 0, @fromAddr6, @fromLen);
      if len > 0 then
      begin
        SetString(ResultString, buffer, len);
        Result := ResultString.SubString(ResultString.IndexOf('[AD]') + 4);
        Result := Result.SubString(0, Result.IndexOf('[/AD]'));
        Exit;
      end;
      if count = 60 then
      begin
        Result := 'Sorry, Cannot find your Port, Please Enter it manual:';
        Exit;
      end;
      Sleep(1000);
      count := count + 1;
    end;
  finally
    {$IFDEF WINDOWS}
    WSACleanup;
    {$ENDIF}
    CloseSocket(socket4);
    CloseSocket(socket6);
  end;
end;

end.
