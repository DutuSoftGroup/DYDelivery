{*******************************************************************************
  作者: fendou116688@163.com 2016/8/17
  描述: 云天批次记录
*******************************************************************************}
unit UFrameYTBatchcode;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxStyles, dxSkinsCore, dxSkinsDefaultPainters,
  cxCustomData, cxFilter, cxData, cxDataStorage, cxEdit, DB, cxDBData,
  cxContainer, dxLayoutControl, cxMaskEdit, cxButtonEdit, cxTextEdit,
  ADODB, cxLabel, UBitmapPanel, cxSplitter, cxGridLevel, cxClasses,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView,
  cxGridDBTableView, cxGrid, ComCtrls, ToolWin, Menus;

type
  TfFrameYTBatchcode = class(TfFrameNormal)
    cxTextEdit1: TcxTextEdit;
    dxLayout1Item1: TdxLayoutItem;
    EditName: TcxButtonEdit;
    dxLayout1Item2: TdxLayoutItem;
    cxTextEdit2: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure EditNamePropertiesButtonClick(Sender: TObject;
      AButtonIndex: Integer);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnEditClick(Sender: TObject);
    procedure BtnDelClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
  private
    { Private declarations }
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
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase,
  UFormCtrl, USysBusiness;

class function TfFrameYTBatchcode.FrameID: integer;
begin
  Result := cFI_FrameYTBatchcode;
end;

function TfFrameYTBatchcode.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'Select * From ' + sTable_YT_Batchcode;
  if nWhere <> '' then
    Result := Result + ' Where (' + nWhere + ')';
  Result := Result + ' Order By M_Name';
end;

//Desc: 添加
procedure TfFrameYTBatchcode.BtnAddClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  nP.FCommand := cCmd_AddData;
  CreateBaseFormItem(cFI_FormMaterails, '', @nP);

  if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
  begin
    InitFormData('');
  end;
end;

//Desc: 修改
procedure TfFrameYTBatchcode.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('M_ID').AsString;
    CreateBaseFormItem(cFI_FormMaterails, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 删除
procedure TfFrameYTBatchcode.BtnDelClick(Sender: TObject);
var nStr: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('M_Name').AsString;
    nStr := Format('确定要删除原材料[ %s ]吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStr := 'Delete From %s Where R_ID=%s';
    nStr := Format(nStr, [sTable_Materails, SQLQuery.FieldByName('R_ID').AsString]);

    FDM.ExecuteSQL(nStr);
    InitFormData(FWhere);
  end;
end;

//Desc: 查询
procedure TfFrameYTBatchcode.EditNamePropertiesButtonClick(Sender: TObject;
  AButtonIndex: Integer);
begin
  if Sender = EditName then
  begin
    EditName.Text := Trim(EditName.Text);
    if EditName.Text = '' then Exit;


    FWhere := Format('M_Name Like ''%%%s%%'' or M_PY Like ''%%%s%%''' +
              ' or M_Memo Like ''%%%s%%''', [EditName.Text,
              EditName.Text, EditName.Text]);
    InitFormData(FWhere);
  end;
end;

procedure TfFrameYTBatchcode.N1Click(Sender: TObject);
begin
  inherited;
  SyncRemoteMeterails;
  BtnRefresh.Click;
end;

procedure TfFrameYTBatchcode.PopupMenu1Popup(Sender: TObject);
begin
  inherited;
  {$IFDEF SyncRemote}
  N1.Visible := True;
  {$ENDIF}
end;

procedure TfFrameYTBatchcode.N2Click(Sender: TObject);
var nStr: string;
    nStockName, nStockID, nStockType: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('M_Name').AsString;
    nStr := Format('确定要将材料[ %s ]设为发货品种吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStockID := SQLQuery.FieldByName('M_ID').AsString;
    nStockName := SQLQuery.FieldByName('M_Name').AsString;

    if Pos('袋', nStockName) > 0 then
         nStockType := sFlag_Dai
    else nStockType := sFlag_San;

    nStr := 'Select count(*) From %s Where D_Name=''%s'' And D_ParamB=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem, nStockID]);
    with FDM.QueryTemp(nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('D_Name', sFlag_StockItem),
              SF('D_Desc', '水泥类型'),
              SF('D_ParamA', 0, sfVal),
              SF('D_ParamB', nStockID),
              SF('D_Value', nStockName),
              SF('D_Memo', nStockType)], sTable_SysDict, '', True);
      FDM.ExecuteSQL(nStr);

      nStr := 'Update %s Set M_IsSale=''%s'' Where M_ID=''%s''';
      nStr := Format(nStr, [sTable_Materails, sFlag_Yes, nStockID]);
      FDM.ExecuteSQL(nStr);
    end;

    InitFormData(FWhere);
  end;
end;

procedure TfFrameYTBatchcode.N3Click(Sender: TObject);
var nStr, nStockID: string;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nStr := SQLQuery.FieldByName('M_Name').AsString;
    nStr := Format('确定要取消材料[ %s ]的发货品种吗?', [nStr]);
    if not QueryDlg(nStr, sAsk) then Exit;

    nStockID := SQLQuery.FieldByName('M_ID').AsString;
    nStr := 'Delete From %s Where D_Name=''%s'' And D_ParamB=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem, nStockID]);
    FDM.ExecuteSQL(nStr);

    nStr := 'Update %s Set M_IsSale=''%s'' Where M_ID=''%s''';
    nStr := Format(nStr, [sTable_Materails, sFlag_No, nStockID]);
    FDM.ExecuteSQL(nStr);
    
    InitFormData(FWhere);
  end;
end;

initialization
  gControlManager.RegCtrl(TfFrameYTBatchcode, TfFrameYTBatchcode.FrameID);
end.
