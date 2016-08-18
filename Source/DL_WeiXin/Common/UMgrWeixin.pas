{*******************************************************************************
  ����: fendou116688@163.com 2014/12/20
  ����: ΢�ſ�����̨����Ԫ
*******************************************************************************}
unit UMgrWeixin;

interface

uses
  Windows, SysUtils, DateUtils, Classes, UWaitItem, USysLoger, ULibFun,
  superobject, superxmlparser, DB, ADODB, USysDB,IniFiles,
  IdHTTPServer, IdContext,IdCustomTCPServer, IdCustomHTTPServer, UMITPacker,
  StrUtils, ActiveX, UBusinessConst, UBusinessWorker, UBusinessPacker,
  IdHTTP, IdSSLOpenSSL, SyncObjs, UBase64, ExtCtrls,IdTCPServer,IdGlobal,
  USysMAC, UMgrChannel, UChannelChooser, MIT_Service_Intf,
  UMgrRemoteWXMsg, IdHashSHA1, UMgrDB, UMgrDBConn, UWeiXinConst;

type
  { TWXMessageBase }
  TWXMessageBase = class(TObject)
  private
  protected
    FMsgId: Int64; // ��Ϣid��64λ����
    FMsgType: string; //

    FFromUserName: string; //���ͷ��ʺţ�һ��OpenID��
    FToUserName: string; //������΢�ź�

    FCreateTime: Int64; //��Ϣ����ʱ�� �����ͣ�
    //xxxxxx

  public
    constructor Create;
    destructor Destroy; override;
    property Id: Int64 read FMsgId write FMsgId;
    property MsgType: string read FMsgType write FMsgType;

    property ToUserName: string read FToUserName write FToUserName;
    property FromUserName: string read FFromUserName write FFromUserName;

    property CreateTime: Int64 read FCreateTime write FCreateTime;
    //xxxxx
  published

  end;

  { TWXMessageText }
  TWXMessageText = class(TWXMessageBase)
  private
  protected
    FContentText: string;
    //xxxxxx
  public
    constructor Create;
    destructor Destroy; override;
    property ContentText: string read FContentText write FContentText;
  published

  end;

  { TWXMessageImage }
  TWXMessageImage = class(TWXMessageBase)
  private
  protected
    //ͼƬ����
    FPicUrl: string;
    //ͼƬ��Ϣý��id�����Ե��ö�ý���ļ����ؽӿ���ȡ���ݡ�
    FMediaId: string;
    //xxxxxx
  public
    constructor Create;
    destructor Destroy; override;
    property PicUrl: string read FPicUrl write FPicUrl;
    property MediaId: string read FMediaId write FMediaId;
  published
  end;

   { TWXMessageVoice }
  TWXMessageVoice = class(TWXMessageBase)
  private
  protected
    FFormat: string; //������ʽ����amr��speex��
    //������Ϣý��id�����Ե��ö�ý���ļ����ؽӿ���ȡ���ݡ�
    FMediaId: string;
    //xxxxxx
  public
    constructor Create;
    destructor Destroy; override;
    property Format: string read FFormat write FFormat;
    property MediaId: string read FMediaId write FMediaId;
  published

  end;

  { TWXMessageVideo }
  TWXMessageVideo = class(TWXMessageBase)
  private
  protected
    //��Ƶ��Ϣý��id�����Ե��ö�ý���ļ����ؽӿ���ȡ����.
    FMediaId: string;
    //��Ƶ��Ϣ����ͼ��ý��id�����Ե��ö�ý���ļ����ؽӿ���ȡ���ݡ�
    FThumbMediaId: string;
    //xxxxxx
  public
    constructor Create;
    destructor Destroy; override;
    property MediaId: string read FMediaId write FMediaId;
    property ThumbMediaId: string read FThumbMediaId write FThumbMediaId;
  published

  end;

  { TWXMessageLocation }
  TWXMessageLocation = class(TWXMessageBase)
  private
  protected
    //����λ��ά�ȡ�����
    FLocation_X: Double;
    FLocation_Y: Double;
    //xxxxxx

    //��ͼ���Ŵ�С
    FScale: Integer;
    //����λ����Ϣ
    FLabel: string;
  public
    constructor Create;
    destructor Destroy; override;
    property Scale: Integer read FScale write FScale;
    property SLabel: string read FLabel write FLabel;
    property Location_X: Double read FLocation_X write FLocation_X;
    property Location_Y: Double read FLocation_Y write FLocation_Y;
  published

  end;

  { TWXMessageLink }
  TWXMessageLink = class(TWXMessageBase)
  private
  protected
    FUrl: string; //��Ϣ����
    FTitle: string; //��Ϣ����
    FDescription: string; //��Ϣ����
    //xxxxxx
  public
    constructor Create;
    destructor Destroy; override;
    property Url: string read FUrl write FUrl;
    property Title: string read FTitle write FTitle;
    property Description: string read FDescription write FDescription;
  published

  end;

  { TWXMessageEvent }
  TWXMessageEvent = class(TWXMessageBase)
  private
  protected
    FEvent: string; //�¼�����
    FEventKey: string; //�¼�KEYֵ

    FTicket: string; //��ά���ticket����������ȡ��ά��ͼƬ
    //ɨ���ά��

    FLatitude: Double; //����λ��γ��
    FLongitude: Double; //����λ�þ���
    FPrecision: Double; //����λ�þ���
    //�ϱ�����λ���¼�

    //xxxxxx
  public
    constructor Create;
    destructor Destroy; override;
    property Event: string read FEvent write FEvent;
    property EventKey: string read FEventKey write FEventKey;

    property Ticket: string read FTicket write FTicket;
    //xxxxxx
    property Latitude: Double read FLatitude write FLatitude;
    property Longitude: Double read FLongitude write FLongitude;
    property Precision: Double read FPrecision write FPrecision;

  published

  end;

{ TWXBusiness }

  TWXBusiness = class(TObject)
  private
  protected
  public
    constructor Create;
    destructor Destroy; override;

    function GetZhikaValidMoney(nZhiKa: string; var nFixMoney: Boolean;
      const nFactory: string=''): Double;
    //ֽ�����ý�
    function GetCustomerValidMoney(nCID: string; const nLimit: Boolean = True;
     const nValidMoney: PDouble = nil; const nCredit: PDouble = nil;
     const nFactory: string=''): Boolean;
    //�ͻ����ý��
    function GetReport(nCondition: string;var nOutData: string;
      const nFactory: string=''):Boolean;

    function GetQueueList(var nOutData: string;const nFactory: string=''):Boolean;
    //������װ������ѯ
  published
  end;

{ TWXSearchData }
  TWXSearchData = class(TObject)
  private
    FWXBusiness   :  TWXBusiness;
    function GetFactName(nFID: string=''): string;
  protected
    FListA, FListB, FListC: TStrings;
    //���ݼ�
  public
    constructor Create;
    destructor Destroy; override;

    function unBindPersonMap(nOpenID: string = ''): string;
    function BindPersonInfo(nPersonInfo: string; nOpenID: string = ''): string;
    //xxxxxx

    function GetRetStrFromFile(nFile: string = ''): string;
    //xxxxxx

    function GetWXValidMoney(nOpenID: string = ''; nCmd: string = ''): string;
    //��ȡ�û��������
    function GetWXFreezeMoney(nOpenID: string = ''; nCmd: string = ''): string;
    //��ȡ�û�������
    function GetWXZhiKaMoney(nZhiKa: string; nOpenID: string = '';
      nCmd: string = ''): string;
    //��ȡָ��ֽ�����
    function GetWXZhiKaList(nOpenID: string = ''): string;
    //��ȡֽ���б���Ϣ

    function GetValidInfo(nSearch: string; nOpenID: string = '';
      nCmd: string = ''): string;
    //��Ʒ��α���ѯ
    function GetSalePInfo(nSearch: string; nOpenID: string = '';
      nCmd: string = ''): string;
    //���ۼ۸��ѯ
    //���ö�Ȳ�ѯ

    function GetWXReportStr(nSearch: string; nOpenID: string = '';
      nCmd: string = ''): string;
    //���ۼ۸��ѯ
    function GetWXFactQueue(nSearch: string; nOpenID: string = '';
      nCmd: string = ''): string;
    //������װ������ѯ
    
    function CheckDataVaild(nStrSrc: string;
      var nLID, nOutNum: string):Boolean;

    function SearchStr(nSeachStr: string = ''; nOpenID: string = ''): string;
  published

  end;

  TAccessToken = record
    FLastTime: Int64;
    FExpires_in: Int64;
    FFieldValue: string;
  end;

  { TWXUserManager }
  TWXUserBaseInfo = record
    FSubscribe: Integer; //�û��Ƿ��ĸù��ںű�ʶ��ֵΪ0ʱ��������û�û�й�ע�ù��ںţ���ȡ����������Ϣ��
    FOpenid: string; //�û��ı�ʶ���Ե�ǰ���ں�Ψһ
    FNickname: string; //�û����ǳ�
    FSex: string; //�û����Ա�ֵΪ1ʱ�����ԣ�ֵΪ2ʱ��Ů�ԣ�ֵΪ0ʱ��δ֪
    FCity: string;
    FCountry: string;
    FProvince: string;
    FLanguage: string;
    FHeadimgurl: string; //�û�ͷ��
    FSubscribe_time: Int64; //�û���עʱ�䣬Ϊʱ�����
    FUnionid: string; //ֻ�����û������ںŰ󶨵�΢�ſ���ƽ̨�ʺź󣬲Ż���ָ��ֶΡ�
  end;
  TWXGroupRecord = record
    FGroupID: Int64; //����id����΢�ŷ���
    FGroupName: string; //�������֣�
    FGroupUCount: Int64; //�������û�����
  end;
  TWXGroups = array of TWXGroupRecord;

{ TWXHttpsRequest }

  TWXHttpsRequest = class(TObject)
  private
    FWXIdHttps: TIdHTTP;
    FWXIdSSLHandler: TIdSSLIOHandlerSocketOpenSSL;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure InitHttpsClient(nVersion: TIdSSLVersion=sslvTLSv1);
    procedure FreeHttpsClient;
    function HttpsRequest(nUrl, uMothed: string; var nResponseStr: string;
      nParams: string = ''): Boolean;
  published
  end;

{TWXSendTempMsgLog}
  TWXMessageMgr = class;
  TWXSendTempMsgLog = class(TThread)
  private
    FOwner: TWXMessageMgr;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
    FOldTickCount, FNewTickCount:DWORD;
  protected
    procedure DoExecute;
    procedure Execute; override;
  public
    constructor Create(AOwner: TWXMessageMgr);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

{TWXSendTecentTMsg}
  TWXSendTecentTMsg = class(TThread)
  private
    FOwner: TWXMessageMgr;
    //ӵ����
    FWaiter: TWaitObject;
    //�ȴ�����
  protected
    procedure DoExecute;
    procedure Execute; override;
  public
    constructor Create(AOwner: TWXMessageMgr);
    destructor Destroy; override;
    //�����ͷ�
    procedure StopMe;
    //ֹͣ�߳�
  end;

{ TWXMessageMgr }
  TWXMessageMgr = class(TObject)
  private
    FWXType   : TStrings;
    FHTMLDir  : string;
    FWXSearch : TWXSearchData;
    FWXHttpsServer   : TIdHTTPServer;
    //����Ϊ������Ϣ
    FWXTCPServer: TIdTCPServer;

    FAppID, FAppSecret, FAppToken: string;
    FAccess_Token: TAccessToken;
    //������Ϣ�������
    FSycAcessToken: TCriticalSection;
    FWXHttps  : TWXHttpsRequest;

    FDataList: TStrings;
    FSyncLock: TCriticalSection;
    //ͬ����

    FTecentThreads: array [0..2] of TWXSendTecentTMsg;
    FSendLogThread: TWXSendTempMsgLog;
  protected
    function SHA1(Input: String): String;
    function checkSignature(nSignature,nTimestamp,nNonce,nEchostr:string):Boolean;
    procedure wxhttpServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo;
      AResponseInfo: TIdHTTPResponseInfo);
    //xxxxxx

    //procedure WXDealMsg(nRequest:string;var nResponse:string);
    function PacketTextMsg(nstrWXMsg: string; nSO: ISuperObject): string;

    procedure InitSystemObject;
    procedure FreeSystemObject;
    
    function RunSystemObject:Boolean;
    //��ʼ��ϵͳ����

    function GetTokenStr: string;
    //��ȡ��֤��

    function CreateMenu(nWXMenu: string): Boolean;
    function DeleteMenu: Boolean;
    //���ɾ��ϵͳ�˵�

    procedure IdTCPServerExecute(AContext: TIdContext);
    procedure DoExecute(const nContext: TIdContext);
    procedure SendTPMsgExecute(var nBase: TWXDataBase; var nBuf: TIdBytes;
      nCtx: TIdContext);
    //��ȡ�ӷ������Ϸ��͵�ģ����Ϣ

    procedure StartSendTecent;
    procedure StopSendTecent;
    //��ͣ��ͷ

    function MakeRemarkValue(nStrSrc: string;nDS:TDataSet=nil): string;
  public
    constructor Create;
    destructor Destroy; override;

    function WXStartService(nHttpsPort: Integer = 80;
      nTcpPort: Integer=8000): Boolean;
    procedure WXStopService;

    //function CreateMenu(nWXMenu: string): Boolean;
    procedure WXDealHtmlMsg(nRequest: string;var nResponse: string);
    procedure WXDealMsg(nRequest:string;var nResponse:string);
    function WXCreateMenus(nFileType, nFileName: string): Boolean;
    function WXDeleteMenu: Boolean;

    function WXGetAccessToken(nAppid: string = ''; nAppsecret: string = '';
      nFlag: Boolean = False): Boolean;
    //��ȡ��֤�룺AccessToken
    function WXSendCustomMessage(nParams: string): Boolean;
    //���Ϳͷ���Ϣ�������յ���ע����Ϣ֮����Ч
    function WXSendTPMessage(nStrJSON: string;
      var nMsgID: string): string;
    //����ģ����Ϣ
    function WXSendTemplateMsg(const nTempType,nData: string;
      var nHint: string): Boolean;
    procedure WXTPMessageReSend(nRIDs: string; var nHint: string);
    //�ط�ģ����Ϣ
    procedure WXTPMessageSendFromLog;
    //�������ݿⷢ����־�ط�ģ����Ϣ
    function WXSaveTemplate(nTPMID, nTPMType, nTPMTemplate:string;
      nTPMComment:string=''):string;
    function WXDeleteTemplate(nTPMID, nTPMType:string):string;
    //ģ����Ϣ��ʽ��¼��ɾ��

    function WXGetUserGroups(var nGroupStr:string;
      var nGroups: TWXGroups): Boolean;
    function WXGetUserGroupID(nOpenID: string;var nGroupID:Int64): Boolean;
    function WXCreateUserGroup(nGroupName: string;
      var nGroup: TWXGroupRecord): Boolean;
    function WXMoveUserGroup(nGroupID, nOpenID: string): Boolean;
    function WXUpdateGroupName(nGroupID, nGroupName: string): Boolean;

    function WXGetUserInfo(nOpenID: string): TWXUserBaseInfo;

    procedure WXAddTemMsg(nMsg: string);
    //����ģ����Ϣ

    property appid: string read FAppID write FAppID;
    property apptoken: string read FAppToken write FAppToken;
    property appsecret: string read FAppSecret write FAppSecret;
  published

  end;

