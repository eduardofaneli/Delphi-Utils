unit Comum.StreamUtils;

interface

uses
  Classes;

type
  IStreamUTils = interface
    ['{3695444E-C3DC-4785-A027-4DFA750CD017}']
    function textFileCountLines(AStream: TStream; const ABreakLine: Char): IStreamUTils;
    function textFileReadLine(AStream: TStream; const ABreakLine: Char): IStreamUTils;
    function textFilePosition(AStream: TFileStream; ANumeroLinha: Integer): IStreamUTils;
    function toString(): string;
    function toInteger(): Integer;
  end;

  TStreamUtils = class(TInterfacedObject, IStreamUTils)
  private
    FString: string;
    FInteger: Integer;
    { private declarations}
  protected
    { protected declarations}
  public
    function textFileCountLines(AStream: TStream; const ABreakLine: Char): IStreamUTils;
    function textFilePosition(AStream: TFileStream; ANumeroLinha: Integer): IStreamUTils;
    function textFileReadLine(AStream: TStream; const ABreakLine: Char): IStreamUTils;
    function toString(): string;
    function toInteger(): Integer;
    class function new(): IStreamUtils;
    { public declarations}
  end;

implementation

uses
  SysUtils;
const
  BufferSize = 1024 * 1024; //1 MB

var
  CharBuffer: array[0..BufferSize - 1] of AnsiChar;

{ TStreamUtils }  
function TStreamUtils.textFileCountLines(AStream: TStream; const ABreakLine: Char): IStreamUTils;
var
  I, cutOff: Integer;
  startPosition: Integer;
  streamSize: Integer;
  count: Integer;
begin
  try
    count := 0;
    startPosition := 0;
    streamSize := AStream.Size;
    cutOff := 0;
    while AStream.Position < streamSize do
    begin
      AStream.Read(CharBuffer[0], BufferSize);
      startPosition := startPosition + BufferSize;
      if startPosition > streamSize then
        cutOff := startPosition - streamSize;
      for I := 0 to BufferSize - 1 - cutOff do
        if CharBuffer[I] = ABreakLine then
          inc(count);
    end;
  finally
    FInteger := count;
    Result := Self;
  end;

end;

function TStreamUtils.textFileReadLine(AStream: TStream; const ABreakLine: Char): IStreamUTils;
var
  ch: AnsiChar;
  StartPos, lineLength: integer;
  line: string;
begin
  try
    StartPos := AStream.Position;
    ch := #0;
    while (AStream.Read(ch, 1) = 1) and (ch <> ABreakLine) do
      ;
    lineLength := AStream.Position - StartPos;
    AStream.Position := StartPos;
    SetString(line, NIL, lineLength);
    AStream.ReadBuffer(line[1], lineLength);
    if ch = #13 then
    begin
      if (AStream.Read(ch, 1) = 1) and (ch <> ABreakLine) then
        AStream.Seek(-1, soCurrent) // unread it if not LF character.
    end
  finally
    FString := line;
    Result := Self;
  end;
end;

class function TStreamUtils.new(): IStreamUtils;
begin
  Result := Self.Create;
end;

function TStreamUtils.toString: string;
begin
  Result := FString;
end;

function TStreamUtils.textFilePosition(AStream: TFileStream; ANumeroLinha: Integer): IStreamUTils;
var
  position: Integer;
  stream: TMemoryStream;
  character: Char;
  linhaAtual, startPos: Integer;  
begin
  try
    stream := TMemoryStream.Create();
    stream.LoadFromStream(AStream);

    character := #0;
    startPos := stream.Position;
    linhaAtual := 2;
    position := 0;

    while stream.Position < stream.Size do
    begin
      while (stream.Read(character, 1) = 1) and (character <> #10) do
        ;
      if linhaAtual = ANumeroLinha then
      begin
        position := stream.Position;
        Break;
      end;
      inc(linhaAtual);
    end;

  finally
    FreeAndNil(stream);
    FInteger := position;
    Result := Self;
  end;
end;

function TStreamUtils.toInteger: Integer;
begin
  Result := FInteger;
end;

end.

