unit LogPascal;

{$mode objfpc}{$H+}
interface
(*
 * 一个简单的 Log 日志类，用于定义日志！
 *)
uses
  SysUtils;

type
  Log4P = class
  private
    FFmt: String;
  public
    property Fmt: String read FFmt write FFmt;
    constructor Create();
    procedure Info(msg: String);
    procedure Warn(msg: String);
    procedure Error(msg: String);
  end;

implementation
// Init log format like [2025-10-30 17:22:31] [Info] Hello World!
constructor Log4P.Create();
begin
  inherited Create();
  FFmt := '[{time}] [{level}] {msg}';
  DeleteFile('Log.txt');
end;

procedure Log4P.Info(msg: String);
var
  S: String;
  F: TextFile;
begin
  AssignFile(F, 'Log.txt');
  if FileExists('Log.txt') then
  begin
    Append(F);
  end
  else
  begin
    Rewrite(F);
  end;
  S := FFmt.Replace('{time}', DateTimeToStr(Now)).Replace('{level}', 'Info').Replace('{msg}', msg);
  WriteLn(F, S);
  WriteLn(msg);
  Close(F);
end;

procedure Log4P.Warn(msg: String);
var
  S: String;
  F: TextFile;
begin
  AssignFile(F, 'Log.txt');
  if FileExists('Log.txt') then
  begin
    Append(F);
  end
  else
  begin
    Rewrite(F);
  end;
  S := FFmt.Replace('{time}', DateTimeToStr(Now)).Replace('{level}', 'Warn').Replace('{msg}', msg);
  WriteLn(F, S);
  WriteLn(msg);
  Close(F);
end;

procedure Log4P.Error(msg: String);
var
  S: String;
  F: TextFile;
begin
  AssignFile(F, 'Log.txt');
  if FileExists('Log.txt') then
  begin
    Append(F);
  end
  else
  begin
    Rewrite(F);
  end;
  S := FFmt.Replace('{time}', DateTimeToStr(Now)).Replace('{level}', 'Error').Replace('{msg}', msg);
  WriteLn(F, S);
  WriteLn(msg);
  Close(F);
end;

end.
