unit ScaffoldingClient;

{$mode ObjFPC}{$H+}

interface
(*
 * Scaffolding 客户端单元！用于实现所有的客户端逻辑！
 *)
uses
  Classes, SysUtils, Utils, LogPascal, SocketHandler;

// 房客逻辑
procedure ToBeGuest();
// 房主逻辑
procedure ToBeHost();

implementation

procedure ToBeGuest();
begin

end;

procedure ToBeHost();
var
  LANPort: String;
  LANPortInt: Integer;
begin
  // WriteLn('I Want to be a Host! Please Enter your MC LAN Port!'#13#10'If you want to back, Please Enter ''b''');
  // while True do
  // begin
    // ReadLn(LANPort);
  Log.Info('Start to search your Minecraft instance! Please make sure you are open Minecraft and Open to LAN!');
  LANPort := GetMCPort();
  try
    LANPortInt := StrToInt(LANPort);
  except
    Log.Warn('Cannot find your MC Instance Port, Please Enter your MC Port manual!');
    Readln(LANPort);
    try
      LANPortInt := StrToInt(LANPort);
      if (LANPortInt < 1024) or (LANPortInt > 65536) then raise Exception.Create(''); 
    except
      Log.Error('Your Enter is wrong, Please Try again!');
      Exit;
    end;
  end;
  Log.Info('Your MC Port is ' + LANPort + ', Then Try to open TCP LAN and Open Easytier Program!');
  Exit;
  // end;
end;

end.