{ TWX2MITWorker }

  TWX2MITWorker = class(TBusinessWorkerBase)
  protected
    FListA,FListB: TStrings;
    //�ַ��б�
    procedure WriteLog(const nEvent: string);
    //��¼��־
    function ErrDescription(const nCode,nDesc: string;
      const nInclude: TDynamicStrArray): string;
    //��������
    function MITWork(var nData: string;const nFactory: string=''): Boolean;
    //ִ��ҵ��
    function GetFixedServiceURL: string; virtual;
    //�̶���ַ
    function GetFixedServiceURL_2(const nFactory: string=''): string; virtual;
  public
    constructor Create; override;
    destructor destroy; override;
    //�����ͷ�
    function DoWork(const nIn, nOut: Pointer): Boolean; override;
    //ִ��ҵ��
  end;

{ TWXWorkerQueryField }

  TWXHareworeCommand = class(TWX2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL_2(const nFactory: string=''): string; override;
  end;

{ TWXBusinessCommand }

  TWXBusinessCommand = class(TWX2MITWorker)
  public
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    function GetFixedServiceURL_2(const nFactory: string=''): string; override;
  end;

  TWXSysParam = record
    FUserID     : string;                            //�û���ʶ
    FIsWithMIT  : string;                            //�Ƿ����м��һ��
    //xxxxxx

    FLocalIP    : string;                            //����IP
    FLocalMAC   : string;                            //����MAC
    FLocalName  : string;                            //��������
    FFactName   : string;                            //��������
  end;
  //΢��ϵͳ����

function CallBusinessCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nFactory: string = ''): Boolean;
function CallHardwareCommand(const nCmd: Integer; const nData,nExt: string;
  const nOut: PWorkerBusinessCommand; const nFactory: string = ''): Boolean;

procedure InitSystemDBMgr;
procedure FinalSystemDBMgr;
var
  gWXMessgeMgr  :  TWXMessageMgr=nil;

implementation

var
  gWXSysParam   :  TWXSysParam;                        //���򻷾�����

const
  G_WeixinTocken    = 'weixin';
  G_WeixinTextType  = $01;
  G_WeixinLinkType  = $02;
  G_WeixinEventType = $03;
  G_WeixinImageType = $04;
  G_WeixinVideoType = $05;
  G_WeixinVoiceType = $06;

  sConfig           = 'Config.Ini';
  sForm             = 'FormInfo.Ini';
  sDB               = 'DBConn.Ini';
  gWXStartTemp        = '{{';
  gWXStopTemp         = '.DATA}}';

procedure WriteLog(const nEvent: string);
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gWeiXinPath + 'logs\');
  gSysLoger.AddLog(TWXMessageMgr, '΢�Ź���ƽ̨����', nEvent);
end;

function GetNowUnixTime: Int64;
begin
  Result := DateTimeToUnix(Now) - 8 * 60 * 60;
end;

function GetErrMsgByCode(nErrCode: Integer): string;
var
  nErrFile:  string;
  nSErrList: TStrings;
begin
  nSErrList := TStringList.Create;
  try
    nErrFile := gWeiXinPath + 'WXErrCode.ini';
    if FileExists(nErrFile) then
      nSErrList.LoadFromFile('WXErrCode.ini');
    Result := nSErrList.Values[IntToStr(nErrCode)];
  finally
    FreeAndNil(nSErrList);
  end;
end;

{ TWXMessageBase }
constructor TWXMessageBase.Create;
begin
  inherited Create;

  FMsgId := 0;
  FMsgType := '';

  FFromUserName := '';
  FToUserName := '';

  FCreateTime := 0;
  //xxxxxx
end;

destructor TWXMessageBase.Destroy;
begin
  FMsgId := 0;
  FMsgType := '';

  FFromUserName := '';
  FToUserName := '';

  FCreateTime := 0;
  //xxxxxx

  inherited Destroy;
end;

//------------------------------------------------------------------------------
{ TWXMessageText }
constructor TWXMessageText.Create;
begin
  inherited Create;

end;

destructor TWXMessageText.Destroy;
begin
  inherited Destroy;
end;
//------------------------------------------------------------------------------
{ TWXMessageImage }
constructor TWXMessageImage.Create;
begin
  inherited Create;

end;

destructor TWXMessageImage.Destroy;
begin
  inherited Destroy;
end;
//------------------------------------------------------------------------------
{ TWXMessageVoice }
constructor TWXMessageVoice.Create;
begin
  inherited Create;

end;

destructor TWXMessageVoice.Destroy;
begin
  inherited Destroy;
end;
//------------------------------------------------------------------------------
{ TWXMessageVideo }
constructor TWXMessageVideo.Create;
begin
  inherited Create;

end;

destructor TWXMessageVideo.Destroy;
begin
  inherited Destroy;
end;
//------------------------------------------------------------------------------
{ TWXMessageLocation }
constructor TWXMessageLocation.Create;
begin
  inherited Create;

end;

destructor TWXMessageLocation.Destroy;
begin
  inherited Destroy;
end;
//------------------------------------------------------------------------------
{ TWXMessageLink }
constructor TWXMessageLink.Create;
begin
  inherited Create;

end;

destructor TWXMessageLink.Destroy;
begin
  inherited Destroy;
end;
//------------------------------------------------------------------------------
{ TWXMessageEvent }
constructor TWXMessageEvent.Create;
begin
  inherited Create;

end;

destructor TWXMessageEvent.Destroy;
begin
  inherited Destroy;
end;
//------------------------------------------------------------------------------
{ TWXSearchData }
constructor TWXSearchData.Create;
begin
  inherited Create;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;

  FWXBusiness  := TWXBusiness.Create;
end;

destructor TWXSearchData.Destroy;
begin
  FListA.Free;
  FListB.Free;
  FListC.Free;

  FWXBusiness.Free;
  inherited Destroy;
end;

function TWXSearchData.GetFactName(nFID: string=''): string;
var nStr: string;
    nDB : PDBWorker;
begin
  Result := '';
  if nFID = '' then Exit;
  nStr := 'Select D_Value from %s where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_FactoryItem, nFID]);
  //xxxxxx

  try
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount<1 then Exit;
      Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;

function TWXSearchData.BindPersonInfo(nPersonInfo: string;
  nOpenID: string = ''): string;
var
  nSQLQuery, nFact: string;
  nDB :PDBWorker;
begin
  Result := '�밴����ȷ�ĸ�ʽ����[1001#΢��ϵͳ���]';
  if nPersonInfo='' then Exit;

  nOpenID := UpperCase(nOpenID);
  nPersonInfo := UpperCase(nPersonInfo);
  nSQLQuery := 'Select * from $WXMATCH where M_ID=''$MID''';
  nSQLQuery := MacroValue(nSQLQuery, [MI('$WXMATCH', sTable_WeixinMatch),
                                      MI('$MID', nPersonInfo)]);
  //xxxxxx

  try
    with gDBConnManager.SQLQuery(nSQLQuery, nDB) do
    begin
      if RecordCount < 1 then
      begin
        Result := Format('΢��ϵͳ���[%s]������,�����°�',[nPersonInfo]);Exit;
      end;

      if FieldByName('M_isValid').AsString <> sFlag_Yes then
      begin
        Result := '�ͻ�δ����΢��ҵ��';Exit;
      end;

      if FieldByName('M_WXID').AsString = nOpenID then
      begin
        Result := '΢���Ѱ�';Exit;
      end;

      nFact := FieldByName('M_WXFactory').AsString;
    end;

    nSQLQuery := 'Select * from $WXMATCH where M_WXID=''$MWXID'' ' +
                 'and M_WXFactory=''$FACT''';
    nSQLQuery := MacroValue(nSQLQuery, [MI('$WXMATCH', sTable_WeixinMatch),
                                        MI('$MWXID', nOpenID),
                                        MI('$FACT', nFact)]);
    //xxxxxx

    with gDBConnManager.WorkerQuery(nDB, nSQLQuery) do
    if RecordCount>0 then
    begin
      Result := 'ͬһ����ֻ�ܹ�עһ���ͻ�';
      Exit;
    end;

    nSQLQuery := 'Update $WXMATCH set M_WXID=''$MWXID'' where M_ID=''$MID''';
    nSQLQuery := MacroValue(nSQLQuery, [MI('$WXMATCH', sTable_WeixinMatch),
                                        MI('$MID', nPersonInfo),
                                        MI('$MWXID', nOpenID)]);
    //xxxxxx
    if gDBConnManager.WorkerExec(nDB, nSQLQuery) > 0 then
      Result := '�󶨳ɹ�'
    else
      Result := '��ʧ��';
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;

function TWXSearchData.unBindPersonMap(nOpenID: string = ''): string;
var
  nSQLQuery: string;
  nDB : PDBWorker;
begin
  nOpenID := UpperCase(nOpenID);
  nSQLQuery := 'Select * from $WXMATCH where M_WXID=''$MWXID''';
  nSQLQuery := MacroValue(nSQLQuery, [MI('$WXMATCH', sTable_WeixinMatch),
                                      MI('$MWXID', nOpenID)]);
  //xxxxxx

  try
    with gDBConnManager.SQLQuery(nSQLQuery, nDB) do
    begin
      if RecordCount < 1 then
      begin
        Result := '΢��δ��'; Exit;
      end;

      if FieldByName('M_isValid').AsString <> sFlag_Yes then
      begin
        Result := '�ͻ�δ����΢��ҵ��';
        Exit;
      end;
    end;

    nSQLQuery := 'Update $WXMATCH set M_WXID=null where M_WXID=''$MWXID''';
    nSQLQuery := MacroValue(nSQLQuery, [MI('$WXMATCH', sTable_WeixinMatch),
                                        MI('$MWXID', nOpenID)]);
    //xxxxxx

    if gDBConnManager.WorkerExec(nDB, nSQLQuery) > 0 then
      Result := '����󶨳ɹ�'
    else
      Result := '�����ʧ��';
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;

end;

function TWXSearchData.GetWXValidMoney(nOpenID: string = '';
  nCmd: string = ''): string;
var nStr: string;
    nDB : PDBWorker;
    nVal, nCredit: Double;
begin
  nOpenID := UpperCase(nOpenID);

  nStr := 'Select * from $CUSTOMER sc inner join $WXMATCH sw ' +
          'on sc.C_Weixin=sw.M_ID where M_WXID=''$MWXID'' order by sc.C_ID';
  nStr := MacroValue(nStr, [MI('$CUSTOMER', sTable_Customer),
                            MI('$WXMATCH', sTable_WeixinMatch),
                            MI('$MWXID', nOpenID)]);

  try
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount<1 then
      begin
        Result := '��΢���˺�δ��';
        Exit;
      end;

      First; Result := '';
      while not Eof do
      begin
        nStr := FieldByName('M_isValid').AsString;
        if nStr <> sFlag_Yes then
        begin
          Result := '�����رտͻ�΢��ҵ��';
          Next;Continue;
        end;
        //�ж��Ƿ���Ч

        if not FWXBusiness.GetCustomerValidMoney(FieldByName('C_ID').AsString, False,
          @nVal, @nCredit, nStr) then
        begin
          Result := '��ѯ���ִ������Ժ�����';
          Exit;
        end;

        nStr := '�ͻ�ID:[$CID] �ͻ�����:[$CUSNAME] ' +
                '���ý��:[$MONEY]' + #13#10;
        nStr := MacroValue(nStr, [MI('$CID', FieldByName('C_ID').AsString),
                                  MI('$CUSNAME', FieldByName('C_NAME').AsString),
                                  MI('$MONEY', FloatToStr(Float2Float(nVal,cPrecision)))]);
        //xxxxxx

        Result := Result + nStr;
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;

