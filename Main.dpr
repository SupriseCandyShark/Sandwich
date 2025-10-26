program main;

{$mode objfpc}{$H+}
{$IFDEF MSWINDOWS}
  {$IFDEF WIN32}
    {$R openssl32.res}
  {$ELSE}
    {$R openssl64.res}
  {$ENDIF}
{$ENDIF}

uses
  Utils in 'utils/Utils.pas',
  fphttpclient, sslsockets, opensslsockets, fpJSON, sysutils, classes, JSONParser
  {$IFDEF MSWINDOWS}
  , Windows
  {$ENDIF};
{$IFDEF MSWINDOWS}
procedure ExtractOpensSLLibs();
var
  LIBEAY32Dll: TResourceStream;
  SSLEAY32Dll: TResourceStream;
begin
  if not FileExists(PathJoin([GetCurrentDir(), 'libeay32.dll'])) then
  begin
    try
      LIBEAY32Dll := TResourceStream.Create(HInstance, PChar('LIBEAY32'), RT_RCDATA);
      LIBEAY32Dll.SaveToFile(PathJoin([GetCurrentDir(), 'libeay32.dll']));
    finally
      LIBEAY32Dll.Free;
    end;
  end;
  if not FileExists(PathJoin([GetCurrentDir(), 'ssleay32.dll'])) then
  begin
    try
      SSLEAY32Dll := TResourceStream.Create(HInstance, PChar('SSLEAY32'), RT_RCDATA);
      SSLEAY32Dll.SaveToFile(PathJoin([GetCurrentDir(), 'ssleay32.dll']));
    finally
      SSLEAY32Dll.Free;
    end;
  end;
end;
{$ENDIF}
var
  JSONData: TJSONData;
  URL: String;
  S: TStringStream;
begin
  {$IFDEF MSWINDOWS}
  ExtractOpensSLLibs;
  {$ENDIF}
  S := TStringStream.Create();
  URL := 'https://piston-meta.mojang.com/mc/game/version_manifest_v2.json';
  with TFPHttpClient.Create(Nil) do
    try
      Get(URL, S);
    finally
      Free;
    end;
  Writeln(S.DataString);
  try
    JSONData := GetJSON(S.DataString);
  except
    on E: Exception do
    begin
      writeln(E.Message);
    end;
  end;
end.
