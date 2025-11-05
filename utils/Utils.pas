unit Utils;

{$mode objfpc}{$H+}
interface
(*
 * 一个包装单元，用于各种字符串处理等逻辑~
 *)
uses
  SysUtils, Classes, Math, StrUtils, RegExpr, LogPascal, Process, md5;

type
  generic TArray<T> = array of T;
  TStringArray = specialize TArray<String>;
var
  Log: Log4P;
// 根据系统拼接路径
function PathJoin(pathname: array of String): String;
// 获取当前可执行文件路径
function GetCurrentDir(): String;
// 生成房间ID
function GenerateRoomId(): String;
// 判断房间ID是否合法
function JudgeRoomId(roomId: String): Boolean;
// 获取联机网络基本请求信息（返回2个值，网络名称和密钥）
function GetNetworkStandardsInfo(roomId: String): TStringArray;
// 获取机器码
function GetMachineCode(): String;
// 同步运行 cmd 命令（在跑 easytier-core 的时候，不要使用这个！除非在外面包一层 Thread！）
function RunCommandSync(cmd: TStringArray; dir: String = ''): String;

implementation

function RunCommandSync(cmd: TStringArray; dir: String = ''): String;
var
  i: Integer;
begin
  if dir = '' then dir := GetCurrentDir();
  Result := '';
  if Length(cmd) = 0 then Exit;
  with TProcess.Create(nil) do
  begin
    try
      CurrentDirectory := dir;
      Executable := cmd[0];
      for i := 1 to Length(cmd) - 1 do
      begin
        Parameters.Add(cmd[i]);
      end;
      Options := [poUsePipes, poWaitOnExit, poNoConsole];
      Execute;
      with TStringStream.Create do begin
        try
          CopyFrom(Output, 0);
          Result := DataString;
        finally
          Free;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

// 获取机器码（请记住，在 Linux 和 FreeBSD 里，使用 cat /etc/machine-id 获取机器码，这种方式可能不安全，且有可能被用户自主修改。。）
// 目前正在努力找一个【用户无法修改、每台机器唯一】的获取机器码的方式！
// 以下方式为获取到机器码之后，顺手将其 MD5 化了（
function GetMachineCode(): String;
var
  output: String;
begin
  {$IF DEFINED(WINDOWS)}
  output := RunCommandSync(['wmic', 'csproduct', 'get', 'uuid']);
  Result := MD5Print(MD5String(output)).ToUpper;
  {$ELSEIF DEFINED(DARWIN)}
  output := RunCommandSync(['system_profiler', 'SPHardwareDataType', '|', 'grep', 'Hardware UUID']);
  Result := MD5Print(MD5String(output)).ToUpper;
  {$ELSE}
  output := RunCommandSync(['cat', '/etc/machine-id']);
  Result := MD5Print(MD5String(output)).ToUpper;
  {$ENDIF}
  //Result := '';
end;

// 房间码检索字符串
const
  RoomIdChars: String = '0123456789ABCDEFGHJKLMNPQRSTUVWXYZ';
function RoomIdIndex(AValue: Char): Integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to Length(RoomIdChars) - 1 do
  begin
    if RoomIdChars[i] = AValue then
    begin
      Result := i;
      Break;
    end;
  end;
end;
// 路径拼接
function PathJoin(pathname: array of String): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Length(pathname) - 1 do
  begin
    if i = Length(pathname) - 1 then
      Result := Result + pathname[i]
    else
      Result := Result + pathname[i] + {$IFDEF MSWINDOWS}'\'{$ELSE}'/'{$ENDIF};
  end;
end;
// 是否能整除 7
function IsDivided7(str: String): Boolean;
var
  i: Integer;
  total: Extended;
  cur: Extended;
  arr: array of Char;
begin
  Result := False;
  total := 0;
  arr := str.ToCharArray();
  for i := 0 to Length(arr) - 1 do
  begin
    cur := RoomIdIndex(arr[i]);
    if cur = -1 then Exit;
    total := (total * Length(RoomIdChars) + cur);
  end;
  Result := total mod 7 = 0;
end;

// 获取当前文件夹
function GetCurrentDir(): String;
begin
  Result := ExtractFileDir(ParamStr(0));
end;
function JudgeRoomId(roomId: string): Boolean;
begin
  Result := False;
  if LeftStr(roomId, 2) <> 'U/' then Exit;
  roomId := roomId.Replace('U/', '');
  with TRegExpr.Create('^([A-HJ-NP-Z0-9]{4}-){3}[A-HJ-NP-Z0-9]{4}$') do
  begin
    try
      if not Exec(roomId) then Exit;
      roomId := roomId.Replace('-', '');
      Result := IsDivided7(roomId);
    finally
      Free;
    end;
  end;
end;

function GenerateRoomId(): String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to 14 do
  begin
    Result := Result + RoomIdChars[Random(Length(RoomIdChars))];
    if (i = 3) or (i = 7) or (i = 11) then
      Result := Result + '-';
  end;
  for i := 0 to Length(RoomIdChars) - 1 do
  begin
    if IsDivided7(Result.Replace('-', '') + String(RoomIdChars[i])) then
    begin
      Result := 'U/' + Result + String(RoomIdChars[i]);
    end;
  end;
end;

function GetNetworkStandardsInfo(roomId: String): TStringArray;
begin
  SetLength(Result, 2);
  Result[0] := 'scaffolding-mc-' + roomId.Replace('U/', '').Substring(0, 9);
  Result[1] := roomId.Substring(12);
end;
end.