function TWXSearchData.GetWXFreezeMoney(nOpenID: string = '';
  nCmd: string = ''): string;
var nDB: PDBWorker;
    nStr: string;
    nVal: Double;
begin
  nStr := 'Select * from $WXMATCH where M_WXID=''$MWXID'' Order by M_ID';
  nStr := MacroValue(nStr, [MI('$WXMATCH', sTable_WeixinMatch),
                            MI('$MWXID', nOpenID)]);
  //xxxxxx

  try
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount < 1 then
      begin
        Result := '΢��ҵ��δ��';
        Exit;
      end;

      if FieldByName('M_isValid').AsString <> sFlag_Yes then
      begin
        Result := '�ͻ�δ����΢��ҵ��';Exit;
      end;
    end;

    nStr := 'select sca.* ,scm.* from $CUSACCOUNT sca ' +
            'inner join (select C_ID,C_Name,M_IsValid from $CUSTOMER sc ' +
            'inner join $WXMATCH sw on sc.C_Weixin=sw.M_ID where M_WXID=''$MWXID'')'+
            ' scm 	on sca.A_CID=scm.C_ID order by scm.C_ID';
    nStr := MacroValue(nStr, [MI('$CUSACCOUNT', sTable_CusAccount),
                              MI('$CUSTOMER', sTable_Customer),
                              MI('$WXMATCH', sTable_WeixinMatch),
                              MI('$MWXID', nOpenID)]);
    //xxxxxx
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      First;
      Result := '';

      while not Eof do
      begin
        nVal:= FieldByName('A_FreezeMoney').AsFloat;
        nStr := '�ͻ�ID:[$ACID] �ͻ�����:[$CUSNAME] ' +
                '������:[$MONEY]' + #13#10;
        nStr := MacroValue(nStr, [MI('$ACID', FieldByName('A_CID').AsString),
                                  MI('$CUSNAME', FieldByName('C_NAME').AsString),
                                  MI('$MONEY', FloatToStr(Float2Float(nVal,cPrecision)))]);
        //xxxxxx

        Result := Result + nStr;
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
    if Result='' then Result := 'δ�鵽��Ϣ';
  end;
end;

function TWXSearchData.GetWXZhiKaMoney(nZhiKa: string; nOpenID: string = '';
  nCmd: string = ''): string;
var nDB: PDBWorker;
    nDS: TDataSet;
    nStr: string;
    nFix: Boolean;
    nVal: Double;
begin
  if (nZhiKa='') then
  begin
    Result := '��������ȷ�����ݸ�ʽ[%s#ֽ�����]';
    Result := Format(Result, [nCmd]);
    Exit;
  end;

  nStr := 'Select * from $WXMATCH where M_WXID=''$MWXID'' Order by M_ID';
  nStr := MacroValue(nStr, [MI('$WXMATCH', sTable_WeixinMatch),
                            MI('$MWXID', nOpenID)]);
  //xxxxxx

  try
    nDS := gDBConnManager.SQLQuery(nStr, nDB);
    if (not Assigned(nDS)) or (nDS.RecordCount<1) then
    begin
      Result := '��΢���˺�δ��';
      Exit;
    end;

    if nDS.FieldByName('M_isValid').AsString <> sFlag_Yes then
    begin
      Result := '�ͻ�δ����΢��ҵ��';
      Exit;
    end;

    nStr := 'select * from $ZHIKA inner join $CUSTOME on Z_Customer=C_ID '+
            'where C_Weixin=''$CMID'' and Z_ID=''$ZID''';
    nStr := MacroValue(nStr, [MI('$CMID', nDS.FieldByName('M_ID').AsString),
                              MI('$CUSTOME', sTable_Customer),
                              MI('$ZHIKA', sTable_ZhiKa),
                              MI('$ZID', nZhiKa)]);
    //xxxxxx

    nDS := gDBConnManager.WorkerQuery(nDB, nStr);
    if (not Assigned(nDS)) or (nDS.RecordCount<1) then
    begin
      Result := 'ֽ����Ŵ���';
      Exit;
    end;

    nVal := FWXBusiness.GetZhikaValidMoney(nZhika, nFix);

    nStr := 'ֽ�����:[$ZID] ֽ������:[$ZNAME] ֽ�����ý��:[$MONEY]';
    Result := MacroValue(nStr, [MI('$ZNAME', nDS.FieldByName('Z_NAME').AsString),
                                MI('$MONEY', FloatToStr(Float2Float(nVal,100))),
                                MI('$ZID', nZhiKa)]);
    //xxxxxx
  finally
    gDBConnManager.ReleaseConnection(nDB);
    if Result='' then Result := 'δ�鵽��Ϣ';
  end;
end;

//ֽ���б�
function TWXSearchData.GetWXZhiKaList(nOpenID: string = ''): string;
var nDB: PDBWorker;
    nStr: string;
    nFix:Boolean;
    nMoney: Double;
begin
  nStr := 'Select * from $WXMATCH where M_WXID=''$MWXID'' Order by M_ID';
  nStr := MacroValue(nStr, [MI('$WXMATCH', sTable_WeixinMatch),
                            MI('$MWXID', nOpenID)]);
  //xxxxxx

  try
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount < 1 then
      begin
        Result := '΢��ҵ��δ��';
        Exit;
      end;

      if FieldByName('M_isValid').AsString <> sFlag_Yes then
      begin
        Result := '�ͻ�δ����΢��ҵ��';Exit;
      end;

      nStr := 'Select * from $ZHK sz inner join $CUSTOMER sc on ' +
              'sz.Z_Customer=sc.C_ID where sc.C_Weixin=''$CMID''';
      nStr := MacroValue(nStr, [MI('$CMID', FieldByName('M_ID').AsString),
                                MI('$CUSTOMER', sTable_Customer),
                                MI('$ZHK', sTable_ZhiKa)]);
      //xxxxxx
    end;


    with gDBConnManager.WorkerQuery(nDB, nStr) do
    begin
      if RecordCount<1 then
      begin
        Result := '�ͻ�δ����ֽ��';
        Exit;
      end;

      First;Result := '';
      while not Eof do
      begin
        nMoney := FWXBusiness.GetZhikaValidMoney(FieldByName('Z_ID').AsString, nFix);
        Result := Result + 'ֽ�����:%s ֽ������:%s ���ý��:%.2f'+#13#10;
        Result := Format(Result, [FieldByName('Z_ID').AsString,
                                  FieldByName('Z_Name').AsString,
                                  nMoney]);
        //xxxxxx

        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
    if Result='' then Result := 'δ�鵽��Ϣ';
  end;
end;

//���ݷ�α���ȡ������Ϣ
function TWXSearchData.GetValidInfo(nSearch: string; nOpenID: string = '';
  nCmd: string = ''): string;
var nWorker: PDBWorker;
    nStr: string;
    nLOutNum, nLID: string;
begin
  if (nSearch='') then
  begin
    Result := '��������ȷ�����ݸ�ʽ[%s#��α��]';
    Result := Format(Result, [nCmd]);
    Exit;
  end;

  //protocol:151018P02151015��01141
  //DATA������"������� ��������"
  if not CheckDataVaild(nSearch, nLID, nLOutNum) then
  begin
    Result := '����ѯ�ķ�α��Ϊ:%s' + #13#10 +
              '��֤û��ͨ����' + #13#10 +
              '��α��Ӧ��Ϊ21λ(�����ո�)';
    Result := Format(Result, [nSearch]);
    Exit;
  end;

  try
    nStr := 'Select * From $BILLTABLE Where ' +
            'L_ID Like ''%%$LID'''; // and L_HYDan = ''$LOUTNUM''';
    nStr := MacroValue(nStr, [MI('$BILLTABLE', sTable_Bill),
                              MI('$LOUTNUM', nLOutNum),
                              MI('$LID', nLID)]);
    //xxxxxx

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    begin
      if RecordCount<1 then
      begin
        Result := '����ѯ�ı��:%s����ȷ����˶Լ��';
        Result := Format(Result, [nSearch]);
        Exit;
      end;

      nStr := gWeiXinPath + 'Template\' + nCmd + '.txt';
      if FileExists(nStr) then
      begin
        Result := GetRetStrFromFile(nCmd + '.txt');
        Result := MacroValue(Result, [
                  MI('$BILL', FieldByName('L_ID').AsString),
                  MI('$ZHIKA', FieldByName('L_ZhiKa').AsString),
                  MI('$TRUCK', FieldByName('L_Truck').AsString),

                  MI('$PROJECT', FieldByName('L_Project').AsString),
                  MI('$CUSNAME', FieldByName('L_CusName').AsString),

                  MI('$STOCK', FieldByName('L_StockName').AsString),
                  MI('$OUTDATE', FieldByName('L_OutFact').AsString),

                  MI('$LPRICE', FieldByName('L_Price').AsString),
                  MI('$LVALUE', FieldByName('L_Value').AsString),
                  MI('$PVALUE', FieldByName('L_PValue').AsString),
                  MI('$MVALUE', FieldByName('L_MValue').AsString)]);

        //xxxxxx
      end else
      begin   
        Result := Format('��֤�����������ѯ�Ĳ�Ʒ����%s��������Ʒˮ�࣬лл��',
            [gWXSysParam.FFactName]);
        //
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
    if Result='' then Result := 'δ�鵽��Ϣ';
  end;
end;

//���ۼ۸��ѯ
function TWXSearchData.GetSalePInfo(nSearch: string; nOpenID: string = '';
  nCmd: string = ''): string;
var nStr: string;
begin
  try
    nStr := gWeiXinPath + 'Template\' + nCmd + '.txt';
    if FileExists(nStr) then
    begin
      Result := GetRetStrFromFile(nCmd + '.txt');
    end;
  finally
    if Result='' then Result := 'δ�鵽��Ϣ';
  end;
end;

//�����ѯ
//��ʼ����;��ֹ����;�������;�ͻ����(�ָ�������)
function TWXSearchData.GetWXReportStr(nSearch: string; nOpenID: string = '';
  nCmd: string = ''): string;
var nIdx: Integer;
  nDS: TDataSet;
  nDB: PDBWorker;
  nListA, nListB, nListC: TStrings;
  nStr, nFactName, nSQLQuery: string;
begin
  nListA := TStringList.Create;
  nListB := TStringList.Create;
  nListC := TStringList.Create;

  nSearch := StringReplace(nSearch, '��', ',', [rfReplaceAll]);
  nSQLQuery := 'Select * from $WXMATCH where M_WXID=''$MWXID''';
  nSQLQuery := MacroValue(nSQLQuery, [MI('$WXMATCH', sTable_WeixinMatch),
                                      MI('$MWXID', nOpenID)]);
  //xxxxxx

  try
    nDS := gDBConnManager.SQLQuery(nSQLQuery, nDB);
    with nDS do
    begin
      if RecordCount<1 then
      begin
        Result := '��΢���˺�δ��';
        Exit;
      end;

      First;
      while not Eof do
      begin
        nListA.Clear;

        with nListA do
        begin
          Values['DateStart'] := DateTime2Str(Today);
          Values['DateEnd']   := DateTime2Str(Today + 1);
          Values['FactName']  := '';
          Values['CusName']   := '';

          Values['Factory'] := FieldByName('M_WXFactory').AsString;
          Values['AttentionID']:= FieldByName('M_AttentionID').AsString;
          Values['AttentionType']:= FieldByName('M_AttentionType').AsString;
        end;

        nListB.Clear;
        if SplitStr(nSearch, nListB, 0, ',') then
        begin
          for nIdx:=0 to nListB.Count-1 do
          begin
            case nIdx of
            0: nListA.Values['DateStart'] := DateTime2Str(StrToDateDef(nListB[nIdx], Today));
            1: nListA.Values['DateEnd']   := DateTime2Str(StrToDateDef(nListB[nIdx], Today+1));
            2: nListA.Values['FactName']  := nListB[nIdx];
            3: nListA.Values['CusName']   := nListB[nIdx];
            end;
          end;
        end;

        nStr := FieldByName('M_AttentionID').AsString;
        if (nStr = '') then
        begin
          Result := '�����رտͻ�΢��ҵ��';
          Next;Continue;
        end;

        nStr := FieldByName('M_isValid').AsString;
        if nStr <> sFlag_Yes then
        begin
          Result := '�����رտͻ�΢��ҵ��';
          Next;Continue;
        end;


        nStr := nListA.Values['Factory'];
        nFactName := GetFactName(nStr);
        if (nFactName='') or
          ((nListA.Values['FactName'] <> '')
          and (Pos(nListA.Values['FactName'], nStr)<1))
        then
        begin
          Result := '�����رտͻ�΢��ҵ��';
          Next;Continue;
        end;
        //�жϹ����Ƿ����

        if not FWXBusiness.GetReport(PackerEncodeStr(nListA.Text),
          nStr, nStr) then
        begin
          Result := '��ѯ���ִ������Ժ�����';
          Exit;
        end;

        nListC.Clear;
        nListC.Text := PackerDecodeStr(nStr);
        Result := Result + #13#10 + '��������:' + nFactName;

        for nIdx:=0 to nListC.Count-1 do
        begin
          nListB.Clear;
          nListB.Text := PackerDecodeStr(nListC[nIdx]);

          nStr := '����:%s ��%s�� ������:%s��';
          nStr := Format(nStr, [nListB.Values['StockName'],
                  nListB.Values['Count'],
                  nListB.Values['Value']]);
          Result := Result + #13#10 + nStr;
        end;

        Next;
      end;
    end;
  finally
    if Result = '' then
      Result := '���޳�����Ϣ';

    gDBConnManager.ReleaseConnection(nDB);
    nListA.Free;
    nListB.Free;
    nListC.Free;
  end;
