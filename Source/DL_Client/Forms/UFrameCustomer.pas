{*******************************************************************************
  作者: dmzn@163.com 2009-6-11
  描述: 客户管理
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
    {*查询SQL*}
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

//Desc: 数据查询SQL
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

//Desc: 关闭
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
//Desc: 添加
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

//Desc: 修改
procedure TfFrameCustomer.BtnEditClick(Sender: TObject);
var nParam: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要编辑的记录', sHint); Exit;
  end;

  nParam.FCommand := cCmd_EditData;
  nParam.FParamA := SQLQuery.FieldByName('C_ID').AsString;
  CreateBaseFormItem(cFI_FormCustomer, PopedomItem, @nParam);

  if (nParam.FCommand = cCmd_ModalResult) and (nParam.FParamA = mrOK) then
  begin
    InitFormData(FWhere);
  end;
end;

//Desc: 删除
procedure TfFrameCustomer.BtnDelClick(Sender: TObject);
var nStr,nSQL: string;
  nCusId,nMobileNo:string;
begin
  nMobileNo := '';
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要删除的记录', sHint); Exit;
  end;

  nStr := SQLQuery.FieldByName('C_Name').AsString;
  if not QueryDlg('确定要删除名称为[ ' + nStr + ' ]的客户吗', sAsk) then Exit;

  FDM.ADOConn.BeginTrans;
  try
    nStr := SQLQuery.FieldByName('C_ID').AsString;
    nCusId := nStr;
    nSQL := 'Delete From %s Where C_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Customer, nStr]);
    FDM.ExecuteSQL(nSQL);

    //查询附加信息中的手机号码，用于删除商城账号
    nSql := 'select I_Info from %s where I_Group=''%s'' and I_Item=''%s'' and I_ItemID=''%s''';
    nSql := Format(nSql,[sTable_ExtInfo,sFlag_CustomerItem,'手机',nCusId]);
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
    ShowMsg('已成功删除记录', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('删除记录失败', '未知错误');
  end;
end;

//Desc: 查看内容
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

//Desc: 执行查询
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


//Desc: 快捷菜单
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
  ShowWaitForm(ParentForm, '正在同步,请稍后');
  try
    if SyncRemoteCustomer then InitFormData(FWhere);
  finally
    CloseWaitForm;
  end;   
end;

//desc:开通网上商城账号
procedure TfFrameCustomer.btnWebMallClick(Sender: TObject);
var nParam: TFormCommandParam;
  nCus_ID,nMobileNo,nCusName:string;
  nSql:string;
  nDs:TDataSet;
  nWebMallStatus:string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('请选择要开通的记录', sHint); Exit;
  end;
  nCus_ID := SQLQuery.FieldByName('C_ID').AsString;
  nCusName := SQLQuery.FieldByName('C_Name').AsString;
  
  //查询附加信息中的手机号码
  nSql := 'select I_Info from %s where I_Group=''%s'' and I_Item=''%s'' and I_ItemID=''%s''';
  nSql := Format(nSql,[sTable_ExtInfo,sFlag_CustomerItem,'手机',nCus_ID]);
  nDs := FDM.QuerySQL(nSql);
  if nDs.RecordCount<=0 then
  begin
    ShowMsg('该客户未设置手机号码，请在增加附加信息后再试！','手机号码未设置');
    Exit;
  end;
  nMobileNo := FDM.QueryTemp(nSQL).FieldByName('I_Info').AsString;
  {
  //暂不判断是否绑定微信号
  //判断录入的手机号码是否已成功绑定
  nSql := 'select isnull(wcb_WebMallStatus,''0'') as wcb_WebMallStatus  from %s where wcb_Phone=''%s''';
  nSql := Format(nSql,[sTable_WeixinBind,nMobileNo]);
  nDs := FDM.QuerySQL(nSql);
  if nDs.RecordCount<=0 then
  begin
    ShowMsg('客户 [ '+nCusName+' ] 设置的手机号码 [ '+nMobileNo+' ] 未进行绑定 ，请先进行账户绑定！','手机号码未绑定');
    Exit;
  end;
  nWebMallStatus := nDs.FieldByName('wcb_WebMallStatus').AsString;
  if nWebMallStatus='1' then
  begin
    ShowMsg('客户 [ '+nCusName+' ] 设置的手机号码 [ '+nMobileNo+' ] 已开通商城账号，无需重复操作！','已开通');
    Exit;
  end;
  }
  if AddMallUser(nMobileNo,nCus_ID) then
  begin
    //更新sys_WeixinCusBind表的状态
    nSql := 'update %s set wcb_WebMallStatus=''%s'' where wcb_Phone=''%s''';
    nSql := Format(nSql,[sTable_WeixinBind,'1',nMobileNo]);

    FDM.ADOConn.BeginTrans;
    try
      FDM.ExecuteSQL(nSQL);
      FDM.ADOConn.CommitTrans;
      ShowMsg('客户 [ '+nCusName+' ] 开通商城用户成功！',sHint);
    except
      FDM.ADOConn.RollbackTrans;
      ShowMsg('开通商城用户失败', '未知错误');
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
  //默认密码123456
  nPass := '123456';

  //发送绑定请求开户请求
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
    ShowMsg('手机号码[ '+nPhone+' ]注册商城用户失败！', sError);
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
  //判断是否开通过商城账号
  nSql := 'select 1 from %s where wcb_WebMallStatus=''1'' and wcb_Phone=''%s''';
  nSql := Format(nSql,[sTable_WeixinBind,nPhone]);
  nDs := FDM.QuerySQL(nSql);
  //已开通商城账号
  if nDs.RecordCount>0 then
  begin
    //发送web请求删除商城账号
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
      ShowMsg('手机号码[ '+nPhone+' ]删除商城用户失败！', sError);
      Result := False;
      Exit;
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameCustomer, TfFrameCustomer.FrameID);
end.
