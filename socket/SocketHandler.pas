unit SocketHandler;

{$mode objfpc}{$H+}
interface

uses
  SysUtils, Classes, Sockets;

function GetMCPort(): String;

implementation

type
  Ip_Mreq = record
    imr_multiaddr: In_Addr;
    imr_interface: In_Addr;
  end;
  Ipv6_Mreq = record
    ipv6mr_multiaddr: In6_Addr;
    ipv6mr_interface: DWORD;
  end;

function GetMCPort(): String;
var
  // IP 相关
  socket: LongInt;
  socket6: LongInt;
  addr: TInetSockAddr;
  addr6: TInetSockAddr6;
  mreq: Ip_Mreq;
  mreq6: Ipv6_Mreq;
  fromAddr: TInetSockAddr;
  fromAddr6: TInetSockAddr6;
  // 辅助相关
  buffer: array [0..4095] of Char;
  fromLen: TSockLen;
  len: LongInt;
  ResultString: String;
  count: Integer;
begin
  Result := '';

  // 绑定固定端口，进行 Udp 连接
  socket := fpSocket(AF_INET, SOCK_DGRAM, 0);
  if (socket < 0) then begin Result := 'A'; Exit; end;
  socket6 := fpSocket(AF_INET6, SOCK_DGRAM, 0);
  if (socket6 < 0) then begin Result := 'B'; Exit; end;

  addr.sin_family := AF_INET;
  addr.sin_port := hTons(4445);
  addr.sin_addr.s_addr := hTonl(INADDR_ANY);

  addr6.sin6_family := AF_INET6;
  addr6.sin6_port := hTons(4445);
  addr6.sin6_addr := StrToNetAddr6('::1');

  if fpBind(socket, @addr, SizeOf(addr)) < 0 then begin Result := 'C'; Exit; end;

  if fpBind(socket6, @addr6, SizeOf(addr6)) < 0 then begin Result := 'D'; Exit; end;

  // 加入到多播组
  mreq.imr_multiaddr := StrToNetAddr('224.0.2.60');
  mreq.imr_interface.s_addr := hTonl(INADDR_ANY);
  if fpSetSockOpt(socket, IPPROTO_IP, IP_ADD_MEMBERSHIP, @mreq, SizeOf(mreq)) < 0 then begin Result := 'E'; Exit; end;

  mreq6.ipv6mr_interface := 0;
  mreq6.ipv6mr_multiaddr := StrToNetAddr6('ff75:230::60');
  if fpSetSockOpt(socket6, IPPROTO_IPV6, IPV6_ADD_MEMBERSHIP, @mreq6, SizeOf(mreq6)) < 0 then begin Result := 'F'; Exit; end;

  if SocketError <> 0 then begin Result := 'G'; Exit; end;

  // 开始计数
  count := 0;
  // 开始监听信息
  while True do
  begin
    fromLen := SizeOf(fromAddr);
    len := fpRecvFrom(socket, @buffer, SizeOf(buffer), 0, @fromAddr, @fromLen);
    if len > 0 then
    begin
      SetString(ResultString, buffer, len);
      Result := ResultString.SubString(ResultString.IndexOf('[AD]') + 4);
      Result := Result.SubString(0, Result.IndexOf('[/AD]'));
      Exit;
    end;
    fromLen := SizeOf(fromAddr6);
    len := fpRecvFrom(socket6, @buffer, SizeOf(buffer), 0, @fromAddr6, @fromLen);
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
end;

end.
