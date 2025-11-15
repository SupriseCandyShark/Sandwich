unit DownloadMethod;

{$mode objfpc}{$H+}
interface
(*
 * 一个简单的下载文件逻辑~
 *)
uses
  FPHttpClient, opensslsockets, SysUtils, Classes, Utils, DateUtils, LogPascal;

// 下载 HTTP 内容
procedure DownloadFile(AUrl, savePath: String);
// 只是一个普通的获取 网站 内容的一个函数。。
function GetURL(url: String): String;

implementation

type
  TDownload = class
    class procedure OnDownloadDataReceived(Sender: TObject; const TotalDownloaded, CurrentDownloaded: Int64);
  end;

var
  LastDownloaded: Int64;
  LastTime: TDateTime;
// 字节转换成 B、KB、MB、GB、TB 类型
function BytesToStr(Bytes: Int64): string;
const
  Units: array[0..4] of string = ('B', 'KB', 'MB', 'GB', 'TB');
var
  i: Integer;
  Value: Extended;
begin
  if Bytes < 1024 then
  begin
    Result := IntToStr(Bytes) + ' B';
    Exit;
  end;
  Value := Bytes;
  i := 0;
  while (Value >= 1024) and (i < High(Units)) do
  begin
    Value := Value / 1024;
    Inc(i);
  end;
  Result := Format('%.2f %s', [Value, Units[i]]);
end;
class procedure TDownload.OnDownloadDataReceived(Sender: TObject; const TotalDownloaded, CurrentDownloaded: Int64);
var
  ElapsedTime: Double;
  CurrentSpeed: Double;
  Percent: Double;
begin
  if TotalDownloaded > 0 then
  begin
    ElapsedTime := (Now - LastTime) * 24 * 60 * 60;
    if ElapsedTime >= 1.0 then
    begin
      CurrentSpeed := (CurrentDownloaded - LastDownloaded) / ElapsedTime;
      Percent := CurrentDownloaded / TotalDownloaded * 100;
      Log.Info(Format('Percent: %s%%, Speed: %s/s, Downloaded: %s/%s', [FormatFloat('0', Percent), BytesToStr(Round(CurrentSpeed)), BytesToStr(CurrentDownloaded), BytesToStr(TotalDownloaded)]));
      LastDownloaded := CurrentDownloaded;
      LastTime := Now;
    end;
  end;
end;
procedure DownloadFile(AUrl, savePath: String);
var
  ResponseStream: TMemoryStream;
begin
  with TFPHttpClient.Create(nil) do
  begin
    try
      LastDownloaded := 0;
      LastTime := Now;
      ResponseStream := TMemoryStream.Create();
      OnDataReceived := @TDownload.OnDownloadDataReceived;
      Log.Info('Start Download: ' + AUrl);
      Get(AUrl, ResponseStream);         
      Log.Info('Download Finish!, Total Byte: ' + IntToStr(ResponseStream.Size));
      ResponseStream.SaveToFile(savePath);
    finally
      ResponseStream.Free;
      Free;
    end;
  end;
end;
function GetURL(url: String): String;
begin
  with TFPHttpClient.Create(nil) do
  begin
    try
      Result := Get(url);
    finally
      Free;
    end;
  end;
end;

end.
