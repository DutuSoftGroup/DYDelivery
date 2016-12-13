{*******************************************************************************
  ����: dmzn@163.com 2009-6-22
  ����: �������
*******************************************************************************}
unit UFrameBill;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter,
  cxData, cxDataStorage, cxEdit, DB, cxDBData, ADODB, cxContainer, cxLabel,
  dxLayoutControl, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxTextEdit, cxMaskEdit, cxButtonEdit, Menus,
  UBitmapPanel, cxSplitter, cxLookAndFeels, cxLookAndFeelPainters,
  cxCheckBox, dxLayoutcxEditAdapters;

type
  TfFrameBill = class(TfFrameNormal)
    EditCus: TcxButtonEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    cxTextEdit4: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    cxTextEdit3: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditDate: TcxButtonEdit;
    dxLayout1Item7: TdxLayoutItem;
    PMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N4: TMenuItem;
    EditLID: TcxButtonEdit;
    dxLayout1Item8: TdxLayoutItem;
    N5: TMenuItem;
    Edit1: TcxTextEdit;
    dxLayout1Item9: TdxLayoutItem;
    N8: TMenuItem;
    N9: TMenuItem;
    dxLayout1Item10: TdxLayoutItem;
    CheckDelete: TcxCheckBox;
    dxlytmLayout1Item11: TdxLayoutItem;
    EditYTCard: TcxButtonEdit;
    N3: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N10: TMenuItem;
    procedure EditIDPropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnDelClick(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure EditDatePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure PMenu1Popup(Sender: TObject);
    procedure CheckDeleteClick(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure SendMsgToWebMall(const nBillno:string);
    procedure N10Click(Sender: TObject);
  protected
    FStart,FEnd: TDate;
    //ʱ������
    FUseDate: Boolean;
    //ʹ������
    procedure OnCreateFrame; override;
    procedure OnDestroyFrame; override;
    function FilterColumnField: string; override;
    function InitFormDataSQL(const nWhere: string): string; override;
    procedure AfterInitFormData; override;
    {*��ѯSQL*}
  public
    { Public declarations }
    class function FrameID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  ULibFun, UMgrControl, UDataModule, UFormBase, UFormInputbox, USysPopedom,
  USysConst, USysDB, USysBusiness, UFormDateFilter,UBusinessConst,UBusinessPacker,
  USysLoger;

//------------------------------------------------------------------------------
class function TfFrameBill.FrameID: integer;
begin
  Result := cFI_FrameBill;
end;

procedure TfFrameBill.OnCreateFrame;
begin
  inherited;
  FUseDate := True;
  InitDateRange(Name, FStart, FEnd);
end;

procedure TfFrameBill.OnDestroyFrame;
begin
  SaveDateRange(Name, FStart, FEnd);
  inherited;
end;

//Desc: ���ݲ�ѯSQL
function TfFrameBill.InitFormDataSQL(const nWhere: string): string;
var nStr: string;
begin
  FEnableBackDB := True;

  EditDate.Text := Format('%s �� %s', [Date2Str(FStart), Date2Str(FEnd)]);

  Result := 'Select * From $Bill ';
  //�����

  if (nWhere = '') or FUseDate then
  begin
    Result := Result + 'Where (L_Date>=''$ST'' and L_Date <''$End'')';
    nStr := ' And ';
  end else nStr := ' Where ';

  if nWhere <> '' then
    Result := Result + nStr + '(' + nWhere + ')';
  //xxxxx

  Result := MacroValue(Result, [
            MI('$ST', Date2Str(FStart)), MI('$End', Date2Str(FEnd + 1))]);
  //xxxxx

  if CheckDelete.Checked then
       Result := MacroValue(Result, [MI('$Bill', sTable_BillBak)])
  else Result := MacroValue(Result, [MI('$Bill', sTable_Bill)]);
end;

procedure TfFrameBill.AfterInitFormData;
begin
  FUseDate := True;
end;

function TfFrameBill.FilterColumnField: string;
begin
  if gPopedomManager.HasPopedom(PopedomItem, sPopedom_ViewPrice) then
       Result := ''
  else Result := 'L_Price';
end;

//Desc: ִ�в�ѯ
procedure TfFrameBill.EditIDPropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditLID then
  begin
    EditLID.Text := Trim(EditLID.Text);
    if EditLID.Text = '' then Exit;

    FUseDate := Length(EditLID.Text) <= 3;
    FWhere := 'L_ID like ''%' + EditLID.Text + '%''';
    InitFormData(FWhere);
  end else

  if Sender = EditCus then
  begin
    EditCus.Text := Trim(EditCus.Text);
    if EditCus.Text = '' then Exit;

    FWhere := 'L_CusPY like ''%%%s%%'' Or L_CusName like ''%%%s%%''';
    FWhere := Format(FWhere, [EditCus.Text, EditCus.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditTruck then
  begin
    EditTruck.Text := Trim(EditTruck.Text);
    if EditTruck.Text = '' then Exit;

    FUseDate := Length(EditTruck.Text) <= 3;
    FWhere := Format('L_Truck like ''%%%s%%''', [EditTruck.Text]);
    InitFormData(FWhere);
  end else

  if Sender = EditYTCard then
  begin
    EditYTCard.Text := Trim(EditYTCard.Text);
    if EditYTCard.Text = '' then Exit;

    FUseDate := Length(EditYTCard.Text) <= 3;
    FWhere := Format('L_Project like ''%%%s%%''', [EditYTCard.Text]);
    InitFormData(FWhere); 
  end;
end;

//Desc: δ��ʼ����������
procedure TfFrameBill.N4Click(Sender: TObject);
begin
  case TComponent(Sender).Tag of
   10: FWhere := Format('(L_Status=''%s'')', [sFlag_BillNew]);
   20: FWhere := 'L_OutFact Is Null'
   else Exit;
  end;

  FUseDate := False;
  InitFormData(FWhere);
end;

//Desc: ����ɸѡ
procedure TfFrameBill.EditDatePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if ShowDateFilterForm(FStart, FEnd) then InitFormData('');
end;

//Desc: ��ѯɾ��
procedure TfFrameBill.CheckDeleteClick(Sender: TObject);
begin
  InitFormData('');
end;

//------------------------------------------------------------------------------
//Desc: �������
procedure TfFrameBill.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  CreateBaseFormItem(cFI_FormBill, PopedomItem, @nP);
  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: ɾ��
procedure TfFrameBill.BtnDelClick(Sender: TObject);
var nStr, nHasOut: string;
begin
  if cxView1.DataController.GetSelectedCount < 1 then
  begin
    ShowMsg('��ѡ��Ҫɾ���ļ�¼', sHint); Exit;
  end;

  nHasOut := Trim(SQLQuery.FieldByName('L_OutFact').AsString);
  if nHasOut <> '' then
  begin
    if not gSysParam.FIsAdmin then Exit;

    nStr := '���[ %s ]�����ѳ���, ��ȷ���Ƿ�ɾ��?';
    nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString]);
    if not QueryDlg(nStr, sAsk) then Exit;
  end;

  nStr := 'ȷ��Ҫɾ�����Ϊ[ %s ]�ĵ�����?';
  nStr := Format(nStr, [SQLQuery.FieldByName('L_ID').AsString]);
  if not QueryDlg(nStr, sAsk) then Exit;

  //���͹��ں���Ϣ
  SendMsgToWebMall(SQLQuery.FieldByName('L_ID').AsString);
  nStr := 'update %s set WOM_deleted=''%s'' where WOM_LID=''%s''';
  nStr := Format(nStr,[sTable_WebOrderMatch,sFlag_Yes,SQLQuery.FieldByName('L_ID').AsString]);
  fdm.ExecuteSQL(nStr);

  if DeleteBill(SQLQuery.FieldByName('L_ID').AsString) then
  begin
    InitFormData(FWhere);
    ShowMsg('�������ɾ��', sHint);
  end;
end;

//Desc: ��ӡ�����
procedure TfFrameBill.N1Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillReport(nStr, False);
  end;
end;

procedure TfFrameBill.PMenu1Popup(Sender: TObject);
begin
  N3.Enabled := gPopedomManager.HasPopedom(PopedomItem, sPopedom_Edit);
  //���۵���
end;

//Desc: �޸�δ�������ƺ�
procedure TfFrameBill.N5Click(Sender: TObject);
var nStr,nTruck: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_Truck').AsString;
    nTruck := nStr;
    if not ShowInputBox('�������µĳ��ƺ���:', '�޸�', nTruck, 15) then Exit;

    if (nTruck = '') or (nStr = nTruck) then Exit;
    //��Ч��һ��

    nStr := SQLQuery.FieldByName('L_ID').AsString;
    if ChangeLadingTruckNo(nStr, nTruck) then
    begin
      InitFormData(FWhere);
      ShowMsg('���ƺ��޸ĳɹ�', sHint);
    end;
  end;
end;

//Desc: �޸ķ�ǩ��
procedure TfFrameBill.N7Click(Sender: TObject);
var nStr,nID,nSeal: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_HYDan').AsString;
    nSeal := nStr;
    if not ShowInputBox('�������µĳ������:', '�޸�', nSeal, 100) then Exit;

    if (nSeal = '') or (nStr = nSeal) then Exit;
    //��Ч��һ��
    nID := SQLQuery.FieldByName('L_ID').AsString;

    nStr := 'ȷ��Ҫ��������[ %s ]�ĳ�����Ÿ�Ϊ[ %s ]��?';
    nStr := Format(nStr, [nID, nSeal]);
    if not QueryDlg(nStr, sAsk) then Exit;

    if ChangeLadingSeal(nID, nSeal) then
    begin
      nStr := '�޸ĳ������[ %s -> %s ].';
      nStr := Format(nStr, [SQLQuery.FieldByName('L_HYDan').AsString, nSeal]);
      FDM.WriteSysLog(sFlag_BillItem, nID, nStr, False);
      ShowMsg('��������޸ĳɹ�', sHint);
    end;

    InitFormData(FWhere);
  end;
end;

//Desc: ��ӡ��·��
procedure TfFrameBill.N3Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillLoadReport(nStr, False);
  end;
end;

procedure TfFrameBill.N6Click(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('L_ID').AsString;
    PrintBillFYDReport(nStr, False);
  end;
end;

procedure TfFrameBill.N10Click(Sender: TObject);
var nStr: string;
  nOutFact:string;             
begin
  inherited;
  if (cxView1.DataController.GetSelectedCount > 0) and (not CheckDelete.Checked) then
  begin
    nStr := SQLQuery.FieldByName('L_HYDan').AsString;
    nOutFact := FormatDateTime('yyyy��mm��dd��',SQLQuery.FieldByName('L_OutFact').AsDateTime);
    PrintHuaYanReport(nStr, SQLQuery.FieldByName('L_StockName').AsString,nOutFact, False);
  end;
end;

procedure TfFrameBill.SendMsgToWebMall(const nBillno: string);
var
  nSql:string;
  nDs:TDataSet;

  nBills: TLadingBillItems;
  nXmlStr,nData:string;
  i:Integer;
  nItem:TLadingBillItem;
  nMobileNo,nCustomerid:string;
begin

  //�����������Ϣ
  if not GetLadingBills(nBillno, sFlag_BillDel, nBills) then
  begin
    Exit;
  end;

  //����web�ӿڷ�����Ϣ
  for i := Low(nBills) to High(nBills) do
  begin
    nItem := nBills[i];

    //��ѯ�ֻ�����
    nSql := 'select i_info from %s where i_group=''%s'' and i_Item=''%s'''
        +' and i_itemid = (select l_cusid from s_bill where l_id in(%s))';
    nSql := Format(nSql,[sTable_ExtInfo,sFlag_CustomerItem,'�ֻ�',nBillno]);

    if FDM.QuerySQL(nSql).recordcount<=0 then
    begin
      Continue;
    end;
    nMobileNo := FDM.QuerySQL(nSql).FieldByName('i_info').asstring;

    //���ֻ��Ų�ѯ΢�źŰ󶨵�Customerid
    nSql := 'select wcb_Bindcustomerid from %s where wcb_WebMallStatus=''1'' and wcb_Phone=''%s''';
    nSql := Format(nSql,[sTable_WeixinBind,nMobileNo]);
    if FDM.QuerySQL(nSql).recordcount<=0 then
    begin
      Continue;
    end;
    nCustomerid := FDM.QuerySQL(nSql).FieldByName('wcb_Bindcustomerid').asstring;

    nXmlStr := '<?xml version="1.0" encoding="UTF-8"?>'
        +'<DATA>'
        +'<head>'
        +'<Factory>%s</Factory>'
        +'<ToUser>%s</ToUser>'
        +'<MsgType>%d</MsgType>'
        +'</head>'
        +'<Items>'
        +'	  <Item>'
        +'	      <BillID>%s</BillID>'
        +'	      <Card>%s</Card>'
        +'	      <Truck>%s</Truck>'
        +'	      <StockNo>%s</StockNo>'
        +'	      <StockName>%s</StockName>'
        +'	      <CusID>%s</CusID>'
        +'	      <CusName>%s</CusName>'
        +'	      <CusAccount></CusAccount>'
        +'	      <MakeDate></MakeDate>'
        +'	      <MakeMan></MakeMan>'
        +'	      <TransID></TransID>'
        +'	      <TransName></TransName>'
        +'	      <Searial></Searial>'
        +'	      <OutFact></OutFact>'
        +'	      <OutMan></OutMan>'
        +'	  </Item>	'
        +'</Items>'
        +'   <remark/>'
        +'</DATA>';
    nXmlStr := Format(nXmlStr,[gSysParam.FFactory, nCustomerid,cSendWeChatMsgType_DelBill,
          nItem.FID,nItem.FCard,nitem.FTruck,
          nItem.FStockNo,nItem.FStockName,nItem.FCusID,
          nItem.FCusName]);
    nXmlStr := PackerEncodeStr(nXmlStr);
    nData := send_event_msg(nXmlStr);
    gSysLoger.AddLog(TfFrameBill,'SendMsgToWebMall',nData);

    if ndata<>'' then
    begin
      ShowMsg(nData,sHint);
    end;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameBill, TfFrameBill.FrameID);
end.
