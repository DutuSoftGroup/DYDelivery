{*******************************************************************************
  作者: dmzn@163.com 2009-6-25
  描述: 单元模块

  备注: 由于模块有自注册能力,只要Uses一下即可.
*******************************************************************************}
unit USysModule;

{$I Link.Inc}
interface

uses
  UClientWorker, UMITPacker,
  UFrameLog, UFrameSysLog, UFormIncInfo, UFormBackupSQL, UFormRestoreSQL,
  UFormPassword, UFormBaseInfo, UFrameAuthorize, UFormAuthorize,
  {$IFNDEF GZBJM}
  UFrameCustomer, UFormCustomer, UFormGetCustom, UFrameSalesMan, UFormSalesMan,
  UFrameSaleContract, UFormSaleContract, UFrameZhiKa, UFormZhiKa,
  UFormGetContract, UFormZhiKaAdjust, UFormZhiKaFixMoney, UFrameZhiKaVerify,
  UFormZhiKaVerify, UFrameShouJu, UFormShouJu, UFramePayment, UFormPayment,
  UFrameCustomerCredit, UFormCustomerCredit, UFrameCusAccount,
  UFrameCusInOutMoney, UFrameInvoiceWeek, UFormInvoiceWeek, UFormInvoiceGetWeek,
  UFrameInvoice, UFormInvoice, UFormInvoiceAdjust,UFrameInvoiceK, UFormInvoiceK,
  UFrameInvoiceDtl, UFrameInvoiceZZ, UFormInvoiceZZAll, UFormInvoiceZZCus,
  UFormGetZhiKa, UFrameZhiKaDetail, UFormZhiKaFreeze,
  UFormZhiKaPrice,
  {$ENDIF}
  UFrameBill, UFormBill, UFormGetTruck, UFrameQueryDiapatch, UFrameTruckQuery,
  UFrameBillCard, UFormCard, UFormTruckIn, UFormTruckOut, UFormLadingDai,
  UFormLadingSan, UFramePoundManual, UFramePoundAuto, UFramePMaterails,
  UFormPMaterails, UFramePProvider, UFormPProvider, UFramePoundQuery,
  UFrameQuerySaleDetail, UFrameZTDispatch, UFrameTrucks, UFormTruck,
  UFormRFIDCard, UFormBillNew,UFrameCustomer, UFormCustomer, UFormGetCustom,
  UFormTruckEmpty, UFormReadCard, UFormTransfer, UFrameTransfer,
  UFrameQueryTransferDetail, UFrameZTLines,
  UFormGetYTBatch, UFrameYTBatchcode,

  UFramePurchaseOrder, UFormPurchaseOrder, UFormPurchasing,
  UFrameQueryOrderDetail, UFrameOrderCard,  UFrameOrderDetail,
  UFormGetProvider, UFormGetMeterails, UFramePOrderBase, UFormPOrderBase,
  UFormGetPOrderBase, UFrameWeixinBind,UFormWeixinBind,UFormOrderDtl,
  UFormAICMWorkshop,UFrameAICMWorkshop,
  {$IFDEF MicroMsg}
  UFrameWeiXinAccount, UFormWeiXinAccount, UFrameWeiXinSendlog,
  UFormWeiXinSendlog,
  {$ENDIF}
  //----------------------------------------------------------------------------
  UFormHYStock, UFormHYData, UFormHYRecord, UFormGetStockNo,
  UFrameHYStock, UFrameHYData, UFrameHYRecord;

procedure InitSystemObject;
procedure RunSystemObject;
procedure FreeSystemObject;

implementation

uses
  UMgrChannel, UChannelChooser, UDataModule, USysDB, USysMAC, SysUtils,
  USysLoger, USysConst,UMemDataPool;

//Desc: 初始化系统对象
procedure InitSystemObject;
begin
  if not Assigned(gSysLoger) then
    gSysLoger := TSysLoger.Create(gPath + sLogDir);
  //system loger

  if not Assigned(gMemDataManager) then
    gMemDataManager := TMemDataManager.Create;
  //Memory Manager

  gChannelManager := TChannelManager.Create;
  gChannelManager.ChannelMax := 20;
  gChannelChoolser := TChannelChoolser.Create('');
  gChannelChoolser.AutoUpdateLocal := False;
  //channel
end;

//Desc: 运行系统对象
procedure RunSystemObject;
var nStr: string;
begin
  with gSysParam do
  begin
    FLocalMAC   := MakeActionID_MAC;
    GetLocalIPConfig(FLocalName, FLocalIP);
  end;

  nStr := 'Select W_Factory,W_Serial From %s ' +
          'Where W_MAC=''%s'' And W_Valid=''%s''';
  nStr := Format(nStr, [sTable_WorkePC, gSysParam.FLocalMAC, sFlag_Yes]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FFactNum := Fields[0].AsString;
    gSysParam.FSerialID := Fields[1].AsString;
  end;

  //----------------------------------------------------------------------------
  with gSysParam do
  begin
    FPoundDaiZ := 0;
    FPoundDaiF := 0;
    FPoundSanF := 0;
    FDaiWCStop := False;
    FDaiPercent := False;
  end;

  nStr := 'Select D_Value,D_Memo From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := Fields[1].AsString;
      if nStr = sFlag_PDaiWuChaZ then
        gSysParam.FPoundDaiZ := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiWuChaF then
        gSysParam.FPoundDaiF := Fields[0].AsFloat;
      //xxxxx

      if nStr = sFlag_PDaiPercent then
        gSysParam.FDaiPercent := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PDaiWuChaStop then
        gSysParam.FDaiWCStop := Fields[0].AsString = sFlag_Yes;
      //xxxxx

      if nStr = sFlag_PSanWuChaF then
        gSysParam.FPoundSanF := Fields[0].AsFloat;
      Next;
    end;

    with gSysParam do
    begin
      FPoundDaiZ_1 := FPoundDaiZ;
      FPoundDaiF_1 := FPoundDaiF;
      //backup wucha value
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_MITSrvURL]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      gChannelChoolser.AddChannelURL(Fields[0].AsString);
      Next;
    end;

    {$IFNDEF DEBUG}
    //gChannelChoolser.StartRefresh;
    {$ENDIF}//update channel
  end;

  nStr := 'Select D_Value From %s Where D_Name=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_HardSrvURL]);

  with FDM.QueryTemp(nStr) do
  if RecordCount > 0 then
  begin
    gSysParam.FHardMonURL := Fields[0].AsString;
  end;
end;

//Desc: 释放系统对象
procedure FreeSystemObject;
begin
  FreeAndNil(gSysLoger);
end;

end.
