{*******************************************************************************
  ����: 289525016@163.com 2016-12-20
  ����: �����쿨ϵͳ-�����������
*******************************************************************************}
unit UFrameAICMWorkshop;

{$I Link.Inc}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  UFrameNormal, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, dxLayoutControl, cxMaskEdit,
  cxButtonEdit, cxTextEdit, ADODB, cxContainer, cxLabel, UBitmapPanel,
  cxSplitter, cxGridLevel, cxClasses, cxControls, cxGridCustomView,
  cxGridCustomTableView, cxGridTableView, cxGridDBTableView, cxGrid,
  ComCtrls, ToolWin, cxLookAndFeels, cxLookAndFeelPainters,Menus,
  dxLayoutcxEditAdapters;

type
  TfFrameAICMWorkshop = class(TfFrameNormal)
    procedure BtnEditClick(Sender: TObject);
  private
    { Private declarations }
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
  ULibFun, UMgrControl, USysConst, USysDB, UDataModule, UFormBase, USysBusiness,
  UBusinessPacker;

class function TfFrameAICMWorkshop.FrameID: integer;
begin
  Result := cFI_FrameAICMWorkshop;
end;

function TfFrameAICMWorkshop.InitFormDataSQL(const nWhere: string): string;
begin
  Result := 'select * from %s where d_name=''%s''';
  Result := Format(Result,[sTable_SysDict,sFlag_AICMWorkshop]);
  dxGroup1.Visible := False;
  cxSplitter1.Visible := False;
end;

//Desc: �޸�
procedure TfFrameAICMWorkshop.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('d_paramb').AsString;//ˮ����
    nP.FParamB := SQLQuery.FieldByName('d_value').AsString; //ˮ������
    nP.FParamC := SQLQuery.FieldByName('d_desc').AsString; //�������
    nP.FParamD := SQLQuery.FieldByName('d_memo').AsString; //��������
    CreateBaseFormItem(cFI_FormAICMWorkshop, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: ��ѯ
initialization
  gControlManager.RegCtrl(TfFrameAICMWorkshop, TfFrameAICMWorkshop.FrameID);
end.
