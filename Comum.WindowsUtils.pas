unit Comum.WindowsUtils;

interface

uses
  Windows, Forms, SysUtils, ShellAPI;

type
  IWindowsUtils = interface
    ['{99AA9859-B23F-4736-91EA-4D5B992679DB}']
    function getTempFile(const Extension: string): string;
    procedure OpenFile(AFile: TFileName; TypeForm: Integer = SW_NORMAL);
    procedure OpenFileAndWait(AFile: TFileName; TypeForm: Integer = SW_NORMAL);    
    function ShellExecuteAndWait(Operation, FileName, Parameter, Directory: PAnsiChar; Show: Word; bWait: Boolean): Longint;
  end;

  TWindowsUtils = class(TInterfacedObject, IWindowsUtils)
  public
    class function new(): IWindowsUtils;
    function getTempFile(const Extension: string): string;
    procedure OpenFile(AFile: TFileName; TypeForm: Integer = SW_NORMAL);
    procedure OpenFileAndWait(AFile: TFileName; TypeForm: Integer = SW_NORMAL);
    function ShellExecuteAndWait(Operation, FileName, Parameter, Directory: PAnsiChar; Show: Word; bWait: Boolean): Longint;
  end;

implementation

{ TWindowsUtils }

class function TWindowsUtils.new(): IWindowsUtils;
begin
  Result := Self.Create;
end;

function TWindowsUtils.getTempFile(const Extension: string): string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  repeat
    GetTempPath(SizeOf(Buffer) - 1, Buffer);
    GetTempFileName(Buffer, '~', 0, Buffer);
    Result := ChangeFileExt(Buffer, Extension);
  until not FileExists(Result);
end;

procedure TWindowsUtils.OpenFile(AFile: TFileName; TypeForm: Integer = SW_NORMAL);
var
  Pdir: PChar;
begin
  GetMem(Pdir, 256);             
  StrPCopy(Pdir, AFile);
  ShellExecute(0, nil, Pchar(AFile), nil, Pdir, TypeForm);
  FreeMem(Pdir, 256);
end;

procedure TWindowsUtils.OpenFileAndWait(AFile: TFileName; TypeForm: Integer);
var
  Pdir: PChar;
begin
  GetMem(Pdir, 256);
  StrPCopy(Pdir, AFile);
  ShellExecuteAndWait(nil, Pchar(AFile), nil, Pdir, TypeForm, True);
  FreeMem(Pdir, 256);
end;

function TWindowsUtils.ShellExecuteAndWait(Operation, FileName, Parameter, Directory: PAnsiChar; Show: Word; bWait: Boolean): Longint;
var
  bOK: Boolean;
  Info: TShellExecuteInfo;
begin
  FillChar(Info, SizeOf(Info), Chr(0));
  Info.cbSize := SizeOf(Info);
  Info.fMask := SEE_MASK_NOCLOSEPROCESS;
  Info.lpVerb := PChar(Operation);
  Info.lpFile := PChar(FileName);
  Info.lpParameters := PChar(Parameter);
  Info.lpDirectory := PChar(Directory);
  Info.nShow := Show;
  bOK := Boolean(ShellExecuteEx(@Info));
  if bOK then
  begin
    if bWait then
    begin
      while WaitForSingleObject(Info.hProcess, 100) = WAIT_TIMEOUT do
        Application.ProcessMessages;
      bOK := GetExitCodeProcess(Info.hProcess, DWORD(Result));
    end
    else
      Result := 0;
  end;
  if not bOK then
    Result := -1;
end;

end.

