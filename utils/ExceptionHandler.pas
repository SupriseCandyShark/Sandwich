unit ExceptionHandler;

{$mode objfpc}{$H+}
interface
(*
 * 定义了一个自定义异常类，用于抛出错误信息和错误代码。
 *)

uses
  Generics.Collections, SysUtils;

type
  generic TMyExceptionHandler<T> = class(Exception)
  private
    FMyMessage: String;
    FCode: Integer;
    FData: T;
    FStatus: Boolean;
  public
    property MyMessage: String read FMyMessage write FMyMessage;
    property ErrCode: Integer read FCode write FCode;
    property Data: T read FData write FData;
    property Status: Boolean read FStatus write FStatus;
    constructor CreateSuccess(const AData: T);
    constructor CreateError(const ACode: Integer; const AMsg: String);
    function FormatError: String;
  end;

implementation

constructor TMyExceptionHandler.CreateSuccess(const AData: T);
begin
  inherited Create('Success!');
  FMyMessage := 'Success!';
  FStatus := True;
  FData := AData;
  FCode := 200;
end;

constructor TMyExceptionHandler.CreateError(const ACode: Integer; const AMsg: String);
begin
  inherited Create(AMsg);
  FMyMessage := AMsg;
  FStatus := False;
  FCode := ACode;
  // FData := nil;
end;

function TMyExceptionHandler.FormatError: String;
begin
  Result := Format('Code: %d, Error: %s', [FCode, FMyMessage]);
end;
end.