end;

//Date: 2015/4/21
//Parm: ��������;΢�ſ�����ID��
//Desc: ��ȡָ�������Ĵ�װ����ͳ��
function TWXSearchData.GetWXFactQueue(nSearch: string; nOpenID: string = '';
  nCmd: string = ''): string;
var nIdx: Integer;
    nStr: string;
begin
  if not FWXBusiness.GetQueueList(nStr, nStr) then
  begin
    Result := '��ѯ���ִ������Ժ�����';
    Exit;
  end;

  FListC.Clear;
  FListC.Text := PackerDecodeStr(nStr);
  Result := '��������:' + gWXSysParam.FFactName + #13#10;
  //Result := Result + '��������  ͨ���� ����' + #13#10;

  for nIdx:=0 to FListC.Count-1 do
  begin
    FListB.Clear;
    FListB.Text := PackerDecodeStr(FListC[nIdx]);

    nStr := '��������:%s' + #13#10;
    nStr := Format(nStr, [FListB.Values['StockName']]);
    Result := Result + nStr;

    nStr := '����ͨ��:%s' + #13#10;
    nStr := Format(nStr, [FListB.Values['LineCount']]);
    Result := Result + nStr;

    nStr := '�Ŷӳ���:%s' + #13#10;
    nStr := Format(nStr, [FListB.Values['TruckCount']]);
    Result := Result + nStr;

    Result := Result + #13#10;

//    nStr := '%s  %s  %s';
//    nStr := Format(nStr, [FListB.Values['StockName'],
//            FListB.Values['LineCount'],
//            FListB.Values['TruckCount']]);
//    Result := Result + #13#10 + nStr;
  end;
end;

function TWXSearchData.GetRetStrFromFile(nFile: string = ''): string;
var
  nSSRet: TStrings;
  nFileName: string;
begin
  nSSRet := TStringList.Create;
  try
    nFileName := gWeiXinPath + 'Template\' + nFile;
    if not FileExists(nFileName) then
    begin
      nFileName := gWeiXinPath + 'Template\' + '0000.Txt';
    end;

    nSSRet.LoadFromFile(nFileName);
    Result := nSSRet.Text;
  finally
    FreeAndNil(nSSRet);
  end;
end;

function TWXSearchData.SearchStr(nSeachStr: string = '';
  nOpenID: string = ''): string;
var
  nPos: Integer;
  nCommand: string;
begin
  nPos := Pos('#', nSeachStr);
  if nPos > 0 then
  begin
    nCommand := Copy(nSeachStr, 1, nPos - 1);
    Delete(nSeachStr, 1, nPos);
  end else
  begin
    nCommand := nSeachStr;
    Delete(nSeachStr, 1, Length(nCommand));
  end;

  if IsNumber(nCommand, False) then
  begin
    case StrToInt(nCommand) of
      1001: //  ���˻���Ϣ
        Result := BindPersonInfo(nSeachStr, nOpenID);
      1002: //����󶨰�OpenID
        Result := unBindPersonMap(nOpenID);
      {2001: //��ȡ�˻��������
        Result := GetWXValidMoney(nOpenID, nCommand);
      2002: //��ȡֽ���������
        Result := GetWXZhiKaMoney(nSeachStr, nOpenID, nCommand);
      2003: //��ȡ�˻�ֽ���б�
        Result := GetWXZhiKaList(nOpenID);
      2004: //��ȡ�˻��������
        Result := GetWXFreezeMoney(nOpenID, nCommand);    }
      2001: //��Ʒ��α���ѯ
        Result := GetValidInfo(nSeachStr, nOpenID, nCommand);
      2002: //���ۼ۸��ѯ
        Result := GetSalePInfo(nSeachStr, nOpenID, nCommand);
      {4001: //�ձ����ѯ
        Result := GetWXReportStr(nSeachStr, nOpenID, nCommand); }
      3001: //��װ������ѯ
        Result := GetWXFactQueue(nSeachStr, nOpenID, nCommand);
    else
      Result := GetRetStrFromFile(nCommand + '.txt');
    end;
  end else
  begin
    Result := GetRetStrFromFile('0000.txt');
  end;
end;

function TWXSearchData.CheckDataVaild(nStrSrc: string;
  var nLID, nOutNum: string):Boolean;
var
  nStr: string;
begin
  //151018P02151015��01141
  Result := False;
  nStr   := Trim(nStrSrc);
  if Length(nStr) < 18 then Exit;

  nLID    := Trim(LeftStr(nStr, 6)) + Trim(RightStr(nStr, Length(nStr)-18));
  nOutNum := Trim(Copy(nStr, 8, 8)) + '��'+ Trim(Copy(RightStr(nStr, 5), 1, 2));

  Result := True;
end;
//------------------------------------------------------------------------------
constructor TWXBusiness.Create;
begin
  inherited Create;
end;

destructor TWXBusiness.Destroy;
begin
  inherited Destroy;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ�ҵ���������
function CallBusinessCommand(const nCmd: Integer;
  const nData,nExt: string; const nOut: PWorkerBusinessCommand;
  const nFactory: string = ''): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FParam := nFactory;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_BusinessCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

function CallHardwareCommand(const nCmd: Integer;
  const nData,nExt: string; const nOut: PWorkerBusinessCommand;
  const nFactory: string = ''): Boolean;
var nIn: TWorkerBusinessCommand;
    nWorker: TBusinessWorkerBase;
begin
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;
    nIn.FBase.FParam := nFactory;

    nWorker := gBusinessWorkerManager.LockWorker(sCLI_HardwareCommand);
    //get worker
    Result := nWorker.WorkActive(@nIn, nOut);

    if not Result then
      WriteLog(nOut.FBase.FErrDesc);
    //xxxxx
  finally
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-14
//Parm: ֽ����;�Ƿ�����
//Desc: ��ȡnZhiKa�Ŀ��ý�Ŷ
function TWXBusiness.GetZhikaValidMoney(nZhiKa: string;
  var nFixMoney: Boolean; const nFactory: string=''): Double;
var nOut: TWorkerBusinessCommand;
begin
  if CallBusinessCommand(cBC_GetZhiKaMoney, nZhiKa, '', @nOut, nFactory) then
  begin
    Result := StrToFloat(nOut.FData);
    nFixMoney := nOut.FExtParam = sFlag_Yes;
  end else Result := 0;
end;

function TWXBusiness.GetCustomerValidMoney(nCID: string; const nLimit: Boolean;
 const nValidMoney: PDouble; const nCredit: PDouble;
 const nFactory: string): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  if nLimit then
       nStr := sFlag_Yes
  else nStr := sFlag_No;

  if CallBusinessCommand(cBC_GetCustomerMoney, nCID, nStr, @nOut, nFactory) then
  begin
    Result := True;
    if Assigned(nCredit) then
      nValidMoney^ := StrToFloat(nOut.FData);
    if Assigned(nCredit) then
      nCredit^ := StrToFloat(nOut.FExtParam);
    //xxxxx
  end else
  begin
    Result := False;
    if Assigned(nCredit) then
      nValidMoney^ := 0;
    if Assigned(nCredit) then
      nCredit^ := 0;
    //xxxxx
  end;
end;

function TWXBusiness.GetQueueList(var nOutData: string;
  const nFactory: string=''):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallHardwareCommand(cBC_GetQueueList, 'Y', '', @nOut, nFactory);
  if (not Result) or (nOut.FData='') then Exit;
  nOutData := nOut.FData;
end;

function TWXBusiness.GetReport(nCondition: string;var nOutData: string;
  const nFactory: string=''):Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetWeiXinReport, nCondition, '', @nOut, nFactory);
  if (not Result) or (nOut.FData='') then Exit;
  nOutData := nOut.FData;
end;
//Date: 2012-3-11
//Parm: ��־����
//Desc: ��¼��־
procedure TWX2MITWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(ClassType, '΢�ſͻ�ҵ�����', nEvent);
end;

constructor TWX2MITWorker.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  inherited;
end;

destructor TWX2MITWorker.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  inherited;
end;

//Date: 2012-3-11
//Parm: ���;����
//Desc: ִ��ҵ�񲢶��쳣������
function TWX2MITWorker.DoWork(const nIn, nOut: Pointer): Boolean;
var nStr: string;
    nParam: string;
    nArray: TDynamicStrArray;
begin
  with PBWDataBase(nIn)^,gWXSysParam do
  begin
    nParam := FParam;
    FPacker.InitData(nIn, True, False);

    with FFrom do
    begin
      FUser   := FUserID;
      FIP     := FLocalIP;
      FMAC    := FLocalMAC;
      FTime   := Now;
      FKpLong := GetTickCount;
    end;
  end;

  nStr := FPacker.PackIn(nIn);
  Result := MITWork(nStr, nParam);

  if not Result then
  begin
    PBWDataBase(nOut)^.FErrDesc := nStr;
    Exit;
  end;

  FPacker.UnPackOut(nStr, nOut);
  with PBWDataBase(nOut)^ do
  begin
    nStr := 'User:[ %s ] FUN:[ %s ] TO:[ %s ] KP:[ %d ]';
    nStr := Format(nStr, [gWXSysParam.FUserID, FunctionName, FVia.FIP,
            GetTickCount - FWorkTimeInit]);
    {$IFDEF DEBUG}
    WriteLog(nStr);
    {$ENDIF}
    Result := FResult;
    if Result then
    begin
      if FErrCode = sFlag_ForceHint then
      begin
        nStr := 'ҵ��ִ�гɹ�,��ʾ��Ϣ����: ' + #13#10#13#10 + FErrDesc;
        WriteLog(nStr);     //��Ϊ��������������ʾ�������ֹҵ��
      end;

      Exit;
    end;

    if FErrCode = sFlag_ForceHint then
    begin
      SetLength(nArray, 0);

      nStr := 'ҵ��ִ���쳣,��������: ' + #13#10#13#10 +

              ErrDescription(FErrCode, FErrDesc, nArray) +

              '������������������Ƿ���Ч,����ϵ����Ա!' + #32#32#32;
      WriteLog(nStr);
    end;
  end;
end;

//Date: 2012-3-20
//Parm: ����;����
//Desc: ��ʽ����������
function TWX2MITWorker.ErrDescription(const nCode, nDesc: string;
  const nInclude: TDynamicStrArray): string;
