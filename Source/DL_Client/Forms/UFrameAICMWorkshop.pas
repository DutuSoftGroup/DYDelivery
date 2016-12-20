{*******************************************************************************
  作者: 289525016@163.com 2016-12-20
  描述: 自助办卡系统-发货车间管理
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
    {*查询SQL*}
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

//Desc: 修改
procedure TfFrameAICMWorkshop.BtnEditClick(Sender: TObject);
var nP: TFormCommandParam;
begin
  if cxView1.DataController.GetSelectedCount > 0 then
  begin
    nP.FCommand := cCmd_EditData;
    nP.FParamA := SQLQuery.FieldByName('d_paramb').AsString;//水泥编号
    nP.FParamB := SQLQuery.FieldByName('d_value').AsString; //水泥名称
    nP.FParamC := SQLQuery.FieldByName('d_desc').AsString; //车间代码
    nP.FParamD := SQLQuery.FieldByName('d_memo').AsString; //车间名称
    CreateBaseFormItem(cFI_FormAICMWorkshop, '', @nP);

    if (nP.FCommand = cCmd_ModalResult) and (nP.FParamA = mrOK) then
    begin
      InitFormData(FWhere);
    end;
  end;
end;

//Desc: 查询
initialization
  gControlManager.RegCtrl(TfFrameAICMWorkshop, TfFrameAICMWorkshop.FrameID);
end.
