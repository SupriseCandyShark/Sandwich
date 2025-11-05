unit ScaffoldingClient;

{$mode ObjFPC}{$H+}

interface
(*
 * Scaffolding 客户端单元！用于实现所有的客户端逻辑！
 *)
uses
  Classes, SysUtils, Utils;

// 房客逻辑
procedure ToBeGuest();
// 房主逻辑
procedure ToBeHost();

implementation

procedure JudgePortValid(port: String): Boolean;
var
  ProcessScan: String;
  ProcessSplitText: array of String;
  ProcessSplitLine: TStringList;
begin
  {$IF DEFINED(WINDOWS)}
  writeln('Hello World1!');
  ProcessScan := RunCommandSync(['netstat', '-anop', 'tcp', '|', 'findstr', ':' + port, '|', 'findstr', 'LISTENING']);
  writeln('Hello World2!');
  if ProcessScan = '' then
  begin
    Log.Error('Your enter port is Invalid, cannot find MC Process!');
    continue;
  end;
  ProcessSplitText := ProcessScan.Split([' ', #9, #13, #10]);
  ProcessScan := ProcessSplitText[Length(ProcessSplitText) - 1];
  writeln(ProcessScan);
  ProcessScan := RunCommandSync(['tasklist', '|', 'findstr', ProcessScan]);
  if ProcessScan = '' then
  begin
    Log.Error('Your enter port is Invalid, cannot find MC Process!');
    continue;
  end;
  ProcessSplitText := ProcessScan.Split([' ', #9, #13, #10]);
  ProcessScan :=  ProcessSplitText[0];
  writeln(ProcessScan);
  {$ELSEIF DEFINED(DARWIN)}
  ProcessScan := RunCommandSync(['', '']);
  {$ELSEIF DEFINED(LINUX)}
  ProcessScan := RunCommandSync(['', '']);
  {$ELSE}
  ProcessScan := RunCommandSync(['', '']);
  {$ENDIF}
end;

procedure ToBeGuest();
begin

end;

procedure ToBeHost();
var
  LANPort: String;
  LANPortInt: Integer;
begin
  WriteLn('I Want to be a Host! Please Enter your MC LAN Port!'#13#10'If you want to back, Please Enter ''b''');
  while True do
  begin
    ReadLn(LANPort);
    if LANPort = 'b' then
    begin
      Exit;
    end
    else
    begin
      try
        if LANPort = '' then continue;
        LANPortInt := StrToInt(LANPort);
        if (LANPortInt < 1024) or (LANPortInt > 65536) then
          raise Exception.Create('Invalid Number!');
        // 根据不同的操作系统，准确判断这个端口是否被 MC 占用！
        // 如果找到的进程不为【java.exe】或者【javaw.exe】，则抛出报错
        if not JudgePortValid(LANPort) then
        begin
          Log.Error('You Enter a Invalid Port, Cannot Find Minecraft Instance!');
          continue;
        end;
      except
        Log.Error('You Enter a Invalid Port, Please Try Again!');
      end;
    end;
  end;
end;

end.
