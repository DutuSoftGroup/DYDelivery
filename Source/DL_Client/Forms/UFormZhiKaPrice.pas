{*******************************************************************************
  ����: dmzn@163.com 2010-3-16
  ����: ֽ������
*******************************************************************************}
unit UFormZhiKaPrice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFormNormal, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, cxCheckBox, cxTextEdit,
  dxLayoutControl, StdCtrls;

type
  TfFormZKPrice = class(TfFormNormal)
    EditStock: TcxTextEdit;
    dxLayout1Item3: TdxLayoutItem;
    EditPrice: TcxTextEdit;
    dxLayout1Item4: TdxLayoutItem;
    EditNew: TcxTextEdit;
    dxLayout1Item5: TdxLayoutItem;
    Check1: TcxCheckBox;
    dxLayout1Item6: TdxLayoutItem;
    Check2: TcxCheckBox;
    dxLayout1Item7: TdxLayoutItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
  private
    { Private declarations }
    FZKList: TStrings;
    //ֽ���б�
    procedure InitFormData;
    //��������
  public
    { Public declarations }
    class function CreateForm(const nPopedom: string = '';
      const nParam: Pointer = nil): TWinControl; override;
    class function FormID: integer; override;
  end;

implementation

{$R *.dfm}
uses
  IniFiles, ULibFun, UFormBase, UMgrControl, USysDB, USysConst, USysBusiness,
  UFormWait, UDataModule;

class function TfFormZKPrice.CreateForm(const nPopedom: string;
  const nParam: Pointer): TWinControl;
var nP: PFormCommandParam;
begin
  Result := nil;
  if Assigned(nParam) then
       nP := nParam
  else Exit;

  with TfFormZKPrice.Create(Application) do
  begin
    Caption := 'ֽ������';
    FZKList.Text := nP.FParamB;
    InitFormData;
    
    nP.FCommand := cCmd_ModalResult;
    nP.FParamA := ShowModal;
    Free;
  end;
end;

class function TfFormZKPrice.FormID: integer;
begin
  Result := cFI_FormAdjustPrice;
end;

procedure TfFormZKPrice.FormCreate(Sender: TObject);
var nIni: TIniFile;
begin
  FZKList := TStringList.Create;
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    LoadFormConfig(Self, nIni);
    Check1.Checked := nIni.ReadBool(Name, 'AutoUnfreeze', True);
    Check2.Checked := nIni.ReadBool(Name, 'NewPriceType', False);
  finally
    nIni.Free;
  end;
end;

procedure TfFormZKPrice.FormClose(Sender: TObject;
  var Action: TCloseAction);
var nIni: TIniFile;
begin
  nIni := TIniFile.Create(gPath + sFormConfig);
  try
    SaveFormConfig(Self, nIni);
    nIni.WriteBool(Name, 'AutoUnfreeze', Check1.Checked);
    nIni.WriteBool(Name, 'NewPriceType', Check2.Checked);
  finally
    nIni.Free;
  end;

  FZKList.Free;
end;

//------------------------------------------------------------------------------
procedure TfFormZKPrice.InitFormData;
var nIdx: Integer; 
    nStock: string;
    nList: TStrings;
    nMin,nMax,nVal: Double;
begin
  nList := TStringList.Create;
  try
    nMin := MaxInt;
    nMax := 0;
    nStock := '';

    for nIdx:=FZKList.Count - 1 downto 0 do
    begin
      if not SplitStr(FZKList[nIdx], nList, 5, ';') then Continue;
      //��ϸ��¼��;����;ֽ��;Ʒ������
      if not IsNumber(nList[1], True) then Continue;

      nVal := StrToFloat(nList[1]);
      if nVal < nMin then nMin := nVal;
      if nVal > nMax then nMax := nVal;
      if nStock = '' then nStock := nList[4];
    end;

    ActiveControl := EditNew;
    EditStock.Text := nStock;
    
    if nMin = nMax then
         EditPrice.Text := Format('%.2f Ԫ/��', [nMax])
    else EditPrice.Text := Format('%.2f - %.2f Ԫ/��', [nMin, nMax]);
  finally
    nList.Free;
  end;
end;

procedure TfFormZKPrice.BtnOKClick(Sender: TObject);
var nStr: string;
    nVal: Double;
    nIdx: Integer;
    nList: TStrings;
begin
  if not (IsNumber(EditNew.Text, True) and ((StrToFloat(EditNew.Text) > 0) or
     Check2.Checked)) then
  begin
    EditNew.SetFocus;
    ShowMsg('��������ȷ�ĵ���', sHint); Exit;
  end;

  nStr := 'ע��: �ò��������Գ���,��������!' + #13#10#13#10 +
          '�۸������,�µ��ۻ�������Ч,Ҫ������?  ';
  if not QueryDlg(nStr, sAsk, Handle) then Exit;

  nList := nil;
  FDM.ADOConn.BeginTrans;
  try
    if FZKList.Count > 20 then
      ShowWaitForm(Self, '������,���Ժ�');
    nList := TStringList.Create;

    for nIdx:=FZKList.Count - 1 downto 0 do
    begin
      if not SplitStr(FZKList[nIdx], nList, 5, ';') then Continue;
      //��ϸ��¼��;����;ֽ��;Ʒ������

      nVal := StrToFloat(EditNew.Text);
      if Check2.Checked then
        nVal := StrToFloat(nList[1]) + nVal;
      nVal := Float2Float(nVal, cPrecision, True);

      nStr := 'Update %s Set D_Price=%.2f,D_PPrice=%s ' +
              'Where R_ID=%s And D_TPrice<>''%s''';
      nStr := Format(nStr, [sTable_ZhiKaDtl, nVal, nList[1], nList[0], sFlag_No]);
      FDM.ExecuteSQL(nStr);

      nStr := 'ˮ��Ʒ��[ %s ]���۵���[ %s -> %.2f ]';
      nStr := Format(nStr, [nList[4], nList[1], nVal]);
      FDM.WriteSysLog(sFlag_ZhiKaItem, nList[2], nStr, False);

      if not Check1.Checked then Continue;
      nStr := 'Update %s Set Z_TJStatus=''%s'' Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, sFlag_TJOver, nList[2]]);
      FDM.ExecuteSQL(nStr);
    end;

    FDM.ADOConn.CommitTrans;
    nIdx := MaxInt;
  except
    nIdx := -1;
    FDM.ADOConn.RollbackTrans;
    ShowMsg('����ʧ��', sError);
  end;

  nList.Free;
  if FZKList.Count > 20 then CloseWaitForm;
  if nIdx = MaxInt then ModalResult := mrOk;
end;

initialization
  gControlManager.RegCtrl(TfFormZKPrice, TfFormZKPrice.FormID);
end.