var nIdx: Integer;
begin
  FListA.Text := StringReplace(nCode, #9, #13#10, [rfReplaceAll]);
  FListB.Text := StringReplace(nDesc, #9, #13#10, [rfReplaceAll]);

  if FListA.Count <> FListB.Count then
  begin
    Result := '��.����: ' + nCode + #13#10 +
              '   ����: ' + nDesc + #13#10#13#10;
  end else Result := '';

  for nIdx:=0 to FListA.Count - 1 do
  if (Length(nInclude) = 0) or (StrArrayIndex(FListA[nIdx], nInclude) > -1) then
  begin
    Result := Result + '��.����: ' + FListA[nIdx] + #13#10 +
                       '   ����: ' + FListB[nIdx] + #13#10#13#10;
  end;
end;

//Desc: ǿ��ָ�������ַ
function TWX2MITWorker.GetFixedServiceURL: string;
begin
  Result := '';
end;

function TWX2MITWorker.GetFixedServiceURL_2(const nFactory: string=''): string;
begin
  Result := '';
end;

//Date: 2012-3-9
//Parm: �������
//Desc: ����MITִ�о���ҵ��
function TWX2MITWorker.MITWork(var nData: string;const nFactory: string=''): Boolean;
var nChannel: PChannelItem;
    nURL: string;
begin
  Result := False;
  nChannel := nil;
  try
    nChannel := gChannelManager.LockChannel(cBus_Channel_Business);
    if not Assigned(nChannel) then
    begin
      nData := '����MIT����ʧ��(BUS-MIT No Channel).';
      Exit;
    end;

    with nChannel^ do
    while True do
    try
      if not Assigned(FChannel) then
        FChannel := CoSrvBusiness.Create(FMsg, FHttp);
      //xxxxx

      nURL := GetFixedServiceURL_2(nFactory);
      if nURL = '' then
           FHttp.TargetURL := gChannelChoolser.ActiveURL
      else FHttp.TargetURL := nURL;

      Result := ISrvBusiness(FChannel).Action(GetFlagStr(cWorker_GetMITName),
                                              nData);
      //call mit funciton
      Break;
    except
      on E:Exception do
      begin
        if (nURL <> '') or
           (gChannelChoolser.GetChannelURL = FHttp.TargetURL) then
        begin
          nData := Format('%s(BY %s ).', [E.Message, gWXSysParam.FLocalName]);
          WriteLog('Function:[ ' + FunctionName + ' ]' + E.Message);
          Exit;
        end;
      end;
    end;
  finally
    gChannelManager.ReleaseChannel(nChannel);
  end;
end;
//------------------------------------------------------------------------------
class function TWXHareworeCommand.FunctionName: string;
begin
  Result := sCLI_HardwareCommand;
end;

function TWXHareworeCommand.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_HardwareCommand;
  end;
end;

//Desc: ǿ��ָ�������ַ
function TWXHareworeCommand.GetFixedServiceURL_2(const nFactory: string=''): string;
var nStr: string;
    nDB: PDBWorker;
begin
  if nFactory = '' then Exit;
  nStr := 'Select D_Value from %s where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_HardSrvURL, nFactory]);
  //xxxxxx

  try
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount<1 then Exit;
      Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;

//------------------------------------------------------------------------------
class function TWXBusinessCommand.FunctionName: string;
begin
  Result := sCLI_BusinessCommand;
end;

function TWXBusinessCommand.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
   cWorker_GetMITName    : Result := sBus_BusinessCommand;
  end;
end;

//Desc: ǿ��ָ�������ַ
function TWXBusinessCommand.GetFixedServiceURL_2(const nFactory: string=''): string;
var nStr: string;
    nDB: PDBWorker;
begin
  if nFactory = '' then Exit;
  nStr := 'Select D_Value from %s where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL, nFactory]);
  //xxxxxx

  try
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount<1 then Exit;
      Result := Fields[0].AsString;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;
//------------------------------------------------------------------------------
constructor TWXHttpsRequest.Create;
begin
  inherited Create;
  FWXIdHttps := TIdHTTP.Create;
  FWXIdSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
end;

destructor TWXHttpsRequest.Destroy;
begin
  FreeHttpsClient;
  inherited Destroy;
end;

procedure TWXHttpsRequest.InitHttpsClient(nVersion: TIdSSLVersion=sslvTLSv1);
begin
  if not Assigned(FWXIdHttps) then FWXIdHttps := TIdHTTP.Create;
  if not Assigned(FWXIdSSLHandler) then
    FWXIdSSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create;
  //xxxxxx

  with FWXIdSSLHandler do
  begin
    //SSLOptions           ���������¸�ֵ�����򽫱�SOCKET ERROR #0
    //TIdSSLVersion = (sslvSSLv2, sslvSSLv23, sslvSSLv3, sslvTLSv1);
    SSLOptions.Method := nVersion;
  end;

  with FWXIdHttps do
  begin
    AllowCookies := True;
    HandleRedirects := True;
    IOHandler := FWXIdSSLHandler;
  end;
  //����httpsЭ��������
end;

procedure TWXHttpsRequest.FreeHttpsClient;
begin
  if Assigned(FWXIdHttps) then FreeAndNil(FWXIdHttps);
  if Assigned(FWXIdSSLHandler) then FreeAndNil(FWXIdSSLHandler);
  //xxxxxx
end;

function TWXHttpsRequest.HttpsRequest(nUrl, uMothed: string;
  var nResponseStr: string; nParams: string = ''): Boolean;
var
  nWRtStream: TStream;
  nStrStream: TStringStream;
begin
  Result := False;
  nResponseStr := '';
  nStrStream := TStringStream.Create('');

  try
    try
    if UpperCase(uMothed) = 'GET' then
    begin
      FWXIdHttps.Get(nUrl, nStrStream);
    end
    else if UpperCase(uMothed) = 'POST' then
    begin
      //ascתutf-8
      nWRtStream := TStringStream.Create(UTF8Encode(nParams));
      FWXIdHttps.Post(nUrl, nWRtStream, nStrStream);
    end
    else if UpperCase(uMothed) = 'PUT' then
    begin
      nWRtStream := TFileStream.Create(nParams , 0);
      FWXIdHttps.Put(nUrl, nWRtStream, nStrStream);
    end;

    if FWXIdHttps.ResponseCode <> 200 then
      Exit;

    nResponseStr := UTF8Decode(nStrStream.DataString);
    Result := True;

    except
      if FWXIdHttps.ResponseCode = 200 then
      begin
        nResponseStr := UTF8Decode(nStrStream.DataString);
        Result := True;
      end;

      FreeHttpsClient;
      InitHttpsClient;
    end;
  finally
    FreeAndNil(nStrStream);
  end;
end;
//------------------------------------------------------------------------------
{TWXSendTempMsgLog}
constructor TWXSendTempMsgLog.Create(AOwner: TWXMessageMgr);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 5* 1000;

  FNewTickCount := 0;
  FOldTickCount := FNewTickCount;
end;

destructor TWXSendTempMsgLog.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TWXSendTempMsgLog.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TWXSendTempMsgLog.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    DoExecute;
    //ִ�з���ģ����־��Ϣ
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
      Sleep(500);
    end;
  end;
end;


procedure TWXSendTempMsgLog.DoExecute;
begin
  FNewTickCount := GetTickCount;
  if (FNewTickCount - FOldTickCount)/1000 > 20*60 then
  begin
    FOwner.WXTPMessageSendFromLog;
    FOldTickCount := FNewTickCount;
  end;
end;

//------------------------------------------------------------------------------
{TWXSendTecentTMsg}
constructor TWXSendTecentTMsg.Create(AOwner: TWXMessageMgr);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 5* 1000;
end;

destructor TWXSendTecentTMsg.Destroy;
begin
  FWaiter.Free;
  inherited;
end;

procedure TWXSendTecentTMsg.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TWXSendTecentTMsg.Execute;
begin
  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    DoExecute;
    //ִ�з���ģ�漴ʱ��Ϣ
  except
    on E: Exception do
    begin
      WriteLog(E.Message);
      Sleep(500);
    end;
  end;
end;


procedure TWXSendTecentTMsg.DoExecute;
var nPos: Integer;
  nData, nHint, nTempType: string;
begin
  with FOwner do
  begin
    FSyncLock.Enter;
    try
      if FDataList.Count < 1 then Exit;
      nData := FDataList[0];
      nData := DecodeBase64(nData);
      //��������

      nPos := Pos('#', nData);
      if nPos > 1 then
      begin
        nTempType := Copy(nData, 1, nPos - 1);
        System.Delete(nData, 1, nPos);
      end else nTempType := '';

      WriteLog('��ʼ����ģ����Ϣ: ' + nData);
      WXSendTemplateMsg(nTempType, nData, nHint);
      WriteLog('����ģ����Ϣ����.' + nHint);

      FDataList.Delete(0);
    finally
      FSyncLock.Leave;
    end;
  end;
end;
//------------------------------------------------------------------------------
{ TWXMessageMgr }
constructor TWXMessageMgr.Create;
var nIdx: Integer;
begin
  inherited Create;
  FHTMLDir := gWeiXinPath + 'WEBROOT';
  FWXTCPServer := TIdTCPServer.Create;
  FWXHttpsServer  := TIdHTTPServer.Create;
  FWXSearch := TWXSearchData.Create;
  //��ѯ
  FWXHttps  := TWXHttpsRequest.Create;
  //������Ϣ

  FDataList := TStringList.Create;
  FSyncLock := TCriticalSection.Create;
  FSycAcessToken := TCriticalSection.Create;
  //xxxxxx

  for nIdx:=Low(FTecentThreads) to High(FTecentThreads) do
    FTecentThreads[nIdx] := nil;
  //xxxxxx
  FSendLogThread := nil;

  FAppID := '';
  FAppSecret := '';
  FAppToken := G_WeixinTocken;
  with FAccess_Token do
  begin
    FLastTime := 0;
    FFieldValue := '';
    FExpires_in := 7200; 
  end;

  FWXType := TStringList.Create;
  with FWXType do
  begin
    Values['text'] := IntToStr(G_WeixinTextType);
    Values['link'] := IntToStr(G_WeixinLinkType);
    Values['image'] := IntToStr(G_WeixinImageType);
    Values['event'] := IntToStr(G_WeixinEventType);
    Values['voice'] := IntToStr(G_WeixinVoiceType);
    Values['video'] := IntToStr(G_WeixinVideoType);
  end;
end;

destructor TWXMessageMgr.Destroy;
begin
  FWXTCPServer.Free;
  FWXHttpsServer.Free;

  FWXType.Free;
  FWXHttps.Free;
  FWXSearch.Free;

  FDataList.Free;
  FSyncLock.Free;
  FSycAcessToken.Free;

  inherited Destroy;
end;
//Date: 2014/12/20
//Parm: ΢��HTTP��ѯ�˿ڣ�ģ����Ϣ�����˿�
//Desc: ΢�ŷ��������ӿ�
function TWXMessageMgr.WXStartService(nHttpsPort: Integer = 80;
  nTcpPort: Integer=8000): Boolean;
begin
  Result := False;
  if not Assigned(FWXHttpsServer) then
    FWXHttpsServer := TIdHTTPServer.Create;

  try
    InitSystemObject;
    if not RunSystemObject then Exit;
  except
    Exit;
  end;

  with FWXHttpsServer do
  begin
    try
      if Active then
        Active := False;

      with Bindings do
      begin
        Clear;
        DefaultPort := nHttpsPort;
        Add;
      end;
      //�󶨶˿�

      Active := True;
      //��������

      OnCommandGet := wxhttpServerCommandGet;
      //ָ������
    except
      on E: Exception do
      begin
        WriteLog('WXStartService HttpsServer Failed');
        Exit;
      end;
    end;
  end;

  if gWXSysParam.FIsWithMIT <> sFlag_Yes then
  begin
//    with FWXTCPServer do
//    begin
//      try
//        if Active then Active:= False;
//        OnExecute := IdTCPServerExecute;
//        DefaultPort := nTcpPort;
//        Active := True;
//
//        FDataList.Clear;
//        StartSendTecent;
//        //���ü�ʱ����
//      except
//        on E: Exception do
//        begin
//          WriteLog('WXStartService TCPServer Failed');
//          Exit;
//        end;
//      end;
//    end;

    FDataList.Clear;
    StartSendTecent;
    //���ü�ʱ����
  end;

  Result := FWXHttpsServer.Active = True;
  if Result then
  begin
    FSendLogThread := TWXSendTempMsgLog.Create(Self);
    //������ʱ���ʹ�����Ϣ
  end;
end;
//Date: 2014/12/20
//Parm:
//Desc: ֹͣ����
procedure TWXMessageMgr.WXStopService;
begin
  try
    if gWXSysParam.FIsWithMIT <> sFlag_Yes then
      FWXTCPServer.Active := False;
    FWXHttpsServer.Active := False;

    StopSendTecent;
    //ģ����Ϣ����ֹͣ

    FSendLogThread.Terminate;
    FSendLogThread.StopMe;
    FSendLogThread:=nil;
  except
  end;
end;

function TWXMessageMgr.SHA1(Input: String): String;
begin
  with TIdHashSHA1.Create do
  try
    Result := UpperCase(HashBytesAsHex(ToBytes(Input)));
  finally
    Free;
  end;
end;

function TWXMessageMgr.checkSignature(nSignature, nTimestamp,
  nNonce, nEchostr: string): Boolean;
var
  nStrTmp: string;
  nStrListTmp: TStringList;
begin
  Result := False;
  nStrListTmp := TStringList.Create;

  try
    nStrListTmp.Add(nNonce);
    nStrListTmp.Add(FAppToken);
    nStrListTmp.Add(nTimestamp);

    nStrListTmp.Sort;
    nStrTmp := nStrListTmp[0] + nStrListTmp[1] + nStrListTmp[2];
    nStrTmp := SHA1(nStrTmp);
    if nStrTmp = UpperCase(nSignature) then
      Result := True;
  finally
    nStrListTmp.Free;
  end;
end;

procedure TWXMessageMgr.wxhttpServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  nInputParam: TStrings;
  nRequetStr, nReponseStr, nFilename, nPathname: string;
begin
  nInputParam := TStringList.Create;

  try
    nInputParam := ARequestInfo.Params;
    case ARequestInfo.CommandType of
      hcGET:
        begin
          //����Ϊ��ʱ����ʾ��֤������Ϣ
          if nInputParam.Values['echostr'] = '' then
          begin
            if ARequestInfo.Document = '/' then
              nFilename := '/index.html'
            else
              nFilename := ARequestInfo.Document;

            nPathname := FHTMLDir + nFilename;

            if FileExists(nPathname) then begin
              AResponseInfo.ContentStream := TFileStream.Create(nPathname, fmOpenRead + fmShareDenyWrite);
            end else begin
              AResponseInfo.ResponseNo := 404;
              AResponseInfo.ContentText := 'The requested URL ' + ARequestInfo.Document + ' was not found on this server.';
            end;
          end
          else
          begin
            if checkSignature(nInputParam.Values['signature'],
              nInputParam.Values['timestamp'], nInputParam.Values['nonce'],
              nInputParam.Values['echostr']) then
            begin
              AResponseInfo.ContentText := nInputParam.Values['echostr'];
            end else
            begin
              AResponseInfo.ContentText := '';
            end;  
          end;
        end;
      hcPOST:
        begin
          if UpperCase(ARequestInfo.ContentType) = 'TEXT/XML' then
          begin
            if not checkSignature(nInputParam.Values['signature'],
              nInputParam.Values['timestamp'], nInputParam.Values['nonce'],
              nInputParam.Values['echostr']) then
            begin
              AResponseInfo.ContentText := '';Exit;
            end;

            nInputParam.Clear;
            nInputParam.LoadFromStream(ARequestInfo.PostStream);
            nRequetStr := UTF8Decode(nInputParam.Text);

            WriteLog('nRequest>>' + nRequetStr);
            WXDealMsg(nRequetStr, nReponseStr);
            WriteLog('nResponse>>' + nReponseStr);
          end
          else
          begin
            nInputParam.Clear;
            nInputParam.Append(ARequestInfo.FormParams);
            nRequetStr := UTF8Encode(StringReplace(nInputParam.Text, '&',
              #13#10, [rfReplaceAll]));
            WriteLog('nRequest>>' + nRequetStr);
            nReponseStr:= '��ӭ��!';

            //WXDealHtmlMsg(nRequetStr, nReponseStr);
          end;

          AResponseInfo.ContentEncoding := 'utf8';
          AResponseInfo.ContentText     := UTF8Encode(nReponseStr);
          AResponseInfo.ContentLength   := Length(UTF8Encode(nReponseStr));
        end;
    else
      AResponseInfo.ContentText := ''
    end;
  finally
    nInputParam.Clear;
  end;
end;
//Date: 2015/3/17
//Parm: ���յ�http���󣻷�����Ϣ
//Desc:
procedure TWXMessageMgr.WXDealHtmlMsg(nRequest: string;var nResponse: string);
begin
  nResponse := FWXSearch.SearchStr(nRequest);
end;

function TWXMessageMgr.PacketTextMsg(nstrWXMsg: string;
  nSO: ISuperObject): string;
var
  nRetStr, nCreateTime: string;
begin
  nCreateTime := IntToStr(GetNowUnixTime);
  nRetStr := '<xml>' +
    '<ToUserName><![CDATA[$TOUSER]]></ToUserName>' +
    '<FromUserName><![CDATA[$FROMUSER]]></FromUserName>' +
    '<CreateTime>$CREATETIME</CreateTime>' +
    '<MsgType><![CDATA[text]]></MsgType>' +
    '<Content><![CDATA[$CONTENTTEXT]]></Content>' +
    '</xml>';

  Result := MacroValue(nRetStr, [MI('$TOUSER', nSO['FromUserName'].AsString),
                                 MI('$FROMUSER', nSO['ToUserName'].AsString),
                                 MI('$CREATETIME', nCreateTime),
                                 MI('$CONTENTTEXT', nstrWXMsg)]);
   //xxxxxx
end;
//Date: 2014/12/20
//Parm: ���յ���Ѷ΢�ŷ��������󣻷�����Ϣ
//Desc: ����΢�ŷ�������
procedure TWXMessageMgr.WXDealMsg(nRequest:string;var nResponse:string);
var nSO:ISuperObject;
    nSendMsg: string;
begin
  nSO := XMLParseString(nRequest, True);

  case StrToInt(FWXType.Values[LowerCase(nSO['MsgType'].AsString)]) of
  G_WeixinTextType:
  begin
    nSendMsg := FWXSearch.SearchStr(nSO['Content'].AsString,
      nSO['FromUserName'].AsString);
  end;
  G_WeixinEventType:
  begin
    if UpperCase(nSO['Event'].AsString) = 'CLICK' then //subscribe ��ע��Ϣ
    begin
      nSendMsg := FWXSearch.SearchStr(nSO['EventKey'].AsString,
        nSO['FromUserName'].AsString);
    end
    else
    begin
      nSendMsg := FWXSearch.SearchStr();
    end
  end;
  G_WeixinLinkType,G_WeixinImageType,G_WeixinVideoType,G_WeixinVoiceType:
  begin
     nSendMsg := nSO['MsgType'].AsString;
  end;
  end;

  if Length(nSendMsg) > 1300 then
      nSendMsg := '����ѯ�����������������������ʽ��ѯ';
  nResponse := PacketTextMsg(nSendMsg, nSO);
end;
//Date: 2014/12/20
//Parm: �˵���ʽ�ļ����ͣ��˵���ʽ�ļ���
//Desc: ���ݲ˵���ʽ������΢���Զ���˵�
function TWXMessageMgr.WXCreateMenus(nFileType, nFileName: string): Boolean;
var
  nMenus: TStrings;
  nSO: ISuperObject;
begin
  nMenus := TStringList.Create;
  try
    if UpperCase(nFileType) = 'XML' then
    begin
      nMenus.LoadFromFile(nFileName);
      nSO := XMLParseString(nMenus.Text, True);
      Result := CreateMenu(nSO.AsString);
    end else
    begin
      nMenus.LoadFromFile(nFileName);
      Result := CreateMenu(nMenus.Text);
    end;
  finally
    FreeAndNil(nMenus);
  end;
end;
//Date: 2014/12/20
//Parm:
//Desc: ɾ��΢���Զ���˵�
function TWXMessageMgr.WXDeleteMenu: Boolean;
begin
  Result := DeleteMenu;
end;

function TWXMessageMgr.GetTokenStr: string;
begin
  FSycAcessToken.Enter;
  try
    Result := FAccess_Token.FFieldValue;
  finally
    FSycAcessToken.Leave;
  end;
end;  
//Date: 2014/12/20
//Parm: ΢�Ź��ں�AppID��AppSecret���Ƿ�ǿ�ƻ�ȡ����
//Desc: �ڹ���ƽ̨����ģʽ�£���ȡ��֤���ݡ�
function TWXMessageMgr.WXGetAccessToken(nAppid: string = '';
  nAppsecret: string = ''; nFlag: Boolean = False): Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nErrLog, nRetstr: string;
begin
  FSycAcessToken.Enter;
  try
  Result := True;
  if (nAppid <> '') and (nAppsecret <> '') then
  begin
    FAppid := nAppid;
    FAppsecret := nAppsecret;
  end;

  nUrl := 'https://api.weixin.qq.com/cgi-bin/token' +
          '?grant_type=client_credential&appid=$APPID' +
          '&secret=$APPSECRET';
  nUrl := MacroValue(nUrl, [MI('$APPID', FAppid),
                            MI('$APPSECRET', FAppsecret)]);
  //xxxxxxx

  if (FAccess_Token.FLastTime = 0) or //ϵͳ��������
    (GetNowUnixTime - FAccess_Token.FLastTime > FAccess_Token.FExpires_in) or //��ʱʧЧ
    nFlag then //ǿ�Ƹ���access_token
  begin
    Result := FWXHttps.HttpsRequest(nUrl, 'Get', nRetstr);
    if Result then
    begin
      nSO := SO(nRetstr);

      if Pos('errcode', nRetstr) > 0 then
      begin
        Result := False;
        FAccess_Token.FLastTime := 0;
        FAccess_Token.FFieldValue := '';
        FAccess_Token.FExpires_in := 7200;

        nErr := nSO['errcode'].AsInteger;
        nErrLog := 'WXGetAcessToken Error:ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
        nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                        MI('$ERRMSG', GetErrMsgByCode(nErr))]);
        WriteLog(nErrLog);
      end
      else begin
        FAccess_Token.FLastTime := GetNowUnixTime;
        FAccess_Token.FExpires_in := nSO['expires_in'].AsInteger;
        FAccess_Token.FFieldValue := nSO['access_token'].AsString;
      end;
    end;
  end;
  finally
    FSycAcessToken.Leave;
  end;
end;
//Date: 2014/12/20
//Parm: �ͷ���Ϣ����
//Desc: ���Ϳͻ���Ϣ��ǰ����������ǰ��24Сʱ�ڣ��й����ݽ�����
function TWXMessageMgr.WXSendCustomMessage(nParams: string): Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nErrLog, nRetstr: string;
begin
  Result := WXGetAccessToken;
  if not Result then Exit;
  //xxxxxx

  nUrl := 'https://api.weixin.qq.com/cgi-bin/message/custom/send' +
          '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  Result := FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr, nParams);
  if not Result then Exit;

  nSO := SO(nRetStr);
  nErr := nSO['errcode'].AsInteger;
  nErrLog := 'WXSendCustomMessage :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
  nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                  MI('$ERRMSG', GetErrMsgByCode(nErr))]);
  WriteLog(nErrLog);

  case nErr of
  40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
  end;

  Result := nErr = 0;
