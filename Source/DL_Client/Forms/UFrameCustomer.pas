{*******************************************************************************
  ����: dmzn@163.com 2009-6-11
  ����: �ͻ�����
*******************************************************************************}
unit UFrameCustomer;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxContainer, Menus, dxLayoutControl,
  cxTextEdit, cxMaskEdit, cxButtonEdit, ADODB, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin;

type
  TfFrameCustomer = class(TfFrameNormal)
    EditID: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure cxView1DblClick(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure btnWebMallClick(Sender: TObject);
  private
    { Private declarations }
    function AddMallUser(const nPhone,nCus_id:string):Boolean;
    function DelMallUser(const nPhone,nCus_id:string):boolean;
  protected
    function InitFormDataSQL(const nWhere: string): string; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormWait, USysBusiness,
  USysConst, USysDB,UBusinessPacker,USysLoger;

class function TfFrameCustomer.FrameID: integer;
begin
  Result := cFI_FrameCustomer;
end;

//Desc: ���ݲ�ѯSQL
function TfFrameCustomer.InitFormDataSQL(const nWhere: string): string;
begin
  btnWebMall.Visible := True;
  Result := 'Select cus.*,S_Name From $Cus cus' +
            ' Left Join $Sale On S_ID=cus.C_SaleMan';
  //xxxxx

  if nWhere = '' then
       Result := Result + ' Where C_XuNi<>''$Yes'''
  else Result := Result + ' Where (' + nWhere + ')';

  Result := MacroValue(Result, [MI('$Cus', sTable_Customer),
            MI('$Sale', sTable_Salesman), MI('$Yes', sFlag_Yes)]);
  //xxxxx
end;

//Desc: �ر�
procedure TfFrameCustomer.BtnExitClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if not IsBusy then
  begin
    nParam.FCommand := cCmd_FormClose;
    CreateBaseFormItem(cFI_FormCustomer, '', @nParam); Close;
  end;
end;

//------------------------------------------------------------------------------
//Desc: ���
procedure TfFrameCustomer.BtnAddClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  nParam.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: �޸�
procedure TfFrameCustomer.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ�༭�ļ�¼', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: ɾ��
procedure TfFrameCustomer.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
  nCusId,nMobileNo:string;
begin
  nMobileNo := '';
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('C_Name').AsString;
  if not QueryDlg('ȷ��Ҫɾ������Ϊ[ ' + nStr + ' ]�Ŀͻ���', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('C_ID').AsString;
    nCusId := nStr;
    nSQL := 'Delete From %s Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Customer, nStr]);
    FDM.ExecuteSQL(nSQL);

    //��ѯ������Ϣ�е��ֻ����룬����ɾ���̳��˺�
    nSql := 'select I_Info from %s where I_Group=''%s'' and I_Item=''%s'' and I_ItemID=''%s''';
    nSql := Format(nSql,[sTable_ExtInfo,sFlag_CustomerItem,'�ֻ�',nCusId]);
    if FDM.QuerySQL(nSql).RecordCount>0 then
    begin
      nMobileNo := FDM.QueryTemp(nSQL).FieldByName('I_Info').AsString;
    end;

    nSQL := 'Delete From %s Where I_Group=''%s'' and I_ItemID=''%s''';
    nSQL := Format(nSQL, [sTable_ExtInfo, sFlag_CustomerItem, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where A_CID=''%s''';
    nSQL := Format(nSQL, [sTable_CusAccount, nStr]);
    FDM.ExecuteSQL(nSQL);

    nSQL := 'Delete From %s Where C_CusID=''%s''';
    nSQL := Format(nSQL, [sTable_CusCredit, nStr]);
    FDM.ExecuteSQL(nSQL);

    FDM.ADOConn.CommitTrans;
    if nMobileNo<>'' then
    begin
      DelMallUser(nMobileNo,nCusId);
    end;

    InitFormData(FWhere);
    ShowMsg('�ѳɹ�ɾ����¼', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('ɾ����¼ʧ��', 'δ֪����');
  end;
end;

//Desc: �鿴����
procedure TfFrameCustomer.cxView1DblClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nParam.FCommand := cCmd_ViewData;
    nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
    CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);
  end;
end;

//Desc: ִ�в�ѯ
procedure TfFrameCustomer.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditID then
  begin
    EditID.Text := Trim(EditID.Text);
    if EditID.Text = '' then Exit;

    FWhere := 'C_ID like ''%' + EditID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;

    FWhere := 'C_Name like ''%%%s%%'' Or C_PY like ''%%%s%%''';
    FWhere := Format(FWhere, [EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

//------------------------------------------------------------------------------

procedure TfFrameCustomer.PMenu1Popup(Sender: TObject);
begin
  {$IFDEF SyncRemote}
  N3.Visible := True;
  N4.Visible := True;
  {$ELSE}
  N3.Visible := False;
  N4.Visible := False;
  {$ENDIF}
end;


//Desc: ��ݲ˵�
procedure TfFrameCustomer.N2Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
    10: FWhere := Format('IsNull(C_XuNi, '''')=''%s''', [sFlag_Yes]);
    20: FWhere := '1=1';
  end;

  InitFormData(FWhere);
end;

procedure TfFrameCustomer.N4Click(Sender: TObject);
begin
  ShowWaitForm(ParentForm, '����ͬ��,���Ժ�');
  try
    if SyncRemoteCustomer then InitFormData(FWhere);
  finally
    CloseWaitForm;
  end;   
end;

//desc:��ͨ�����̳��˺�
procedure TfFrameCustomer.btnWebMallClick(Sender: TObject);
var nParam: TFormCommandParam;
  nCus_ID,nMobileNo,nCusName:string;
  nSql:string;
  nDs:TDataSet;
  nWebMallStatus:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫ��ͨ�ļ�¼', sHint); Exit;
  end;
  nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
  nCusName := SQLQuery.FieldByName('C_Name').AsString;
  
  //��ѯ������Ϣ�е��ֻ�����
  nSql := 'select I_Info from %s where I_Group=''%s'' and I_Item=''%s'' and I_ItemID=''%s''';
  nSql := Format(nSql,[sTable_ExtInfo,sFlag_CustomerItem,'�ֻ�',nCus_ID]);
  nDs := FDM.QuerySQL(nSql);
  if nDs.RecordCount<=0 then
  begin
    ShowMsg('�ÿͻ�δ�����ֻ����룬�������Ӹ�����Ϣ�����ԣ�','�ֻ�����δ����');
    Exit;
  end;
  nMobileNo := FDM.QueryTemp(nSQL).FieldByName('I_Info').AsString;
  {
  //�ݲ��ж��Ƿ��΢�ź�
  //�ж�¼����ֻ������Ƿ��ѳɹ���
  nSql := 'select isnull(wcb_WebMallStatus,''0'') as wcb_WebMallStatus  from %s where wcb_Phone=''%s''';
  nSql := Format(nSql,[sTable_WeixinBind,nMobileNo]);
  nDs := FDM.QuerySQL(nSql);
  if nDs.RecordCount<=0 then
  begin
    ShowMsg('�ͻ� [ '+nCusName+' ] ���õ��ֻ����� [ '+nMobileNo+' ] δ���а� �����Ƚ����˻��󶨣�','�ֻ�����δ��');
    Exit;
  end;
  nWebMallStatus := nDs.FieldByName('wcb_WebMallStatus').AsString;
  if nWebMallStatus='1' then
  begin
    ShowMsg('�ͻ� [ '+nCusName+' ] ���õ��ֻ����� [ '+nMobileNo+' ] �ѿ�ͨ�̳��˺ţ������ظ�������','�ѿ�ͨ');
    Exit;
  end;
  }
  if AddMallUser(nMobileNo,nCus_ID) then
  begin
    //����sys_WeixinCusBind���״̬
    nSql := 'update %s set wcb_WebMallStatus=''%s'' where wcb_Phone=''%s''';
    nSql := Format(nSql,[sTable_WeixinBind,'1',nMobileNo]);

    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nSQL);
      FDM.ADOConn.CommitTrans;
      ShowMsg('�ͻ� [ '+nCusName+' ] ��ͨ�̳��û��ɹ���',sHint);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('��ͨ�̳��û�ʧ��', 'δ֪����');
    end;
  end;
end;

function TfFrameCustomer.AddMallUser(const nPhone,
  nCus_id: string): Boolean;
var
  nXmlStr,nPass:string;
  nData:string;
begin
  Result := False;
  //Ĭ������123456
  nPass := '123456';

  //���Ͱ����󿪻�����
  nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
            +'<DATA>'
            +'<head>'
            +'<Factory>%s</Factory>'
            +'<phone>%s</phone>'
            +'<password>%s</password>'
            +'  <type>add</type>'
            +'</head>'
            +'<Items>'
            +'	<Item>'
            +'	  <clientID>null</clientID>'
            +'	  <cash>0</cash>'
            +'	  <clientnumber>%s</clientnumber>'
            +'	</Item>'
            +'</Items>'
            +' <remark/>'
            +'</DATA>';
  nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nPhone,nPass,nCus_id]);
  nXmlStr := PackerEncodeStr(nXmlStr);
  nData := edit_shopclients(nXmlStr);
  gSysLoger.AddLog(TfFrameCustomer,'AddMallUser',nData);
  if nData='' then
  begin
    ShowMsg('�ֻ�����[ '+nPhone+' ]ע���̳��û�ʧ�ܣ�', sError);
    Exit;
  end;
  Result := True;
end;

function TfFrameCustomer.DelMallUser(const nPhone,
  nCus_id: string): boolean;
var
  nSql,nXmlStr,nData:string;
  nDs:TDataSet;
begin
  Result := True;
  //�ж��Ƿ�ͨ���̳��˺�
  nSql := 'select 1 from %s where wcb_WebMallStatus=''1'' and wcb_Phone=''%s''';
  nSql := Format(nSql,[sTable_WeixinBind,nPhone]);
  nDs := FDM.QuerySQL(nSql);
  //�ѿ�ͨ�̳��˺�
  if nDs.RecordCount>0 then
  begin
    //����web����ɾ���̳��˺�
    nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
              +'<DATA>'
              +'<head>'
              +'<Factory>%s</Factory>'
              +'<phone>%s</phone>'
              +'<password></password>'
              +'  <type>del</type>'
              +'</head>'
              +'<Items>'
              +'	<Item>'
              +'	  <clientID>null</clientID>'
              +'	  <cash>0</cash>'
              +'	  <clientnumber>%s</clientnumber>'
              +'	</Item>'
              +'</Items>'
              +' <remark/>'
              +'</DATA>';

    nXmlStr := Format(nXmlStr,[gSysParam.FFactory,nPhone,nCus_id]);
    nXmlStr := PackerEncodeStr(nXmlStr);

    nData := edit_shopclients(nXmlStr);
    gSysLoger.AddLog(TfFrameCustomer,'DelMallUser',nData);
    if nData='' then
    begin
      ShowMsg('�ֻ�����[ '+nPhone+' ]ɾ���̳��û�ʧ�ܣ�', sError);
      Result := False;
      Exit;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameCustomer, TfFrameCustomer.FrameID);
end.
