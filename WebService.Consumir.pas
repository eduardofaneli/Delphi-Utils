unit WebService.Consumir;

interface

uses
  Soap.SOAPHTTPTrans, System.Classes;

type
  IConsumirWS = interface
    ['{B36C8BDA-FDF9-4167-B5A5-BE339ADEDDDC}']
    procedure SetURL(const Value: string);
    procedure SetUsername(const Value: string);
    procedure SetPassword(const Value: string);
    procedure SetAction(const Value: string);
    procedure SetContentHeader(const Value: string);
    procedure SetSendTimeOut(const Value: Integer);
    procedure SetReceiveTimeOut(const Value: Integer);
    procedure SetUTF8inHeader(const Value: Boolean);
    procedure ContentHeaderBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
    procedure setProperties();
    function Post(const pRequest: string): string;
    function Get(): string;
    property URL: string write SetURL;
    property Username: string write SetUsername;
    property Password: string write SetPassword;
    property Action: string write SetAction;
    property ContentHeader: string write SetContentHeader;
    property SendTimeOut: Integer write SetSendTimeOut;
    property ReceiveTimeOut: Integer write SetReceiveTimeOut;
    property UTF8inHeader: Boolean write SetUTF8inHeader;
  end;

  TConsumirWS = class(TInterfacedObject, IConsumirWS)
  private
    FAction: string;
    FURL: string;
    FContentHeader: string;
    FUsername: string;
    FPassword: string;
    FUTF8inHeader: Boolean;
    FSendTimeOut: Integer;
    FReceiveTimeOut: Integer;
    FReqResp: THTTPReqResp;

    procedure SetURL(const Value: string);
    procedure SetAction(const Value: string);
    procedure SetContentHeader(const Value: string);
    procedure SetReceiveTimeOut(const Value: Integer);
    procedure SetSendTimeOut(const Value: Integer);
    procedure SetUTF8inHeader(const Value: Boolean);
    procedure SetPassword(const Value: string);
    procedure SetUsername(const Value: string);
  protected
    procedure ContentHeaderBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
  public
    procedure setProperties();
    function Post(const pRequest: string): string;
    function Get(): string;
    class function new(AOwner: TComponent): IConsumirWS;
    property URL: string write SetURL;
    property Action: string write SetAction;
    property ContentHeader: string write SetContentHeader;
    property SendTimeOut: Integer write SetSendTimeOut;
    property ReceiveTimeOut: Integer write SetReceiveTimeOut;
    property UTF8inHeader: Boolean write SetUTF8inHeader;
    property Username: string write SetUsername;
    property Password: string write SetPassword;
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
  end;

implementation

uses
  System.SysUtils, Winapi.WinInet, System.StrUtils;

{ TConsumirWS }

constructor TConsumirWS.Create(AOwner: TComponent);
begin
  FReqResp := THTTPReqResp.Create(AOwner);

  SendTimeOut := 60000;
  ReceiveTimeOut := 60000;
  URL := EmptyStr;
  Action := EmptyStr;
  ContentHeader := EmptyStr;
  UTF8inHeader := True;
  FUsername := EmptyStr;
  FPassword := EmptyStr;
end;

destructor TConsumirWS.Destroy;
begin
  FreeAndNil(FReqResp);
  inherited;
end;

class function TConsumirWS.new(AOwner: TComponent): IConsumirWS;
begin
  Result := Self.Create(AOwner);
end;

function TConsumirWS.Post(const pRequest: string): string;
var
  request, response: TStringStream;
begin
  request := TStringStream.Create;
  response := TStringStream.Create;
  try
    try
      request.WriteString(pRequest);

      setProperties();

      FReqResp.Execute(request, response);

      Result := response.DataString;
    except
      on E: ESOAPHTTPException do
        raise Exception.Create(E.Message);
      on E: Exception do
          raise Exception.Create(E.Message);
    end;
  finally
    FreeAndNil(request);
    FreeAndNil(response);
  end;
end;

function TConsumirWS.Get(): string;
var
  response: TStringStream;
begin
  response := TStringStream.Create('', TEncoding.UTF8);
  try
    try
      setProperties();

      FReqResp.Get(response);


      Result := response.DataString;
    except
      on E: ESOAPHTTPException do
        raise Exception.Create(E.Message);
      on E: Exception do
          raise Exception.Create(E.Message);
    end;
  finally
    FreeAndNil(response);
  end;
end;

procedure TConsumirWS.SetAction(const Value: string);
begin
  FAction := Value;
end;

procedure TConsumirWS.SetContentHeader(const Value: string);
begin
  FContentHeader := Value;
end;

procedure TConsumirWS.SetPassword(const Value: string);
begin
  FPassword := Value;
end;

procedure TConsumirWS.setProperties();
begin
  FReqResp.URL := FURL;
  FReqResp.UserName := FUsername;
  FReqResp.Password := FPassword;
  FReqResp.SoapAction := FAction;
  FReqResp.UseUTF8InHeader := FUTF8inHeader;
  FReqResp.SendTimeout := FSendTimeOut;
  FReqResp.ReceiveTimeout := FReceiveTimeOut;
  FReqResp.InvokeOptions := [soNoValueForEmptySOAPAction, soNoSOAPActionHeader, soPickFirstClientCertificate];

  if FContentHeader <> EmptyStr then
    FReqResp.OnBeforePost := ContentHeaderBeforePost;

end;

procedure TConsumirWS.SetReceiveTimeOut(const Value: Integer);
begin
  FReceiveTimeOut := Value;
end;

procedure TConsumirWS.SetSendTimeOut(const Value: Integer);
begin
  FSendTimeOut := Value;
end;

procedure TConsumirWS.SetURL(const Value: string);
begin
  FURL := Value;
end;

procedure TConsumirWS.SetUsername(const Value: string);
begin
  FUsername := Value;
end;

procedure TConsumirWS.SetUTF8inHeader(const Value: Boolean);
begin
  FUTF8inHeader := Value;
end;

procedure TConsumirWS.ContentHeaderBeforePost(const HTTPReqResp: THTTPReqResp; Data: Pointer);
begin
  try
    HttpAddRequestHeaders(Data, PChar(FContentHeader), length(FContentHeader), HTTP_ADDREQ_FLAG_REPLACE);
    HTTPReqResp.CheckContentType;
  except
    on e: Exception do
      raise Exception.Create('Falha ao montar HEADER da requisição. Motivo: ' + e.Message);
  end;
end;

end.