end;
//Date: 2014/12/20
//Parm: ģ����Ϣ���ݣ�����ģ����ϢID
//Desc: ����ģ����Ϣ��������ģ����ϢID
function TWXMessageMgr.WXSendTPMessage(nStrJSON: string;
  var nMsgID:string): string;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nErrLog, nRetstr: string;
begin
  Result := '';
  if not WXGetAccessToken then Exit;

  nUrl := 'https://api.weixin.qq.com/cgi-bin/message/template/send' +
    '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  if not FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr, nStrJSON) then Exit;

  nSO := SO(nRetStr); Result:=nRetstr;
  nErr := nSO['errcode'].AsInteger;
  nErrLog := 'WXSendTPMessage [$TEMPMSG]:ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
  nErrLog := MacroValue(nErrLog, [MI('$TEMPMSG', nStrJSON),
                                  MI('$ERRCODE', IntToStr(nErr)),
                                  MI('$ERRMSG', GetErrMsgByCode(nErr))]);
  WriteLog(nErrLog);

  case nErr of
  0:nMsgID := nSO['msgid'].AsString;
  40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
  end;
end;
//Date: 2014/12/19
//Parm: �ط���¼ID��������Ϣ
//Desc: ���ݼ�¼ID���·���ģ����Ϣ����¼ID����','���� ��:records=1,2,3,.....
procedure TWXMessageMgr.WXTPMessageReSend(nRIDs: string; var nHint: string);
var
  nCount: Integer;
  nSList: TStrings;
  nStr, nRet, nMsgID: string;
  nDB : PDBWorker;
begin
  nSList := TStringList.Create;

  try
    nSList.Text := nRIDs;
    nStr := nSList.Values['records'];
    if RightStr(nStr , 1) = ',' then
      nStr := Copy(nStr, 1, Length(nStr)-1);

    nStr := Format('Select * from %s where R_ID in (%s)',[sTable_WeixinLog,nStr]);
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount<1 then
      begin
        nHint := Format('��������[%s]��¼������!', [nRIDs]);
        Exit;
      end;

      First; nSList.Clear;
      while not Eof do
      begin
        nRet := ''; nMsgID := '';
        nCount := FieldByName('L_Count').AsInteger;

        nRet := WXSendTPMessage(DecodeBase64(FieldByName('L_Data').AsString),
          nMsgID);
        Inc(nCount);

        nStr := 'Update $WXLOG set L_MsgID=''$MSGID'',L_Result=''$RESULT''' +
                'L_Count=$COUNT,L_Date=GetDate(),L_Status=''Y'' where R_ID=$RID';
        nStr := MacroValue(nStr, [MI('$RESULT', EncodeBase64(nRet)),
                                  MI('$MSGID', nMsgID),
                                  MI('$WXLOG', sTable_WeixinLog),

                                  MI('$COUNT', IntToStr(nCount)),
                                  MI('$RID', FieldByName('R_ID').AsVariant)]);
        //xxxxxx
        nSList.Add(nStr);

        Next;    //xxxxxx
      end;

      gDBConnManager.ExecSQLs(nSList, True);
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
    FreeAndNil(nSList);
  end;
end;
//Date: 2014/12/20
//Parm:
//Desc: ������ʧ�ܻ���δ���͵�ģ����Ϣ�������·���
procedure TWXMessageMgr.WXTPMessageSendFromLog;
var nDB: PDBWorker;
  nCount: Integer;
  nSList: TStrings;
  nSO: ISuperObject;
  nStr, nRet, nMsgID,nComment: string;
begin
  nStr := 'Select * from $WXLOG where (L_Count<3 and L_MsgId='''') ' +
          'or L_Status<>''Y''';
  nStr := MacroValue(nStr, [MI('$WXLOG', sTable_WeixinLog)]);

  nSList := TStringList.Create;
  try
    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount < 1 then
      begin
         Exit;
      end;

      First;

      while not Eof do
      begin
        nRet := ''; nMsgID := '';
        nCount := FieldByName('L_Count').AsInteger;

        nRet := WXSendTPMessage(DecodeBase64(FieldByName('L_Data').AsString),
          nMsgID);
        Inc(nCount);

        nSO := SO(nRet);
        nComment := GetErrMsgByCode(nSO['errcode'].AsInteger);

        nStr := 'Update $WXLOG set L_MsgID=''$MSGID'',L_Result=''$RESULT'',' +
                'L_Count=$COUNT,L_Date=GetDate(),L_Status=''Y'',' +
                'L_Comment=''$COMMENT'' where R_ID=$RID';
        nStr := MacroValue(nStr, [MI('$RESULT', EncodeBase64(nRet)),
                                  MI('$MSGID', nMsgID),
                                  MI('$WXLOG', sTable_WeixinLog),

                                  MI('$COMMENT', nComment),
                                  MI('$COUNT', IntToStr(nCount)),
                                  MI('$RID', FieldByName('R_ID').AsVariant)]);
        //xxxxxx
        nSList.Add(nStr);

        Next;    //xxxxxx
      end;
    end;

    gDBConnManager.ExecSQLs(nSList, True);
  finally
    gDBConnManager.ReleaseConnection(nDB);
    FreeAndNil(nSList);
  end;
end;
//Date: 2014/12/22
//Parm: �����������ش����ɹ�ʱ������Ϣ
//Desc:��������
function TWXMessageMgr.WXCreateUserGroup(nGroupName: string;
  var nGroup: TWXGroupRecord): Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nStrJSON, nErrLog, nRetstr: string;
