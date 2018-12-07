unit REST.ClientClass;

interface

uses
  REST.Client, System.Generics.Collections, System.Classes, REST.Types, System.JSON;

type
  IClientREST = interface
    ['{3389A380-A0F5-45D6-9CB0-F2DDD7FF6203}']
    function execute(): IClientREST;
    function GetBaseURL: string;
    procedure SetBaseURL(const Value: string);
    function GetTimeOut: Integer;
    procedure SetTimeOut(const Value: Integer);
    function headerAdd(const AName, AValue: string): IClientREST;
    function paramsAdd(const AName, AValue: string; const AKind: TRESTRequestParameterKind; AContentType: TRESTContentType; const AOptions: TRESTRequestParameterOptions = []): IClientREST;
    function GetJsonText: string;
    procedure SetJsonText(const Value: string);
    function GetContentType: string;
    procedure SetContentType(const Value: string);
    function GetMethod: TRESTRequestMethod;
    procedure SetMethod(const Value: TRESTRequestMethod);
    function toJSONString(): string;
    function toJSONValue(): TJSONValue;
    property BaseURL: string read GetBaseURL write SetBaseURL;
    property TimeOut: Integer read GetTimeOut write SetTimeOut;
    property JsonText: string read GetJsonText write SetJsonText;
    property ContentType: string read GetContentType write SetContentType;
    property Method: TRESTRequestMethod read GetMethod write SetMethod;
  end;

  TClientREST = class(TInterfacedObject, IClientREST)
  protected
    FClient: TRESTClient;
    FRequest: TRESTRequest;
    FResponse: TRESTResponse;
    constructor Create();
  { Protected Declarations }
  private
    FTimeOut: Integer;
    FBaseURL: string;
    FJsonText: string;
    FContentType: string;
    FMethod: TRESTRequestMethod;
    function GetBaseURL: string;
    procedure SetBaseURL(const Value: string);
    function GetTimeOut: Integer;
    procedure SetTimeOut(const Value: Integer);
    function GetJsonText: string;
    procedure SetJsonText(const Value: string);
    function GetContentType: string;
    procedure SetContentType(const Value: string);
    function GetMethod: TRESTRequestMethod;
    procedure SetMethod(const Value: TRESTRequestMethod);
  { Private Declarations }
  public
    function execute(): IClientREST;
    class function new(): IClientREST;
    destructor Destroy; override;
    function toJSONString(): string;
    function toJSONValue(): TJSONValue;
    function headerAdd(const AName, AValue: string): IClientREST;
    function paramsAdd(const AName, AValue: string; const AKind: TRESTRequestParameterKind; AContentType: TRESTContentType; const AOptions: TRESTRequestParameterOptions = []): IClientREST;
    property BaseURL: string read GetBaseURL write SetBaseURL;
    property TimeOut: Integer read GetTimeOut write SetTimeOut;
    property JsonText: string read GetJsonText write SetJsonText;
    property ContentType: string read GetContentType write SetContentType;
    property Method: TRESTRequestMethod read GetMethod write SetMethod;
  { Public Declarations }
  end;

implementation

uses
  System.SysUtils, REST.HttpClient;

{ TClientREST }

function TClientREST.headerAdd(const AName, AValue: string): IClientREST;
begin
  try
    FRequest.Params.AddHeader(AName, AValue);
  finally
    Result := Self;
  end;
end;

constructor TClientREST.Create();
begin
  FClient := TRESTClient.Create('');
  FRequest := TRESTRequest.Create(FClient);
  FResponse := TRESTResponse.Create(FClient);
  FRequest.Client := FClient;
  FRequest.Response := FResponse;
  FJsonText := EmptyStr;
end;

destructor TClientREST.Destroy;
begin
  FreeAndNil(FClient);
  inherited;
end;

function TClientREST.execute: IClientREST;
begin
  try
    try
      FRequest.AcceptCharset := 'UTF-8, *;q=0.8';
      FRequest.Execute;
    finally
      Result := Self;
    end;
  except
    on E: ERESTException do
      raise ERESTException.Create(E.Message);
    on E: EHTTPProtocolException do
      raise EHTTPProtocolException.Create(E.ErrorCode, E.ErrorMessage, E.Message);
    on E: Exception do
      raise Exception.Create(E.Message);
  end;
end;

function TClientREST.GetBaseURL: string;
begin
  Result := FBaseURL;
end;

function TClientREST.GetContentType: string;
begin
  Result := FContentType;
end;

function TClientREST.GetJsonText: string;
begin
  Result := FJsonText;
end;

function TClientREST.GetMethod: TRESTRequestMethod;
begin
  Result := FMethod;
end;

function TClientREST.GetTimeOut: Integer;
begin
  Result := FTimeOut;
end;

class function TClientREST.new: IClientREST;
begin
  Result := Self.Create();
end;

function TClientREST.paramsAdd(const AName, AValue: string; const AKind: TRESTRequestParameterKind; AContentType: TRESTContentType; const AOptions: TRESTRequestParameterOptions = []): IClientREST;
begin
  try
    FRequest.Params.AddItem(AName, AValue, AKind, AOptions, AContentType);
  finally
    Result := Self;
  end;
end;

procedure TClientREST.SetBaseURL(const Value: string);
begin
  FBaseURL := Value;
  FClient.BaseURL := Value;
end;

procedure TClientREST.SetContentType(const Value: string);
begin
  FContentType := Value;
  if Value <> EmptyStr then
    FClient.ContentType := Value;
end;

procedure TClientREST.SetJsonText(const Value: string);
begin
  FJsonText := Value;
  if Value <> EmptyStr then
    FRequest.Body.JSONWriter.WriteRaw(Value);
end;

procedure TClientREST.SetMethod(const Value: TRESTRequestMethod);
begin
  FMethod := Value;
  FRequest.Method := Value;
end;

procedure TClientREST.SetTimeOut(const Value: Integer);
begin
  FTimeOut := Value;
  FRequest.Timeout := Value;
end;

function TClientREST.toJSONValue(): TJSONValue;
begin
  Result := FResponse.JSONValue;
end;

function TClientREST.toJSONString(): string;
begin
  Result := FResponse.JSONText;
end;

end.

