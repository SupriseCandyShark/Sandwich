unit DownloadMethod;

{$mode objfpc}{$H+}
interface
(*
 * 一个简单的下载文件逻辑~
 *)
uses
  FPHttpClient, opensslsockets, SysUtils, Classes, Utils, DateUtils, LogPascal;

procedure DownloadFile(AUrl, savePath: String);
function GetURL(url: String): String;

implementation

type
  TDownload = class
    class procedure OnDownloadDataReceived(Sender: TObject; const TotalDownloaded, CurrentDownloaded: Int64);
  end;

var
  LastDownloaded: Int64;
  LastTime: TDateTime;
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
      Percent := CurrentDownloaded / TotalDownloaded;
      Log.Info(Format('Percent: [%s]%, Speed: [%s]B/s, Downloaded: [%s]/[%s]', [FormatFloat('0.00', Percent), IntToStr(Round(CurrentSpeed)), IntToStr(CurrentDownloaded), IntToStr(TotalDownloaded)]));
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