begin
  Result := WXGetAccessToken;
  if not Result then Exit;
  //xxxxxx

  nUrl := 'https://api.weixin.qq.com/cgi-bin/groups/create' +
          '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  nStrJSON := Format('{"group":{"name":"%s"}}', [nGroupName]);
  //xxxxxx

  Result := FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr, nStrJSON);
  if not Result then Exit;

  nSO := SO(nRetStr);
  if Pos('errcode', nRetstr) > 0 then
  begin
    nErr := nSO['errcode'].AsInteger;
    nErrLog := 'WXCreateUserGroup :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
    nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                    MI('$ERRMSG', GetErrMsgByCode(nErr))]);
    WriteLog(nErrLog);

    case nErr of
    40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
    end;
  end
  else
  begin
    nGroup.FGroupID := nSO['group.id'].AsInteger;
    nGroup.FGroupName := nSO['group.name'].AsString;

    nErr := 0;
  end;

  Result := nErr = 0;
end;
//Date: 2014/12/22
//Parm: ��ע��ID�������û����ڷ���ID
//Desc: ͨ���û���OpenID��ѯ�����ڵ�GroupID
function TWXMessageMgr.WXGetUserGroupID(nOpenID: string;
  var nGroupID:Int64): Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nStrJSON, nErrLog, nRetstr: string;
begin
  Result := WXGetAccessToken;
  if not Result then Exit;
  //xxxxxx

  nUrl := 'https://api.weixin.qq.com/cgi-bin/groups/getid' +
    '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  nStrJSON := Format('{"openid":"%s"}', [nOpenID]);
  //xxxxxx

  Result := FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr, nStrJSON);
  if not Result then Exit;

  nSO := SO(nRetStr);

  if Pos('errcode', nRetstr) > 0 then
  begin
    nErr := nSO['errcode'].AsInteger;
    nErrLog := 'WXGetUserGroupID :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
    nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                    MI('$ERRMSG', GetErrMsgByCode(nErr))]);
    WriteLog(nErrLog);

    case nErr of
    40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
    end;
  end
  else
  begin
    nErr := 0;
    nGroupID := nSO['groupid'].AsInteger;
  end;

  Result := nErr = 0;
end;
//Date: 2014/12/22
//Parm: ���ط����ַ��������ط�����Ϣ
//Desc: ��ѯ���з���
function TWXMessageMgr.WXGetUserGroups(var nGroupStr:string;
  var nGroups: TWXGroups): Boolean;
var
  nErr: Int64;
  nIndex: Integer;
  nSATmp: TSuperArray;
  nSO, nSOTmp: ISuperObject;
  nUrl, nRetstr, nErrLog: string;
begin
  Result := WXGetAccessToken;
  if not Result then Exit;
  //xxxxxx

  nUrl := 'https://api.weixin.qq.com/cgi-bin/groups/get' +
    '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  Result := FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr);
  if not Result then Exit;

  nSO := SO(nRetStr);

  if Pos('errcode', nRetstr) > 0 then
  begin
    nErr := nSO['errcode'].AsInteger;
    nErrLog := 'WXGetUserGroups :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
    nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                    MI('$ERRMSG', GetErrMsgByCode(nErr))]);
    WriteLog(nErrLog);

    case nErr of
    40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
    end;
  end
  else
  begin
    nErr := 0;
    nSATmp := nSO['groups'].AsArray;

    SetLength(nGroups, 0);
    for nIndex := 0 to nSATmp.Length - 1 do
    begin
      SetLength(nGroups, Length(nGroups) + 1);
      nSOTmp := SO(nSATmp[nIndex].AsString);
      nGroups[Length(nGroups) - 1].FGroupID := nSOTmp['id'].AsInteger;
      nGroups[Length(nGroups) - 1].FGroupName := nSOTmp['name'].AsString;
      nGroups[Length(nGroups) - 1].FGroupUCount := nSOTmp['count'].AsInteger;
    end;

    nGroupStr := nSO.AsString;
  end;


  Result := nErr = 0;
end;


//Date: 2014/12/22
//Parm: ����ID��������
//Desc: �޸ķ�����
function TWXMessageMgr.WXUpdateGroupName(nGroupID,
  nGroupName: string): Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nStrJSON, nErrLog, nRetstr: string;
begin
  Result := WXGetAccessToken;
  if not Result then Exit;
  //xxxxxx

  nUrl := 'https://api.weixin.qq.com/cgi-bin/groups/update' +
    '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  nStrJSON := Format('{"group":{"id":%s,"name":"%s"}}', [nGroupID, nGroupName]);
  //xxxxxx

  Result := FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr, nStrJSON);
  if not Result then Exit;

  nSO := SO(nRetStr);
  nErr := nSO['errcode'].AsInteger;
  nErrLog := 'WXUpdateGroupName :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
  nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                  MI('$ERRMSG', GetErrMsgByCode(nErr))]);
  WriteLog(nErrLog);

  case nErr of
  40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
  end;

  Result := nErr = 0;
end;

//�ƶ��û�����

function TWXMessageMgr.WXMoveUserGroup(nGroupID,
  nOpenID: string): Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nStrJSON, nErrLog, nRetstr: string;
begin
  Result := WXGetAccessToken;
  if not Result then Exit;
  //xxxxxx

  nUrl := 'https://api.weixin.qq.com/cgi-bin/groups/members/update' +
    '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  nStrJSON := Format('{"openid":"%s","to_groupid":%s}', [nOpenID, nGroupID]);
  //xxxxxx

  Result := FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr, nStrJSON);
  if not Result then Exit;

  nSO := SO(nRetStr);
  nErr := nSO['errcode'].AsInteger;
  nErrLog := 'WXMoveUserGroup :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
  nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                  MI('$ERRMSG', GetErrMsgByCode(nErr))]);
  WriteLog(nErrLog);

  case nErr of
  40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
  end;

  Result := nErr = 0;
end;
//Date: 2014/12/22
//Parm: ��ע��ID
//Desc: ��ȡ��ע����Ϣ
function TWXMessageMgr.WXGetUserInfo(nOpenID: string): TWXUserBaseInfo;
var
  nErr: Int64;
  nRet: Boolean;
  nSO: ISuperObject;
  nUrl, nRetstr, nErrLog: string;
begin
  if not WXGetAccessToken then Exit;
  //xxxxxx

  nUrl := 'https://api.weixin.qq.com/cgi-bin/user/info' +
    '?access_token=$ACCESS_TOKEN' +
    '&openid=$OPENID&lang=zh_CN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr),
    MI('$OPENID', nOpenID)]);

  nRet := FWXHttps.HttpsRequest(nUrl, 'Get', nRetstr);
  if not nRet then Exit;

  nSO := SO(nRetStr);
  if Pos('errcode', nRetstr)>0 then
  begin
    nErr := nSO['errcode'].AsInteger;
    nErrLog := 'WXGetUserInfo :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
    nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                    MI('$ERRMSG', GetErrMsgByCode(nErr))]);
    WriteLog(nErrLog);

    case nErr of
    40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
    end;
  end
  else
  begin
    Result.FSubscribe := nSO['subscribe'].AsInteger;
    Result.FSubscribe_time := nSO['subscribe_time'].AsInteger;

    Result.FOpenid := nSO['openid'].AsString;
    //Result.FUnionid := nSO['unionid'].AsString;
    Result.FNickname := nSO['nickname'].AsString;

    case nSO['sex'].AsInteger of
    1: Result.FSex := '��';
    2: Result.FSex := 'Ů';
    else
    Result.FSex := 'δ֪';
    end;

    Result.FCity := nSO['city'].AsString;
    Result.FCountry := nSO['country'].AsString;
    Result.FProvince := nSO['province'].AsString;

    Result.FLanguage := nSO['language'].AsString;
    Result.FHeadimgurl := nSO['headimgurl'].AsString;
  end;
end;


function TWXMessageMgr.CreateMenu(nWXMenu: string): Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nErrLog, nRetstr: string;
begin
  nUrl := 'https://api.weixin.qq.com/cgi-bin/menu/create' +
          '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  Result := FWXHttps.HttpsRequest(nUrl, 'Post', nRetstr, nWXMenu);
  if not Result then Exit;

  nSO := SO(nRetStr);
  nErr := nSO['errcode'].AsInteger;
  nErrLog := 'CreateMenu [$MENU]:ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
  nErrLog := MacroValue(nErrLog, [MI('$MENU', nWXMenu),
                                  MI('$ERRCODE', IntToStr(nErr)),
                                  MI('$ERRMSG', GetErrMsgByCode(nErr))]);
  WriteLog(nErrLog);

  case nErr of
  40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
  end;

  Result := nErr = 0;
end;

function TWXMessageMgr.DeleteMenu: Boolean;
var
  nErr: Int64;
  nSO: ISuperObject;
  nUrl, nErrLog, nRetstr: string;
begin
  nUrl := 'https://api.weixin.qq.com/cgi-bin/menu/delete' +
          '?access_token=$ACCESS_TOKEN';
  nUrl := MacroValue(nUrl, [MI('$ACCESS_TOKEN', GetTokenStr)]);

  Result := FWXHttps.HttpsRequest(nUrl, 'Get', nRetstr);
  if not Result then Exit;

  nSO := SO(nRetStr);
  nErr := nSO['errcode'].AsInteger;
  nErrLog := 'DeleteMenu :ErrCode[$ERRCODE]=>ErrMessage[$ERRMSG]';
  nErrLog := MacroValue(nErrLog, [MI('$ERRCODE', IntToStr(nErr)),
                                  MI('$ERRMSG', GetErrMsgByCode(nErr))]);
  WriteLog(nErrLog);

  case nErr of
  40001,40002,40014,41001,42001: WXGetAccessToken('','',True);
  end;

  Result := nErr = 0;
end;

procedure TWXMessageMgr.InitSystemObject;
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gWeiXinPath + 'logs\');
  //system loger

  if not Assigned(gChannelManager) then
  begin
    gChannelManager := TChannelManager.Create;
    gChannelManager.ChannelMax := 20;
  end;

  if not Assigned(gChannelChoolser) then
  begin
    gChannelChoolser := TChannelChoolser.Create('');
    gChannelChoolser.AutoUpdateLocal := False;
  end;
  //channel

  InitSystemDBMgr;
  //���ݿ����ӳ�

  FWXHttps.InitHttpsClient;
end;

procedure TWXMessageMgr.WXAddTemMsg(nMsg: string);
begin
  FSyncLock.Enter;
  try
    FDataList.Add(nMsg);
  finally
    FSyncLock.Leave;
  end;

  WriteLog(Format('����ģ����Ϣ: %s', [nMsg]));
  //loged
end;  

procedure TWXMessageMgr.IdTCPServerExecute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E: Exception do
    begin
      AContext.Connection.IOHandler.InputBuffer.Clear;
      WriteLog(E.Message);
    end;
  end;
end;

procedure TWXMessageMgr.DoExecute(const nContext: TIdContext);
var nBuf: TIdBytes;
  nBase: TWXDataBase;
begin
  with nContext.Connection do
  begin
    Socket.ReadBytes(nBuf, cSizeWXDataBase, False);
    BytesToRaw(nBuf, nBase, cSizeWXDataBase);

    case nBase.FCommand of
      cWXCmd_SendMsg:
        begin
          SendTPMsgExecute(nBase, nBuf, nContext);
        //Send Template Message
        end;
    end;
  end;
end;

procedure TWXMessageMgr.SendTPMsgExecute(var nBase: TWXDataBase; var nBuf: TIdBytes;
  nCtx: TIdContext);
var nStr: WideString;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));

  FSyncLock.Enter;
  try
    FDataList.Add(nStr);
  finally
    FSyncLock.Leave;
  end;

  WriteLog(Format('����ģ����Ϣ: %s', [nStr]));
  //loged
end;


procedure TWXMessageMgr.StartSendTecent;
var nIdx,nNum: Integer;
begin
  nNum := 0;
  for nIdx:=Low(FTecentThreads) to High(FTecentThreads) do
   if Assigned(FTecentThreads[nIdx]) then
    Inc(nNum);
  //xxxxx

  for nIdx:=Low(FTecentThreads) to High(FTecentThreads) do
  begin
    if nNum > nIdx then Continue;
    if not Assigned(FTecentThreads[nIdx]) then
    begin
      FTecentThreads[nIdx] := TWXSendTecentTMsg.Create(Self);
      Inc(nNum);
    end;
  end;
end;

procedure TWXMessageMgr.StopSendTecent;
var nIdx: Integer;
begin
  for nIdx:=Low(FTecentThreads) to High(FTecentThreads) do
   if Assigned(FTecentThreads[nIdx]) then
    FTecentThreads[nIdx].Terminate;
  //�����˳����

  for nIdx:=Low(FTecentThreads) to High(FTecentThreads) do
  if Assigned(FTecentThreads[nIdx]) then
  begin
    FTecentThreads[nIdx].StopMe;
    FTecentThreads[nIdx] := nil;
  end;
end;

function TWXMessageMgr.MakeRemarkValue(nStrSrc: string;nDS:TDataSet=nil):string;
var nStrDst: string;
begin
  nStrDst := nStrSrc;

  if Assigned(nDS) then
  with nDS do
  begin
    //����
    nStrDst := StringReplace(nStrDst, 'jz', FieldByName('L_Value').AsString,
                             [rfReplaceAll, rfIgnoreCase]);
    //�۸�
    nStrDst := StringReplace(nStrDst, 'pr', FieldByName('L_Price').AsString,
                             [rfReplaceAll, rfIgnoreCase]);
  end;

  Result := nStrDst;
end;

