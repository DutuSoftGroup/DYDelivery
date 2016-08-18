unit UFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IdContext, ExtCtrls, IdBaseComponent, IdComponent, UFormBase,
  IdCustomTCPServer, IdTCPServer, ComCtrls, StdCtrls, UTrayIcon, SyncObjs,
  Menus, IdGlobal, UMgrRemoteWXMsg;

type
  TfFormMain = class(TForm)
    GroupBox1: TGroupBox;
    CheckSrv: TCheckBox;
    EditPort: TLabeledEdit;
    CheckAuto: TCheckBox;
    CheckLoged: TCheckBox;
    BtnConn: TButton;
    MemoLog: TMemo;
    StatusBar1: TStatusBar;
    IdTCPServer1: TIdTCPServer;
    Timer1: TTimer;
    mainMemu: TMainMenu;
    N1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    N7: TMenuItem;
    N2: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    NowTimer: TTimer;
    BtnClear: TButton;
    N3: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckSrvClick(Sender: TObject);
    procedure CheckLogedClick(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure BtnConnClick(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N10Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure NowTimerTimer(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
    FTrayIcon: TTrayIcon;
    {*״̬��ͼ��*}
    FSyncLock: TCriticalSection;
    //ͬ����

    FAppID, FAppSecret, FAppToken: string;
    //΢��Ӧ��ID��Ӧ����Կ(���ܱ���)
    
    procedure ShowLog(const nStr: string);
    //��ʾ��־
    procedure DoExecute(const nContext: TIdContext);
    //ִ�ж���
    procedure SendTPMsgExecute(var nBase: TWXDataBase; var nBuf: TIdBytes;
      nCtx: TIdContext);
  public
    { Public declarations }
  end;

var
  fFormMain: TfFormMain;

implementation

{$R *.dfm}
uses
  IniFiles, Registry, ULibFun, UDataModule, UFormConn, USysLoger, UWeiXinConst,
  UMgrWeixin, UFormSetAppData, UFormTemplate, UAESStandard;

var
  gPath: string;               //����·��

resourcestring
  sHint               = '��ʾ';
  sConfig             = 'Config.Ini';
  sForm               = 'FormInfo.Ini';
  sDB                 = 'DBConn.Ini';
  sAutoStartKey       = 'WeiXinServer';

procedure WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TfFormMain, '΢�ŷ�������Ԫ', nEvent);
end;

//Desc: ����nConnStr�Ƿ���Ч
function ConnCallBack(const nConnStr: string): Boolean;
begin
  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := nConnStr;
  FDM.ADOConn.Open;
  Result := FDM.ADOConn.Connected;
end;

//Desc: ���ݿ�����
procedure TfFormMain.BtnConnClick(Sender: TObject);
begin
  if ShowConnectDBSetupForm(ConnCallBack) then
  begin
    FDM.ADOConn.Close;
    FDM.ADOConn.ConnectionString := BuildConnectDBStr;
    //���ݿ�����
  end;
end;

procedure TfFormMain.ShowLog(const nStr: string);
var nIdx: Integer;
begin
  MemoLog.Lines.BeginUpdate;
  try
    MemoLog.Lines.Insert(0, nStr);
    if MemoLog.Lines.Count > 100 then
     for nIdx:=MemoLog.Lines.Count - 1 downto 50 do
      MemoLog.Lines.Delete(nIdx);
  finally
    MemoLog.Lines.EndUpdate;
  end;
end;

procedure TfFormMain.FormCreate(Sender: TObject);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  gPath := ExtractFilePath(Application.ExeName);
  InitGlobalVariant(gPath, gPath+sConfig, gPath+sForm, gPath+sDB);
  
  gSysLoger := TSysLoger.Create(gPath + sLogDir, sLogSyncLock);
  gSysLoger.LogEvent := ShowLog;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.Hint := Caption;
  FTrayIcon.Visible := True;

  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    EditPort.Text := nIni.ReadString('Config', 'Port', '8000');
    Timer1.Enabled := nIni.ReadBool('Config', 'Enabled', False);
    if not nIni.ReadBool('Config', 'MenuVisible', False) then Self.Menu := nil;

    FAppID := nIni.ReadString('Config', 'AppID', '');
    FAppToken:= nIni.ReadString('Config', 'AppToken', '');
    FAppSecret := nIni.ReadString('Config', 'AppSecret', ''); 
    //xxxx

    if FAppID <> '' then
      gWXMessgeMgr.appid := Trim(DecryptString(FAppID, 'zx@zn1638'));
    if FAppToken <> '' then
      gWXMessgeMgr.apptoken := Trim(DecryptString(FAppToken, 'zx@zn1638'));
    if FAppSecret <> '' then
      gWXMessgeMgr.appsecret := Trim(DecryptString(FAppSecret, 'zx@zn1638'));

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    CheckAuto.Checked := nReg.ValueExists(sAutoStartKey);
  finally
    nIni.Free;
    nReg.Free;
  end;

  FSyncLock := TCriticalSection.Create;
  //new item

  FDM.ADOConn.Close;
  FDM.ADOConn.ConnectionString := BuildConnectDBStr;
  //���ݿ�����
end;

procedure TfFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var nIni: TIniFile;
    nReg: TRegistry;
begin
  nIni := nil;
  nReg := nil;
  try
    nIni := TIniFile.Create(gPath + 'Config.ini');
    nIni.WriteBool('Config', 'Enabled', CheckSrv.Checked);

    if gWXMessgeMgr.appid <> '' then
      FAppID := EncryptString(gWXMessgeMgr.appid, 'zx@zn1638');
    if gWXMessgeMgr.apptoken<>'' then
      FAppToken := EncryptString(gWXMessgeMgr.apptoken, 'zx@zn1638');
    if gWXMessgeMgr.appsecret<>'' then
      FAppSecret := EncryptString(gWXMessgeMgr.appsecret, 'zx@zn1638');

    nIni.WriteString('Config', 'AppID', FAppID);
    nIni.WriteString('Config', 'AppToken', FAppToken);
    nIni.WriteString('Config', 'AppSecret', FAppSecret);

    nReg := TRegistry.Create;
    nReg.RootKey := HKEY_CURRENT_USER;

    nReg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True);
    if CheckAuto.Checked then
      nReg.WriteString(sAutoStartKey, Application.ExeName)
    else if nReg.ValueExists(sAutoStartKey) then
      nReg.DeleteValue(sAutoStartKey);
    //xxxxx
  finally
    nIni.Free;
    nReg.Free;
  end;

  FSyncLock.Free;
  //lock
end;

procedure TfFormMain.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  CheckSrv.Checked := True;
end;

procedure TfFormMain.CheckSrvClick(Sender: TObject);
begin
  IdTCPServer1.DefaultPort := StrToIntDef(EditPort.Text, 8000);
  //΢�ż������ӣ�Ŀǰ��֧��80�˿�
  if CheckSrv.Checked then
  begin
    if not gWXMessgeMgr.WXStartService(80, StrToIntDef(EditPort.Text, 8000))then
        CheckSrv.Checked := False;
  end
  else
     gWXMessgeMgr.WXStopService;

  IdTCPServer1.Active := CheckSrv.Checked;
  N5.Enabled := CheckSrv.Checked;
  N4.Enabled := not CheckSrv.Checked;
  
  BtnConn.Enabled := not CheckSrv.Checked;
  EditPort.Enabled := not CheckSrv.Checked;
end;

procedure TfFormMain.CheckLogedClick(Sender: TObject);
begin
  gSysLoger.LogSync := CheckLoged.Checked;
end;

procedure TfFormMain.IdTCPServer1Execute(AContext: TIdContext);
begin
  try
    DoExecute(AContext);
  except
    on E:Exception do
    begin
      AContext.Connection.IOHandler.InputBuffer.Clear;
      WriteLog(E.Message);
    end;
  end;
end;

procedure TfFormMain.DoExecute(const nContext: TIdContext);
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

procedure TfFormMain.SendTPMsgExecute(var nBase: TWXDataBase; var nBuf: TIdBytes;
  nCtx: TIdContext);
var nStr: WideString;
begin
  nCtx.Connection.Socket.ReadBytes(nBuf, nBase.FDataLen, False);
  nStr := Trim(BytesToString(nBuf));

  gWXMessgeMgr.WXAddTemMsg(nStr);
end;
//Date: 2015/2/27
//Parm:
//Desc: ��������
procedure TfFormMain.N4Click(Sender: TObject);
begin
  CheckSrv.Checked := True;
end;
//Date: 2015/2/27
//Parm:
//Desc: ��ͣ����
procedure TfFormMain.N5Click(Sender: TObject);
begin
  CheckSrv.Checked := False;
end;
//Date: 2015/2/27
//Parm:
//Desc: �˳�
procedure TfFormMain.N7Click(Sender: TObject);
begin
  Close;
end;
//Date: 2015/2/27
//Parm:
//Desc: �����Զ���˵�
procedure TfFormMain.N8Click(Sender: TObject);
begin
  if gWXMessgeMgr.WXGetAccessToken then
  gWXMessgeMgr.WXCreateMenus('xml', gPath + 'template\menus.xml');
end;
//Date: 2015/2/27
//Parm:
//Desc: ɾ���Զ���˵�
procedure TfFormMain.N9Click(Sender: TObject);
begin
  gWXMessgeMgr.WXDeleteMenu;
end;
//Date: 2015/2/27
//Parm:
//Desc: ����΢��AppID��AppSecret
procedure TfFormMain.N10Click(Sender: TObject);
begin
  //����΢�Ų���
  ShowSetAppForm;
end;
//Date: 2015/2/27
//Parm:
//Desc: ������Ϣģ���ʽ
procedure TfFormMain.N13Click(Sender: TObject);
begin
  ShowTemplateForm;
end;
//Date: 2015/2/27
//Parm:
//Desc: ɾ��ģ����Ϣ��ʽ
procedure TfFormMain.N14Click(Sender: TObject);
begin
  ShowTemplateForm(False);
end;

procedure TfFormMain.NowTimerTimer(Sender: TObject);
var nNowTime: string;
begin
  nNowTime := FormatDateTime('YYYY/mm/dd HH:mm:ss', Now);
  StatusBar1.Panels[1].Text := nNowTime;
end;

procedure TfFormMain.BtnClearClick(Sender: TObject);
begin
  MemoLog.Lines.Clear;
end;

procedure TfFormMain.N3Click(Sender: TObject);
var
  nP :TFormCommandParam;
begin
  if CheckSrv.Checked then
    CreateBaseFormItem(cFI_FormDB, '', @nP);
end;

end.
