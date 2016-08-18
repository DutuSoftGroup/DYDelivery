{*******************************************************************************
����: fendou116688@163.com 2016/2/26
����: �̵�ҵ�����ſ�
*******************************************************************************}
unit UFormTransfer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, dxLayoutControl, StdCtrls, cxContainer, cxEdit,
  cxTextEdit, cxMaskEdit, cxDropDownEdit, cxButtonEdit;

type
  TfFormTransfer = class(TfFormNormal)
    EditMate: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    EditSrcAddr: TcxTextEdit;
    dxLayout1Item6: TdxLayoutItem;
    EditDstAddr: TcxTextEdit;
    dxLayout1Item7: TdxLayoutItem;
    EditMID: TcxComboBox;
    dxLayout1Item3: TdxLayoutItem;
    EditDC: TcxComboBox;
    dxLayout1Item8: TdxLayoutItem;
    EditDR: TcxComboBox;
    dxLayout1Item9: TdxLayoutItem;
    EditTruck: TcxButtonEdit;
    dxLayout1Item4: TdxLayoutItem;
    procedure BtnOKClick(Sender: TObject);
    procedure EditMIDPropertiesChange(Sender: TObject);
    procedure EditDCPropertiesChange(Sender: TObject);
    procedure EditTruckKeyPress(Sender: TObject; var Key: Char);
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
  UMgrControl, UDataModule, UFormBase, UFormCtrl, UBusinessPacker,
  USysDB, USysConst, UAdjustForm, USysBusiness;

type
  TMateItem = record
    FID   : string;
    FName : string;
  end;

var
  gMateItems: array of TMateItem;
  //Ʒ���б�

class function TfFormTransfer.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
    nP := nParam
  else New(nP);

  with TfFormTransfer.Create(Application) do
  try
    InitFormData;
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
  finally
    Free;
  end;
end;

class function TfFormTransfer.FormID: integer;
begin
  Result := cFI_FormTransBase;
end;

procedure TfFormTransfer.BtnOKClick(Sender: TObject);
var nStr: string;
    nIdx: Integer;
    nList: TStrings;
    nP: TFormCommandParam;
begin
  nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);

  nP.FParamA := Trim(EditTruck.Text);
  CreateBaseFormItem(cFI_FormMakeRFIDCard, '', @nP);
  if (nP.FCommand <> cCmd_ModalResult) or (nP.FParamA <> mrOK) then Exit;

  nList := TStringList.Create;
  try
    with nList do
    begin
      Values['Truck'] := Trim(EditTruck.Text);
      Values['SrcAddr'] := Trim(EditSrcAddr.Text);
      Values['DestAddr']  := Trim(EditDstAddr.Text);
      Values['StockNo'] := gMateItems[nIdx].FID;
      Values['StockName'] := gMateItems[nIdx].FName;
    end;

    nStr := SaveDDBases(PackerEncodeStr(nList.Text));
    //call mit bus
    if nStr = '' then Exit;

    SaveDDCard(nStr, 'H' + nP.FParamB);
    //���ӱ�ǩǰ��һ��H������Զ�����������

    ModalResult := mrOk;
  finally
    FreeAndNil(nList);
  end;
end;

procedure TfFormTransfer.InitFormData;
var nStr: string;
    nInt, nIdx: Integer;
begin
  nStr := 'Select M_ID,M_Name From ' + sTable_Materails;

  EditMID.Properties.Items.Clear;
  SetLength(gMateItems, 0);

  with FDM.QueryTemp(nStr) do
  begin
    if RecordCount < 1 then Exit;
    SetLength(gMateItems, RecordCount);

    nInt := 0;
    nIdx := 0;
    First;

    while not Eof do
    begin
      with gMateItems[nIdx] do
      begin
        FID := Fields[0].AsString;
        FName := Fields[1].AsString;
        EditMID.Properties.Items.AddObject(FID + '.' + FName, Pointer(nIdx));
      end;

      Inc(nIdx);
      Next;
    end;

    EditMID.ItemIndex := nInt;
    EditMate.Text := gMateItems[nInt].FName;
  end;

  nStr := 'P_ID=Select P_ID,P_Name From ' + sTable_Provider;
  FDM.FillStringsData(EditDC.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDC, False);

  FDM.FillStringsData(EditDR.Properties.Items, nStr, 1, '.');
  AdjustCXComboBoxItem(EditDR, False);
end;  

procedure TfFormTransfer.EditMIDPropertiesChange(Sender: TObject);
var nIdx: Integer;
begin
  if (not EditMID.Focused) or (EditMID.ItemIndex < 0) then Exit;
  nIdx := Integer(EditMID.Properties.Items.Objects[EditMID.ItemIndex]);
  EditMate.Text := gMateItems[nIdx].FName;
end;

procedure TfFormTransfer.EditDCPropertiesChange(Sender: TObject);
var nStr: string;
    nCom: TcxComboBox;
begin
  nCom := Sender as TcxComboBox;
  nStr := nCom.Text;
  System.Delete(nStr, 1, Length(GetCtrlData(nCom)) + 1);

  if Sender = EditDC then
    EditSrcAddr.Text := nStr
  else if Sender = EditDR then
    EditDstAddr.Text := nStr;
  //xxxxx
end;

procedure TfFormTransfer.EditTruckKeyPress(Sender: TObject; var Key: Char);
var nP: TFormCommandParam;
begin
  if Key = Char(VK_RETURN) then
  begin
    Key := #0;

    Perform(WM_NEXTDLGCTL, 0, 0);
  end;

  if (Sender = EditTruck) and (Key = Char(VK_SPACE)) then
  begin
    Key := #0;
    nP.FParamA := EditTruck.Text;
    CreateBaseFormItem(cFI_FormGetTruck, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and(nP.FParamA = mrOk) then
      EditTruck.Text := nP.FParamB;
    EditTruck.SelectAll;
  end;
end;

initialization
  gControlManager.RegCtrl(TfFormTransfer, TfFormTransfer.FormID);
end.
