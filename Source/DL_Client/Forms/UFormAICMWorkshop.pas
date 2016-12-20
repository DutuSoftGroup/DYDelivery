{*******************************************************************************
  作者: 289525016@163.com 2016-12-20
  描述: 自助办卡系统-发货车间管理
*******************************************************************************}
unit UFormAICMWorkshop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  CPort, CPortTypes, UFormNormal, UFormBase, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxLabel, cxTextEdit,
  dxLayoutControl, StdCtrls, cxGraphics, dxLayoutcxEditAdapters,
  cxMaskEdit, cxDropDownEdit;

type
  TfFormAICMWorkshop = class(TfFormNormal)
    cbbStockNo: TcxComboBox;
    dxLayout1Item7: TdxLayoutItem;
    cbbStockName: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    cbbWorkshop: TcxComboBox;
    dxLayout1Item4: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    Fstockno:string;
    Fstockname:string;
    Fworkshopcode:string;
    Fworkshopname:string;
    procedure InitFormData;
    procedure InitWorkshop(const nList: TStrings);
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
  UDataModule,UAdjustForm,UFormCtrl,UBusinessPacker;

class function TfFormAICMWorkshop.FormID: integer;
begin
  Result := cFI_FormAICMWorkshop;
end;

class function TfFormAICMWorkshop.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormAICMWorkshop.Create(Application) do
  begin
    Caption := '发货车间 - 修改';

    cbbStockNo.Enabled := False;
    cbbStockName.Enabled := False;

    Fstockno := VarToStr(nP.FParamA);
    Fstockname := VarToStr(nP.FParamB);
    Fworkshopcode := VarToStr(nP.FParamC);
    Fworkshopname := VarToStr(np.FParamD);
    InitFormData;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

//Desc: 保存单价
procedure TfFormAICMWorkshop.BtnOKClick(Sender: TObject);
var nStockNo:string;
  nWorkshopCode,nWorkshopName:string;
  nSQL: string;
begin
  nStockNo := cbbStockNo.Text;
  nWorkshopName := cbbWorkshop.Text;
  nWorkshopCode :=  GetCtrlData(cbbWorkshop);

  nSQL := 'update %s set d_desc=''%s'',d_memo=''%s'' where d_name=''%s'' and d_paramb=''%s''';
  nSQL := Format(nSQL,[sTable_SysDict,nWorkshopCode,nWorkshopName,sFlag_AICMWorkshop,nStockNo]);

  FDM.ADOConn.BeginTrans;
  try
    FDM.ExecuteSQL(nSQL);
    FDM.ADOConn.CommitTrans;
    ModalResult := mrOK;
    ShowMsg('数据已保存', sHint);
  except
    FDM.ADOConn.RollbackTrans;
    ShowMsg('数据保存失败', '未知原因');
  end;
end;

procedure TfFormAICMWorkshop.InitFormData;
var nStr: string;
begin
  if cbbStockNo.Properties.Items.Count<1 then
  begin
    nStr := 'd_ParamB=Select d_ParamB From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

    FDM.FillStringsData(cbbStockNo.Properties.Items, nStr);
    AdjustCtrlData(Self);
    cbbStockNo.ItemIndex := cbbStockNo.Properties.Items.IndexOf(Fstockno);
  end;
  if cbbStockName.Properties.Items.Count < 1 then
  begin
    nStr := 'D_Value=Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockItem]);

    FDM.FillStringsData(cbbStockName.Properties.Items, nStr);
    AdjustCtrlData(Self);
    cbbStockName.Text := Fstockname;
  end;
  if cbbWorkshop.Properties.Items.Count<1 then
  begin
    InitWorkshop(cbbWorkshop.Properties.Items);
    if Fworkshopcode='B' then
    begin
      cbbWorkshop.ItemIndex := 0;
    end
    else begin
      cbbWorkshop.ItemIndex := 1;
    end;
  end;
end;

procedure TfFormAICMWorkshop.InitWorkshop(const nList: TStrings);
var
  nData: PStringsItemData;
begin
  New(nData);
  nList.Add('一车间');
  nData.FString := 'B';
  nList.Objects[0] := TObject(nData);

  New(nData);
  nList.Add('二车间');
  nData.FString := 'C';
  nList.Objects[1] := TObject(nData);
end;

initialization
  gControlManager.RegCtrl(TfFormAICMWorkshop, TfFormAICMWorkshop.FormID);
end.
