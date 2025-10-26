unit Utils;

interface

uses
  sysutils, classes;

// 根据系统拼接路径
function PathJoin(pathname: array of string): string;
// 获取当前可执行文件路径
function GetCurrentDir(): string;

implementation

function PathJoin(pathname: array of string): string;
var
  i: Integer;
begin
  PathJoin := '';
  for i := 0 to Length(pathname) - 1 do
  begin
    if i = Length(pathname) - 1 then 
      PathJoin := PathJoin + pathname[i]
    else
      PathJoin := PathJoin + pathname[i] + {$IFDEF MSWINDOWS}'\'{$ELSE}'/'{$ENDIF};
  end;
end;

function GetCurrentDir(): string;
begin
  GetCurrentDir := ExtractFileDir(ParamStr(0));
end;

end.