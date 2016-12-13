{*******************************************************************************
  ����: 289525016@163.com 2016-9-27
  ����: ΢���˺Ű�
*******************************************************************************}
unit UFormWeixinBind;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, dxLayoutcxEditAdapters,
  cxMaskEdit, cxDropDownEdit;

type
  PCustomerInfo = ^stCustomerInfo;
  stCustomerInfo = record
    FPhone:string;
    FAppid:string;
    FBindcustomerid:string;
    FNamepinyin:string;
    FEmail:string;
    FOpenid:string;
    FBinddate:string;
  end;
  //΢��ƽ̨�ͻ���Ϣ

  TfFormWeixinBind = class(TfFormNormal)
    EditMobileNo: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditMobileNoKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    procedure InitFormData;
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UMgrControl, USysBusiness, USmallFunc, USysConst, USysDB,
  UDataModule,UAdjustForm,UFormCtrl,UBusinessPacker,USysLoger;

class function TfFormWeixinBind.FormID: integer;
begin
  Result := cFI_FormWeixinBind;
end;

class function TfFormWeixinBind.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;
  
  with TfFormWeixinBind.Create(Application) do
  begin
    Caption := '�˺Ű�-����';

    InitFormData;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

//Desc: ��ʼ��
procedure TfFormWeixinBind.BtnOKClick(Sender: TObject);
var nMobileNo:string;
  nSQL: string;
  nXmlStr,nData:string;
  nRec:stCustomerInfo;
  nListA:TStringList;
begin
  nMobileNo := Trim(EditMobileNo.Text);
  if nMobileNo = '' then
  begin
    ActiveControl := EditMobileNo;
    EditMobileNo.SelectAll;

    ShowMsg('��������ȷ���ֻ�����', sHint);
    Exit;
  end;

  //��ѯ�Ƿ��Ѿ��ɹ���
  nSQL := 'select 1 from %s where wcb_Phone=''%s''';
  nSQL := Format(nSQL,[sTable_WeixinBind,nMobileNo]);
  if FDM.QuerySQL(nSQL).RecordCount>0 then
  begin
    ShowMsg('�ֻ�����[ '+nMobileNo+' ]�Ѱ󶨳ɹ��������ظ��󶨣�', sHint);
    ModalResult := mrOK;
    Exit;
  end;

  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<Phone>%s</Phone>'
            +'</head>'
            +'</DATA>';
   nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nMobileNo]);
   nXmlStr := PackerEncodeStr(nXmlStr);

   //��ȡ�ͻ�ע����Ϣ
   nData := getCustomerInfo(nXmlStr);
   if nData='' then
   begin
     ShowMsg('δ��ѯ���ֻ�����[ '+nMobileNo+' ]��ע����Ϣ����ȷ���ֻ������Ƿ���ȷ��', sHint);
     Exit;
   end;
  
  //�����ͻ�ע����Ϣ
  nData := PackerDecodeStr(nData);
  nListA := TStringList.Create;
  try
    nListA.Text := nData;
    nRec.FAppid := nListA.Values['Appid'];
    nRec.FBindcustomerid := nListA.Values['Bindcustomerid'];
    nRec.FNamepinyin := nListA.Values['Namepinyin'];
    nRec.FEmail := nListA.Values['Email'];
    nRec.FOpenid := nListA.Values['Openid'];
    nRec.FBinddate := nListA.Values['Binddate'];
    nRec.FPhone := nMobileNo;
  finally
    nListA.Free;
  end;

  //���Ͱ�����
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<ToUser>%s</ToUser>'
            +'<IsBind>1</IsBind>'
            +'</head>'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nRec.FBindcustomerid]);
  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := get_Bindfunc(nXmlStr);
  gSysLoger.AddLog(TfFormWeixinBind,'BtnOKClick',nData);
  if nData='' then
  begin
    ShowMsg('�ֻ�����[ '+nMobileNo+' ]��΢���˺�ʧ�ܣ�', sHint);
    Exit;
  end;

  //�󶨳ɹ���д�����ݿ�
  nSQL := 'insert into %s (wcb_Phone,wcb_Appid,wcb_Bindcustomerid,wcb_Namepinyin,wcb_Email,wcb_Openid,wcb_Binddate)'
         +' values(''%s'',''%s'',''%s'',''%s'',''%s'',''%s'',''%s'')';
  nSQL := Format(nSQL,[sTable_WeixinBind,nMobileNo,nRec.FAppid,nRec.FBindcustomerid,nRec.FNamepinyin,nRec.FEmail,nRec.FOpenid,nRec.FBinddate]);
  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nSQL);
    FDM.ADOConn.CommitTrans;
    ModalResult := mrOK;
    ShowMsg('�����ѱ���', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('���ݱ���ʧ��', 'δ֪ԭ��');
    Exit;
   end;
  //done
end;

procedure TfFormWeixinBind.InitFormData;
var nStr: string;
begin
//
end;

procedure TfFormWeixinBind.EditMobileNoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key=Char(VK_RETURN) then
  begin
    Key := #0;
    BtnOK.Click;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormWeixinBind, TfFormWeixinBind.FormID);
end.
