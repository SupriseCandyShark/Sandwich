program PascalScaffolding;

(*
 * Hi！这里是 xphost！
 * 很令人感到兴奋！因为我重新拾取了我对 Pascal 的热爱！
 * 那么，这里是 Scaffolding 的 Free Pascal 实现源码，在许可证允许的范围内，尽情使用它！
 *)
{$mode objfpc}{$H+}
{
{$IF NOT DEFINED(NO_OPENSSL) AND DEFINED(WIN64)}
{$R openssl.res}
{$ENDIF}
//}

uses
  {$IFDEF UNIX}
  // unix 通用类库
  cthreads,
  {$ENDIF}
  SysUtils,
  Classes,
  SocketHandler in 'socket/SocketHandler.pas'
  {
  RegExpr,
  Zipper,
  Utils in 'utils/Utils.pas',
  ExceptionHandler in 'utils/ExceptionHandler.pas',
  DownloadMethod in 'utils/DownloadMethod.pas',
  LogPascal in 'utils/LogPascal.pas',
  ScfClient in 'scaffolding/ScfClient.pas',
  {$IF NOT DEFINED(NO_OPENSSL) AND DEFINED(WIN64)}
  // 解压 libeay32 和 ssleay32 时需要用到 Windows 类库。。
  , Windows
  {$ENDIF}//};

// 判断操作系统是否为 Windows x86_64，如果是，则解压一次 libeay32 和 ssleay32！
// 同时判断是否启用了 NO_OPENSSL，如果启用了，则默认不会解压 libeay32 和 ssleay32！
{
{$IF NOT DEFINED(NO_OPENSSL) AND DEFINED(WIN64)}
procedure ExtractOpensSLLibs();
begin
  // 首先判断一次 libeay32.dll 和 ssleay32.dll 是否都存在，如果有任一不存在，则开始尝试解压！
  if not FileExists(PathJoin([GetCurrentDir(), 'libeay32.dll'])) then
  begin
    Log.Warn('Not detected libeay32.dll, Current Extract!');
    with TResourceStream.Create(HInstance, PChar('LIBEAY32'), RT_RCDATA) do
    begin
      try
        SaveToFile(PathJoin([GetCurrentDir(), 'libeay32.dll']));
      finally
        Free;
      end;
    end;
  end;
  if not FileExists(PathJoin([GetCurrentDir(), 'ssleay32.dll'])) then
  begin
    Log.Warn('Not detected ssleay32.dll, Current Extract!');
    with TResourceStream.Create(HInstance, PChar('SSLEAY32'), RT_RCDATA) do
    begin
      try
        SaveToFile(PathJoin([GetCurrentDir(), 'ssleay32.dll']));
      finally
        Free;
      end;
    end;
  end;
end;
{$ENDIF}
//}
{
var
  UserInput: String;
  URLGetContent: String;
  RealDownloadURL: String;
  FileName: String;
  FileExt: String;
  WantTo: String;
//}
begin
  // writeln('Hello World!');
  writeln(GetMCPort());
  Exit;
  {
  Log := Log4P.Create();
  Log.Info('Sandwich Is Launched!!');
  {$IF NOT DEFINED(NO_OPENSSL) AND DEFINED(WIN64)}
  ExtractOpensSLLibs;
  {$ENDIF}
  FileName :=
  {$IF DEFINED(WINDOWS) AND DEFINED(CPUX86_64)}
  'windows-x86_64'
  {$ELSEIF DEFINED(WINDOWS) AND (DEFINED(CPUAARCH64) OR DEFINED(CPUARM))}
  'windows-arm64'
  {$ELSEIF DEFINED(LINUX) AND DEFINED(CPUX86_64)}
  'linux-x86_64'
  {$ELSEIF DEFINED(LINUX) AND DEFINED(CPUAARCH64)}
  'linux-aarch64'
  {$ELSEIF DEFINED(DARWIN) AND DEFINED(CPUX86_64)}
  'macos-x86_64'
  {$ELSEIF DEFINED(DARWIN) AND DEFINED(CPUAARCH64)}
  'macos-aarch64'
  {$ELSEIF DEFINED(FREEBSD) AND DEFINED(CPUX86_64)}
  'freebsd-13.2-x86_64'
  {$ELSE}
  'unknown' // This Line will be mismatch!
  {$ENDIF}
  ;
  // 定义文件后缀名
  FileExt := {$IFDEF WINDOWS}'.exe'{$ELSE}''{$ENDIF};
  // 接下来判断是否存在 easytier-core 和 easytier-cli 两个核心文件，这是核心数据！
  if (not FileExists(PathJoin([GetCurrentDir(), 'easytier-core' + FileExt]))) or (not FileExists(PathJoin([GetCurrentDir(), 'easytier-cli' + FileExt])))
  // 在 Windows 上额外判断一次是否包含 Packet.dll、wintun.dll，这也是个关键类库~
  {$IFDEF WINDOWS}
  or (not FileExists(PathJoin([GetCurrentDir(), 'Packet.dll']))) or (not FileExists(PathJoin([GetCurrentDir(), 'wintun.dll'])))
  {$ENDIF}
  then
  begin
    Log.Warn(
      'Maybe you are not install easytier core! if you want to download by this progream, press ''Y''.'#13#10'or, you also can download by manual and put [easytier-core, easytier-cli, Packet.dll(if you are Windows)] by the executable file same path!');
    ReadLn(UserInput);
    if UserInput = 'y' then
    begin
      // 获取 Easytier 下载链接
      Log.Info('Get Version in Official Website!');
      URLGetContent := GetURL('https://easytier.cn/guide/download.html');
      with TRegExpr.Create('https://[a-zA-Z0-9./_-]*?\.zip') do
      begin
        if Exec(URLGetContent) then
        begin
          repeat
            if Match[0].IndexOf(FileName) <> -1 then
            begin
              Log.Info('Already get URL, Then start download!');
              RealDownloadURL := Concat('https://ghfast.top/', Match[0]);
              break;
            end;
          until not ExecNext;
        end;
      end;
      // 下载并解压文件~
      DownloadFile(RealDownloadURL, PathJoin([GetCurrentDir(), 'easytier.zip']));
      if FileExists(PathJoin([GetCurrentDir(), 'easytier.zip'])) then
      begin
        Log.Info('Extract Zip...');
        with TUnZipper.Create do
        begin
          try
            FileName := PathJoin([GetCurrentDir(), 'easytier.zip']);
            OutputPath := GetCurrentDir();
            UnzipAllFiles();
          finally
            Free;
          end;
        end;
        // 移除文件
        {$IFDEF WINDOWS}
        RenameFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' + FileName, 'Packet.dll'])), PChar(PathJoin([GetCurrentDir(), 'Packet.dll'])));
        RenameFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' + FileName, 'wintun.dll'])), PChar(PathJoin([GetCurrentDir(), 'wintun.dll'])));
        DeleteFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' + FileName, 'wintun.dll'])));
        DeleteFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' + FileName, 'Packet.dll'])));
        {$ENDIF}
        // 修改文件路径
        RenameFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' +
          FileName, 'easytier-core' + FileExt])),
          PChar(PathJoin([GetCurrentDir(), 'easytier-core' + FileExt])));
        RenameFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' +
          FileName, 'easytier-cli' + FileExt])),
          PChar(PathJoin([GetCurrentDir(), 'easytier-cli' + FileExt])));
        DeleteFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' +
          FileName, 'easytier-core' + FileExt])));
        DeleteFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' +
          FileName, 'easytier-cli' + FileExt])));
        DeleteFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' +
          FileName, 'easytier-web' + FileExt])));
        DeleteFile(PChar(PathJoin([GetCurrentDir(), 'easytier-' +
          FileName, 'easytier-web-embed' + FileExt])));
        RemoveDir(PChar(PathJoin([GetCurrentDir(), 'easytier-' + FileName])));
        Log.Info('Extract Finish!!');
        // 删除主 zip 文件
        DeleteFile(PChar(PathJoin([GetCurrentDir(), 'easytier.zip'])));
      end
      else
      begin
        Log.Error('Download Failed!');
        Exit;
      end;
    end
    else
      Exit;
  end;
  // 以下为正式开始逻辑！
  WriteLn('Welcome To Sandwich! Please Enter a number what you want to do:'#13#10'1. I want to be a Host!'#13#10'2. I want to be a Guest!'#13#10'q: I dont want to play, please Exit!');
  while True do
  begin
    ReadLn(WantTo);
    if WantTo = '1' then
    begin
      ToBeHost();
      WriteLn('Welcome To Sandwich! Please Enter a number what you want to do:'#13#10'1. I want to be a Host!'#13#10'2. I want to be a Guest!'#13#10'q: I dont want to play, please Exit!');
    end
    else if WantTo = '2' then
    begin
      ToBeGuest();
      WriteLn('Welcome To Sandwich! Please Enter a number what you want to do:'#13#10'1. I want to be a Host!'#13#10'2. I want to be a Guest!'#13#10'q: I dont want to play, please Exit!');
    end
    else if WantTo = 'q' then
    begin
      break;
    end;
  end;
  //}
end.
