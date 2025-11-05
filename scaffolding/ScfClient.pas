unit ScfClient;

{$mode ObjFPC}{$H+}

interface
(*
 * Scaffolding 客户端单元！用于实现所有的客户端逻辑！
 *)
uses
  Classes, SysUtils, Utils, SocketHandler;

// 房客逻辑
procedure ToBeGuest();
// 房主逻辑
procedure ToBeHost();

implementation

// 检查端口是否输入错误，对 localhost 发送 Motd 请求，接受返回值，如果接受到了 Motd，则返回 true，否则返回 false！
function CheckPort(port: String): Boolean;
begin

end;
// 扫描端口，发送 Udp 组播请求，直到接受到任意返回值，则返回【端口号】，在发送 Udp 组播并得到任何返回值之后，会检查端口是否有误一次！
// 如果超时的话，（默认30秒）则返回空字符串！
function ScanPort(seconds: Integer = 300000): String;
// var

begin

  // {$IF DEFINED(WINDOWS)}
  // writeln('Hello World1!');
  // ProcessScan := RunCommandSync(['netstat', '-anop', 'tcp', '|', 'findstr', ':' + port, '|', 'findstr', 'LISTENING']);
  // writeln('Hello World2!');
  // if ProcessScan = '' then
  // begin
  //   Log.Error('Your enter port is Invalid, cannot find MC Process!');
  //   continue;
  // end;
  // ProcessSplitText := ProcessScan.Split([' ', #9, #13, #10]);
  // ProcessScan := ProcessSplitText[Length(ProcessSplitText) - 1];
  // writeln(ProcessScan);
  // ProcessScan := RunCommandSync(['tasklist', '|', 'findstr', ProcessScan]);
  // if ProcessScan = '' then
  // begin
  //   Log.Error('Your enter port is Invalid, cannot find MC Process!');
  //   continue;
  // end;
  // ProcessSplitText := ProcessScan.Split([' ', #9, #13, #10]);
  // ProcessScan :=  ProcessSplitText[0];
  // writeln(ProcessScan);
  // {$ELSEIF DEFINED(DARWIN)}
  // ProcessScan := RunCommandSync(['', '']);
  // {$ELSEIF DEFINED(LINUX)}
  // ProcessScan := RunCommandSync(['', '']);
  // {$ELSE}
  // ProcessScan := RunCommandSync(['', '']);
  // {$ENDIF}
end;

procedure ToBeGuest();
begin

end;

procedure ToBeHost();
var
  ServerPort: String;
//  LANPort: String;
//  LANPortInt: Integer;
begin
  WriteLn('I Want to be a Host! Please Enter your MC LAN Port!'#13#10'If you want to back, Please Enter ''b''');
  while True do
  begin
    ReadLn(ServerPort);
    if ServerPort = 'b' then
    begin
      Exit;
    end
    else
    begin
      try
        // 开始检测端口
        ServerPort := ScanPort();
        if (StrToInt(ServerPort) >= 1024) and (StrToInt(ServerPort) < 65536) then
        begin

        end
        else
        begin
          Log.Warn('Scan Port Failed!, Try to input manual:');
          ReadLn(ServerPort);
          if (StrToInt(ServerPort) < 1024) or (StrToInt(ServerPort) > 65535) then
          begin
            Log.Error('Your Enter a Invalid Number, Please Try again!');
            continue;
          end;
          if CheckPort(ServerPort) then
          begin

          end;
        end;
        //if LANPort = '' then continue;
        //LANPortInt := StrToInt(LANPort);
        //if (LANPortInt < 1024) or (LANPortInt > 65536) then
        //  raise Exception.Create('Invalid Number!');
        // 根据不同的操作系统，准确判断这个端口是否被 MC 占用！
        // 如果找到的进程不为【java.exe】或者【javaw.exe】，则抛出报错
        //if not JudgePortValid(LANPort) then
        //begin
        //  Log.Error('You Enter a Invalid Port, Cannot Find Minecraft Instance!');
        //  continue;
        //end;
      except
        Log.Error('Scan Port Failed!, Try again Later!');
      end;
    end;
  end;
end;

end.