//Date: 2014/12/20
//Parm: ҵ������;ҵ�����ݣ�������Ϣ
//Desc: ����ģ����Ϣ
function TWXMessageMgr.WXSendTemplateMsg(const nTempType,nData: string;
    var nHint: string): Boolean;
var nDB: PDBWorker;
  nSO: ISuperObject;
  nSS: TStrings; nDS: TDataSet;
  nIndex: Integer;nIni: TIniFile;
  nStrFieldName, nStrValue, nStrColor, nRetstr, nMsgID: string;
  nTempID,nTempFields,nBills, nStrSection, nCompany, nStr,nComment: string;
begin
  Result := False;

  if UpperCase(nTempType) = 'RESEND' then
  begin
    //
    WXTPMessageReSend(nData, nHint);
    Exit;
  end;

  try
    nStr := 'Select * from $WXTMPTABLE where W_Type=''$WTYPE''';
    nStr := MacroValue(nStr, [MI('$WTYPE', nTempType),
                              MI('$WXTMPTABLE',sTable_WeixinTemp)]);
    //xxxxxx

    with gDBConnManager.SQLQuery(nStr, nDB) do
    begin
      if RecordCount < 1 then
      begin
        nHint := '�޴�ģ������[ %s ] !!!';
        nHint := Format(nHint, [nTempType]);
        Exit;
      end;

      nTempID := FieldByName('W_TID').AsString;
      nTempFields := FieldByName('W_TFields').AsString;
    end;

    nSS := TStringList.Create;
    nIni := TIniFile.Create(gWeiXinPath + 'DBConn.ini');
    try
      nSS.Text := nData;
      nBills := nSS.Values['bill'];
      nCompany := nSS.Values['company'];
      if RightStr(nBills,1) = ',' then
        nBills := Copy(nBills , 1, Length(nBills)-1);
      nBills := AdjustListStrFormat(nBills , '''' , True , ',' , False);

      nStr := 'Select sb.*,sw.* from $BILL sb inner join ' +
              '$CUSTOMER sc on sb.L_CusID=sc.C_Param inner join $WXMATCH sw ' +
              'on sc.C_WeiXin= sw.M_ID where L_ID in ($LIST)';
      nStr := MacroValue(nStr, [MI('$LIST', nBills),
                                MI('$BILL', sTable_Bill),
                                MI('$WXMATCH', sTable_WeixinMatch),
                                MI('$CUSTOMER', sTable_Customer)]);
      //xxxxxx

      nDS := gDBConnManager.WorkerQuery(nDB, nStr);
      if (not Assigned(nDS)) or (nDS.RecordCount<1) then
      begin
        nHint := Format('�������[%s]��Ϣ',[nData]); Exit;
      end;

      if nDS.FieldByName('M_isValid').AsString <> sFlag_Yes then
      begin
        nHint:=Format('�ͻ�[%s]δ����΢��ҵ��',
                      [nDS.FieldByName('L_CusID').AsString]);
        Exit;
      end;

      nDS.First;
      if not SplitStr(Trim(nTempFields), nSS, 0, '$') then Exit;
      while not nDS.Eof do
      begin
        nStr := '';

        for nIndex := 0 to nSS.Count - 1 do
        begin
          nStrSection := nTempType;
          nStrFieldName := nIni.ReadString(nStrSection, nSS[nIndex], '');
          nStrColor := nIni.ReadString(nStrSection, 'color', '');

          if nStrFieldName = 'company' then
          begin
            nStrValue := nCompany;
          end
          else if (nSS[nIndex] = 'remark') or (nSS[nIndex] = 'first') then
          begin
            nStrValue := MakeRemarkValue(nStrFieldName, nDS);
          end else
          begin
            if Assigned(nDS.FindField(nStrFieldName)) then
              nStrValue := nDS.FieldByName(nStrFieldName).AsString
            else
              nStrValue := '';
          end;

          nStr := nStr + '"$SECTION":{"value":"$VALUE","color":"$COLOR"},';
          nStr := MacroValue(nStr, [MI('$SECTION', nSS[nIndex]),
                                    MI('$VALUE', nStrValue),
                                    MI('$COLOR', nStrColor)]);
          //xxxxxx
        end;

        if Length(nStr) > 0 then
          nStr := Copy(nStr, 1, Length(nStr) - 1);

        nStr := Format('{"touser":"%s","template_id":"%s","url":"",' +
                       '"topcolor":"","data":{%s}}',
                       [nDS.FieldByName('M_WXID').AsString,nTempID,nStr]);
        //xxxxxx

        nRetstr := ''; nMsgID := '';
        nRetstr := WXSendTPMessage(nStr, nMsgID);
        if nRetstr = '' then Exit;
        nSO := SO(nRetstr);
        nComment := GetErrMsgByCode(nSO['errcode'].AsInteger);

        nStrColor := 'Insert into $WXLOG(L_UserID, L_Data, L_MsgID, L_Result, '+
                'L_Count, L_Status, L_Date, L_Comment) values(''$USERID'' , '+
                '''$DATA'', ''$MSGID'', ''$RESULT'', $COUNT, ''$STATUS'',' +
                'GetDate(), ''$COMMENT'')';
        nStr := MacroValue(nStrColor, [MI('$WXLOG', sTable_WeixinLog),

                                       MI('$DATA', EncodeBase64(nStr)),
                                       MI('$USERID', nDS.FieldByName('M_WXID').AsString),

                                       MI('$MSGID', nMsgID),
                                       MI('$COMMENT', nComment),
                                       MI('$RESULT', EncodeBase64(nRetstr)),

                                       MI('$STATUS', 'Y'),
                                       MI('$COUNT', '1')]);
        //xxxxxx
        gDBConnManager.WorkerExec(nDB, nStr);

        nDS.Next; //
      end;

      Result := True;
    finally
      FreeAndNil(nSS);
      FreeAndNil(nIni);
    end;
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;
//Date: 2014/12/20
//Parm: ģ����ϢID��ģ�����ͣ�ģ���ʽ()����ע
//Desc: ����ģ����Ϣ��ʽ
function TWXMessageMgr.WXSaveTemplate(nTPMID, nTPMType,nTPMTemplate:string;
  nTPMComment:string=''):string;
var nSQLStr, nTempF: string;
    nDB : PDBWorker;
  function GetTempF(nStrSrc: string):string;
  var nPos: Integer;
      nStrTmp, nRetStr: string;
  begin
     nRetStr := '';
     nStrTmp := nStrSrc;

     while Length(nStrTmp)>0 do
     begin
        nPos := Pos(gWXStartTemp, nStrTmp);
        if nPos>0 then
        begin
            System.Delete(nStrTmp, 1, nPos + Length(gWXStartTemp)-1);
            nPos := Pos(gWXStopTemp, nStrTmp);
            if nPos>0 then
            begin
               nRetStr := nRetStr +Copy(nStrTmp, 1, nPos-1) + '$';
               System.Delete(nStrTmp, 1, nPos + Length(gWXStopTemp)-1);
               if Pos(gWXStartTemp, nRetStr)>0 then
               begin
                  nRetStr := '';
                  Break;
               end;
            end
            else
            begin
              nRetStr := '';
              Break;
            end;
        end
        else
          Break;
     end;

     Result := nRetStr;
  end;
begin
  Result := '';
  if (nTPMID='') and (nTPMType='') and (nTPMTemplate='') then
  begin
    Result := 'ģ������[%s]��ģ��ID[%s]��ģ����Ϣ[%s]����ͬʱΪ��';
    Result := Format(Result, [nTPMType, nTPMID, nTPMTemplate]);
    WriteLog('WXSaveTemplate:' + Result);
    Exit;
  end;

  nSQLStr := 'Select * from $WXTMPTABLE where W_Type=''$WTYPE''';
  nSQLStr := MacroValue(nSQLStr, [MI('$WTID', nTPMID),
                                  MI('$WTYPE', nTPMType),
                                  MI('$WXTMPTABLE', sTable_WeixinTemp)]);

  try
    with gDBConnManager.SQLQuery(nSQLStr, nDB) do
     if RecordCount>0 then
     begin
         Result := 'ģ������[%s]�Ѵ���';
         Result := Format(Result,[nTPMType]);
         WriteLog('WXSaveTemplate:' + Result);
         Exit;
     end;

    if nTPMTemplate<>'' then
    begin
      nTempF := GetTempF(nTPMTemplate);
      if nTempF = '' then
      begin
         Result := 'ģ���ʽ����!!!';
         WriteLog('WXSaveTemplate:' + Result);
         Exit;
      end;
    end;

    nSQLStr := 'Insert into $WXTMPTABLE(W_TID, W_TFields, W_Type, W_TComment)' +
               'Values(''$WXTID'', ''$WTFIELDS'', ''$WTYPE'', ''$COMMENT'')';
    nSQLStr := MacroValue(nSQLStr, [MI('$WXTMPTABLE', sTable_WeixinTemp),
                                    MI('$COMMENT', nTPMComment),

                                    MI('$WTYPE', nTPMType),
                                    MI('$WXTID', nTPMID),
                                    MI('$WTFIELDS', nTempF)]);
    //xxxxxx
    gDBConnManager.WorkerExec(nDB, nSQLStr);
  finally
    gDBConnManager.ReleaseConnection(nDB);
  end;
end;
//Date: 2014/12/20
//Parm: ģ����ϢID��ģ����Ϣ����
//Desc: ɾ��ģ����Ϣ��ʽ
function TWXMessageMgr.WXDeleteTemplate(nTPMID, nTPMType:string):string;
var nSQLStr: string;
begin
  Result := '';
  if (nTPMID='') and (nTPMType='') then Exit;

  nSQLStr := 'Delete from $WXTMPTABLE where W_Type=''$WTYPE'' ' +
             'or W_TID=''$WTID''';
  nSQLStr := MacroValue(nSQLStr, [MI('$WXTMPTABLE', sTable_WeixinTemp),
                                  MI('$WTYPE', nTPMType),
                                  MI('$WXTID', nTPMID)]);
  //xxxxxx

  gDBConnManager.ExecSQL(nSQLStr);
end;

//Desc: ����ϵͳ����
function TWXMessageMgr.RunSystemObject: Boolean;
var nStr: string;
    nIni: TIniFile;
    nWorker:  PDBWorker;
begin
  nIni := TIniFile.Create(gWeiXinPath + sConfig);
  with gWXSysParam do
  try
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);
    FFactName := nIni.ReadString('Config', 'Company', '����־�ſƼ����޹�˾');
  finally
    nIni.Free;
  end;  

  //----------------------------------------------------------------------------
  try
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      begin
        gChannelChoolser.AddChannelURL(Fields[0].AsString);
        Next;
      end;

      {$IFNDEF DEBUG}
      gChannelChoolser.StartRefresh;
      {$ENDIF}//update channel
    end;

    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, 'WXCompileWithMIT']);

    with gDBConnManager.WorkerQuery(nWorker, nStr) do
    if RecordCount > 0 then gWXSysParam.FIsWithMIT := Fields[0].AsString
    else gWXSysParam.FIsWithMIT := sFlag_No;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;

  Result := True;
end;

//Desc: �ͷ�ϵͳ����
procedure TWXMessageMgr.FreeSystemObject;
begin
  //
  FinalSystemDBMgr;
  //���ݿ����ӳ�
end;

//Desc: ������ݿ����
procedure FillAllDBParam;
var nIdx: Integer;
    nDB : TDBParam;
    nDBItems: TDBParams;
begin
  LoadDBParamFromFile(gWeiXinPath + sDBConfigFile, nDBItems);
  if Length(nDBItems) < 0 then Exit;
  for nIdx:=Low(nDBItems) to High(nDBItems) do
  begin
    nDB := nDBItems[nIdx];

    gDBConnManager.AddParam(nDB);
    if nDB.FEnable then
    begin
      gDBConnManager.DefaultConnection := nDB.FID;
      gDBConnManager.MaxConn := nDB.FNumWorker;
    end;
  end;
  //�����ļ�����

  {$IFDEF JSNF}
  LoadDBParamFromDB(nDBItems);
  if Length(nDBItems) < 0 then Exit;
  for nIdx:=Low(nDBItems) to High(nDBItems) do
  begin
    nDB := nDBItems[nIdx];

    if nDB.FEnable then gDBConnManager.AddParam(nDB);
  end;
  {$ENDIF}
end;

procedure UpdateDBParam(nNewParam: TDBParam);
begin
  with gDBConnManager do
  begin
    DelParam(nNewParam.FID);
    //ɾ��ԭ�����Ӳ���

    AddParam(nNewParam);
    //�����µ����Ӳ���
  end;  
end;  

//------------------------------------------------------------------------------
//Date: 2015/4/28
//Parm: 
//Desc: ��ʼ�����ݿ����
procedure InitSystemDBMgr;
begin
  CoInitialize(nil);
  if not Assigned(gDBConnManager) then
    gDBConnManager := TDBConnManager.Create;

  FillAllDBParam;
end;

procedure FinalSystemDBMgr;
begin
  if Assigned(gDBConnManager) then gDBConnManager.Disconnection;

  CoUninitialize;
end;

initialization
  InitSystemEnvironment;
  gWXMessgeMgr := TWXMessageMgr.Create;

  gBusinessWorkerManager.RegisteWorker(TWXHareworeCommand);
  gBusinessWorkerManager.RegisteWorker(TWXBusinessCommand);
  //ע�ắ��
finalization
  gWXMessgeMgr.FreeSystemObject;
  gWXMessgeMgr.Free;
end.
