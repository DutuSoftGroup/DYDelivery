{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessBill;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  {$IFDEF MicroMsg}UMgrRemoteWXMsg,{$ENDIF}
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand;

type
  TStockMatchItem = record
    FStock: string;         //Ʒ��
    FGroup: string;         //����
    FRecord: string;        //��¼
    FHKRecord: string;      //�Ͽ�
  end;

  TBillLadingLine = record
    FBill: string;          //������
    FLine: string;          //װ����
    FName: string;          //������
    FLineGroup: string;     //�߷���
    FPerW: Integer;         //����
    FTotal: Integer;        //�ܴ���
    FNormal: Integer;       //����
    FBuCha: Integer;        //����
    FHKBills: string;       //�Ͽ���
  end;

  TWorkerBusinessBills = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
    //io
    FSaveHKRecord: Boolean;
    FSanMultiBill: Boolean;
    //ɢװ�൥
    FStockItems: array of TStockMatchItem;
    FMatchItems: array of TStockMatchItem;
    //����ƥ��
    FBillLines: array of TBillLadingLine;
    //װ����
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton    
    function GetHKRecord:string;
    function GetStockGroup(const nStock: string): string;
    function GetMatchRecord(const nStock: string): string;
    //���Ϸ���                                            
    function GetInBillInterval: Integer;
    function AllowedSanMultiBill: Boolean;
    function AllowedSaveHKRecord: Boolean;
    function VerifyBeforSave(var nData: string): Boolean;
    function SaveBills(var nData: string): Boolean;
    //���潻����
    function DeleteBill(var nData: string): Boolean;
    //ɾ��������
    function ChangeBillTruck(var nData: string): Boolean;
    //�޸ĳ��ƺ�
    function BillSaleAdjust(var nData: string): Boolean;
    //���۵���
    function SaveBillCard(var nData: string): Boolean;
    //�󶨴ſ�
    function LogoffCard(var nData: string): Boolean;
    //ע���ſ�
    function GetPostBillItems(var nData: string): Boolean;
    //��ȡ��λ������
    function SavePostBillItems(var nData: string): Boolean;
    //�����λ������
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
    class function VerifyTruckNO(nTruck: string; var nData: string): Boolean;
    //��֤�����Ƿ���Ч
  end;

implementation
uses
  UHardBusiness;
class function TWorkerBusinessBills.FunctionName: string;
begin
  Result := sBus_BusinessSaleBill;
end;

constructor TWorkerBusinessBills.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessBills.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  inherited;
end;

function TWorkerBusinessBills.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessBills.GetInOutData(var nIn, nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessBills.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nPacker.InitData(@nIn, True, False);
    //init
    
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(FunctionName);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-15
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessBills.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveBills           : Result := SaveBills(nData);
   cBC_DeleteBill          : Result := DeleteBill(nData);
   cBC_ModifyBillTruck     : Result := ChangeBillTruck(nData);
   cBC_SaleAdjust          : Result := BillSaleAdjust(nData);
   cBC_SaveBillCard        : Result := SaveBillCard(nData);
   cBC_LogoffCard          : Result := LogoffCard(nData);
   cBC_GetPostBills        : Result := GetPostBillItems(nData);
   cBC_SavePostBills       : Result := SavePostBillItems(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2014/7/30
//Parm: Ʒ�ֱ��
//Desc: ����nStock��Ӧ�����Ϸ���
function TWorkerBusinessBills.GetStockGroup(const nStock: string): string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FStockItems) to High(FStockItems) do
  if FStockItems[nIdx].FStock = nStock then
  begin
    Result := FStockItems[nIdx].FGroup;
    Exit;
  end;
end;

//Date: 2014/7/30
//Parm: Ʒ�ֱ��
//Desc: ����������������nStockͬƷ��,��ͬ��ļ�¼
function TWorkerBusinessBills.GetMatchRecord(const nStock: string): string;
var nStr: string;
    nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FStock = nStock then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;

  nStr := GetStockGroup(nStock);
  if nStr = '' then Exit;  

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FGroup = nStr then
  begin
    Result := FMatchItems[nIdx].FRecord;
    Exit;
  end;
end;

//Date: 2015/11/3
//Parm:
//Desc: ��ȡ���������кϵ���¼
function TWorkerBusinessBills.GetHKRecord: string;
var nIdx: Integer;
begin
  Result := '';
  //init

  for nIdx:=Low(FMatchItems) to High(FMatchItems) do
  if FMatchItems[nIdx].FHKRecord <> '' then
  begin
    Result := FMatchItems[nIdx].FHKRecord;
    Exit;
  end;
end;

//Date: 2014-09-16
//Parm: ���ƺ�;
//Desc: ��֤nTruck�Ƿ���Ч
class function TWorkerBusinessBills.VerifyTruckNO(nTruck: string;
  var nData: string): Boolean;
var nIdx: Integer;
    nWStr: WideString;
begin
  Result := False;
  nIdx := Length(nTruck);
  if (nIdx < 3) or (nIdx > 10) then
  begin
    nData := '��Ч�ĳ��ƺų���Ϊ3-10.';
    Exit;
  end;

  nWStr := LowerCase(nTruck);
  //lower
  
  for nIdx:=1 to Length(nWStr) do
  begin
    case Ord(nWStr[nIdx]) of
     Ord('-'): Continue;
     Ord('0')..Ord('9'): Continue;
     Ord('a')..Ord('z'): Continue;
    end;

    if nIdx > 1 then
    begin
      nData := Format('���ƺ�[ %s ]��Ч.', [nTruck]);
      Exit;
    end;
  end;

  Result := True;
end;

//Date: 2014-10-07
//Desc: ����ɢװ�൥
function TWorkerBusinessBills.AllowedSanMultiBill: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SanMultiBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

function TWorkerBusinessBills.AllowedSaveHKRecord: Boolean;
var nStr: string;
begin
  Result := False;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_SaveHKRecord]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsString = sFlag_Yes;
  end;
end;

//Date: 2015-01-09
//Desc: ������������ָ��ʱ���ڱ��뿪��,������Ч
function TWorkerBusinessBills.GetInBillInterval: Integer;
var nStr: string;
begin
  Result := 0;
  nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_InAndBill]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    Result := Fields[0].AsInteger;
  end;
end;

//Date: 2014-09-15
//Desc: ��֤�ܷ񿪵�
function TWorkerBusinessBills.VerifyBeforSave(var nData: string): Boolean;
var nIdx,nInt: Integer;
    nStr,nTruck: string;
    nVal, nRenum: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  nTruck := FListA.Values['Truck'];
  if not VerifyTruckNO(nTruck, nData) then Exit;

  if FListA.Values['BuDan'] = sFlag_Yes then
       nInt := 0
  else nInt := GetInBillInterval;
  
  if nInt > 0 then
  begin
    nStr := 'Select %s as T_Now,T_LastTime,T_NoVerify,T_Valid From %s ' +
            'Where T_Truck=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_Truck, nTruck]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'û�г���[ %s ]�ĵ���,�޷�����.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nData := '����[ %s ]������Ա��ֹ����.';
        nData := Format(nData, [nTruck]);
        Exit;
      end;

      if FieldByName('T_NoVerify').AsString <> sFlag_Yes then
      begin
        nIdx := Trunc((FieldByName('T_Now').AsDateTime -
                       FieldByName('T_LastTime').AsDateTime) * 24 * 60);
        //�ϴλ������

        if nIdx >= nInt then
        begin
          nData := '����[ %s ]���ܲ���ͣ����,��ֹ����.';
          nData := Format(nData, [nTruck]);
          Exit;
        end;
      end;
    end;
  end;

  //----------------------------------------------------------------------------
  SetLength(FStockItems, 0);
  SetLength(FMatchItems, 0);
  //init

  FSaveHKRecord := AllowedSaveHKRecord;
  FSanMultiBill := AllowedSanMultiBill;
  //ɢװ�����൥

  nStr := 'Select M_ID,M_Group From %s Where M_Status=''%s'' ';
  nStr := Format(nStr, [sTable_StockMatch, sFlag_Yes]);
  //Ʒ�ַ���ƥ��

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FStockItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      FStockItems[nIdx].FStock := Fields[0].AsString;
      FStockItems[nIdx].FGroup := Fields[1].AsString;

      Inc(nIdx);
      Next;
    end;
  end;

  nStr := 'Select * From %s Where T_Truck=''%s'' ';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);
  //���ڶ����г���

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    SetLength(FMatchItems, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    begin
      if (FieldByName('T_Type').AsString = sFlag_San) and (not FSanMultiBill) then
      begin
        nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      //if (FieldByName('T_Type').AsString = sFlag_Dai) and //��װ��ɢװ����
      if (FListA.Values['InFact'] <> sFlag_Yes)  And  //�������Ĭ��Ϊ����״̬
         (FieldByName('T_InFact').AsString <> '') then
      begin
        nStr := '����[ %s ]��δ���[ %s ]������֮ǰ��ֹ����.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end else

      if FieldByName('T_Valid').AsString = sFlag_No then
      begin
        nStr := '����[ %s ]���ѳ��ӵĽ�����[ %s ],���ȴ���.';
        nData := Format(nStr, [nTruck, FieldByName('T_Bill').AsString]);
        Exit;
      end; 

      with FMatchItems[nIdx] do
      begin
        FStock := FieldByName('T_StockNo').AsString;
        FGroup := GetStockGroup(FStock);
        FRecord := FieldByName('R_ID').AsString;

        if Assigned(FindField('T_HKRecord')) then
              FHKRecord := FieldByName('T_HKRecord').AsString
        else  FHKRecord := '';
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //���泵�ƺ�
                        
  //----------------------------------------------------------------------------
  FListC.Text := PackerDecodeStr(FListA.Values['ZhiKa']);
  //����xs_card_base��Ϣ

  with gDBConnManager.WorkerQuery(FDBConn, nStr),FListA do
  begin
    Values['Record'] := FListC.Values['XCB_ID'];
    Values['Project'] := FListC.Values['XCB_CardId'];
    Values['Area'] := FListC.Values['pcb_name'];
    Values['CusID'] := FListC.Values['XCB_Client'];
    Values['CusName'] := FListC.Values['XCB_ClientName'];
    Values['CusPY'] := GetPinYinOfStr(FListC.Values['XCB_ClientName']);

    Values['TransID'] := FListC.Values['XCB_TransID'];
    Values['TransName'] := FListC.Values['XCB_TransName'];
    Values['WorkAddr'] := FListC.Values['XCB_WorkAddr'];
    Values['SaleID'] := FListC.Values['XCB_OperMan'];
    Values['SaleMan'] := '?';
    Values['ZKMoney'] := sFlag_No;
  end;

  nVal := 0;
  FListB.Text := PackerDecodeStr(FListA.Values['Bills']);

  for nIdx := 0 to FListB.Count - 1 do
  begin
    FListC.Text := PackerDecodeStr(FListB[nIdx]);
    nVal := nVal + StrToFloatDef(FListC.Values['Value'], 0);
  end;
  //��������������У�����κźͶ��������� 

  if not TWorkerBusinessCommander.CallMe(cBC_ReadYTCard,
     FListA.Values['Project'], '', @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end; //��ȡ����

  FListB.Text := PackerDecodeStr(nOut.FData);
  FListC.Text := PackerDecodeStr(FListB[0]);

  if FListC.Values['XCB_IsOnly'] = '1' then
  begin
    nStr := 'Select L_ID From %s Where L_Project=''%s''';
    nStr := Format(nStr, [sTable_Bill, FListC.Values['XCB_CardId']]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nStr := '����[ %s ]�ѿ��߽�����[ %s ],��ֹ�ظ�����.';
      nData := Format(nStr, [FListC.Values['XCB_CardId'],
               FieldByName('L_ID').AsString]);
      Exit;
    end;
  end;   
  //�ж�һ��һƱ�������ظ�����

  FListC.Values['Seal'] := FListA.Values['Seal'];
  FListC.Values['HYDan'] := FListA.Values['HYDan'];
  FListC.Values['Value'] := FloatToStr(nVal);
  //������Ϣ

  if not TWorkerBusinessCommander.CallMe(cBC_VerifyYTCard,
     PackerEncodeStr(FListC.Text), sFlag_LoadExtInfo, @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end; //��֤������Ч�ԺͿ�����

  FListB.Text := PackerDecodeStr(nOut.FData);
  nRenum := StrToFloatDef(FListB.Values['XCB_RemainNum'], 0);
  //����ʣ����

  if FloatRelation(nRenum, nVal, rtLess, cPrecision) then
  begin
    nData := '�ͻ�[ %s.%s ]������û���㹻����,��������:' + #13#10#13#10 +
             '��.�������: %s' + #13#10 +
             '��.��������: %.2f��' + #13#10 +
             '��.���ο���: %.2f��' + #13#10+#13#10 +
             '������ȷ�϶�����.';
    nData := Format(nData, [FListA.Values['CusID'], FListA.Values['CusName'],
             FListA.Values['Project'], nRenum, nVal]);
    Exit;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_GetYTBatchCode,
     PackerEncodeStr(FListC.Text), '', @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end; //��֤���κ���Ч�ԺͿ�����

  FListB.Text := PackerDecodeStr(nOut.FData);
  FListA.Values['Seal'] := FListB.Values['XCB_CementCodeID'];
  FListA.Values['HYDan'] := FListB.Values['XCB_CementCode'];

  Result := True;
  //verify done
end;

//Date: 2014-09-15
//Desc: ���潻����
function TWorkerBusinessBills.SaveBills(var nData: string): Boolean;
var nStr,nSQL,nHKID, nRID, nBill, nCode: string;
    nOut: TWorkerBusinessCommand;
    nIdx,nInt: Integer;
    nVal: Double;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if not VerifyBeforSave(nData) then Exit;

  FListB.Text := PackerDecodeStr(FListA.Values['Bills']);
  //unpack bill list

  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    for nIdx:=0 to FListB.Count - 1 do
    begin
      if FSaveHKRecord then
      begin
        nHKID := GetHKRecord;

        if nHKID='' then
        begin
          FListC.Clear;
          FListC.Values['Group'] :=sFlag_BusGroup;
          FListC.Values['Object'] := sFlag_HKRecord;
          //to get serial no

          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
                FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          //xxxxx

          nHKID := nOut.FData;
        end;
      end;
      //��ȡ�����еĺϿ���¼  

      FListC.Clear;
      FListC.Values['Group'] :=sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_BillNo;
      //to get serial no

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := FOut.FData + nOut.FData + ',';
      //combine bill
      FListC.Text := PackerDecodeStr(FListB[nIdx]);
      //get bill info

      nStr := MakeSQLByStr([SF('L_ID', nOut.FData),
              SF('L_ZhiKa', FListA.Values['Record']),
              SF('L_Project', FListA.Values['Project']),
              SF('L_Area', FListA.Values['Area']),
              SF('L_WorkAddr', FListA.Values['WorkAddr']),
              SF('L_CusID', FListA.Values['CusID']),
              SF('L_CusName', FListA.Values['CusName']),
              SF('L_CusPY', FListA.Values['CusPY']),
              SF('L_SaleID', FListA.Values['SaleID']),
              SF('L_SaleMan', FListA.Values['SaleMan']),
              SF('L_TransID', FListA.Values['TransID']),
              SF('L_TransName', FListA.Values['TransName']),

              SF('L_PrintFH', FListA.Values['PrintFH']),
              SF('L_PrintHGZ', FListA.Values['PrintHGZ']),

              SF('L_Type', FListC.Values['Type']),
              SF('L_LineGroup', FListA.Values['LineGroup']),
              SF('L_StockNo', FListC.Values['StockNO']),
              SF('L_StockName', FListC.Values['StockName']),
              SF('L_Value', FListC.Values['Value'], sfVal),
              SF('L_Price', FListC.Values['Price'], sfVal),

              SF('L_ZKMoney', sFlag_No),
              SF('L_Truck', FListA.Values['Truck']),
              SF('L_Status', sFlag_BillNew),
              SF('L_Lading', FListA.Values['Lading']),
              SF('L_IsVIP', FListA.Values['IsVIP']),
              SF('L_Seal', FListA.Values['Seal']),
              SF('L_HYDan', FListA.Values['HYDan']),
              SF('L_Memo', FListA.Values['Memo']),
              SF('L_Man', FIn.FBase.FFrom.FUser),
              SF('L_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Bill, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);

      if FListA.Values['BuDan'] = sFlag_Yes then //����
      begin
        nStr := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PValue', 0, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PMan', FIn.FBase.FFrom.FUser),
                SF('L_MValue', FListC.Values['Value'], sfVal),
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MMan', FIn.FBase.FFrom.FUser),
                SF('L_OutFact', sField_SQLServer_Now, sfVal),
                SF('L_OutMan', FIn.FBase.FFrom.FUser),
                SF('L_Card', '')
                ], sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end else
      begin
        if FListC.Values['Type'] = sFlag_San then
        begin
          nStr := '';
          //ɢװ����ϵ�
        end else
        begin
          nStr := FListC.Values['StockNO'];
          nStr := GetMatchRecord(nStr);
          //��Ʒ����װ�������еļ�¼��
        end;

        if nStr <> '' then
        begin
          nSQL := 'Update $TK Set T_Value=T_Value + $Val,' +
                  'T_HKBills=T_HKBills+''$BL.'' Where R_ID=$RD';
          nSQL := MacroValue(nSQL, [MI('$TK', sTable_ZTTrucks),
                  MI('$RD', nStr), MI('$Val', FListC.Values['Value']),
                  MI('$BL', nOut.FData)]);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end else
        begin
          nSQL := MakeSQLByStr([
            SF('T_Truck'   , FListA.Values['Truck']),
            SF('T_StockNo' , FListC.Values['StockNO']),
            SF('T_Stock'   , FListC.Values['StockName']),
            SF('T_Type'    , FListC.Values['Type']),
            SF('T_InTime'  , sField_SQLServer_Now, sfVal),
            SF('T_Bill'    , nOut.FData),
            SF('T_Valid'   , sFlag_Yes),
            SF('T_Value'   , FListC.Values['Value'], sfVal),
            SF('T_LineGroup', FListA.Values['LineGroup']),
            SF('T_VIP'     , FListA.Values['IsVIP']),
            SF('T_HKBills' , nOut.FData + '.')
            ], sTable_ZTTrucks, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);

          nStr := 'Select Max(R_ID) From ' + sTable_ZTTrucks;
          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            nStr := Fields[0].AsString;
          //�����¼��

          nInt := Length(FMatchItems);
          SetLength(FMatchItems, nInt + 1);
          with FMatchItems[nInt] do
          begin
            FStock := FListC.Values['StockNO'];
            FGroup := GetStockGroup(FStock);
            FRecord := nStr;
            FHKRecord:= nHKID;
          end;
        end;
      end;

      if FSaveHKRecord then
      begin
        nSQL := MakeSQLByStr([SF('L_HKRecord', nHKID)],
            sTable_Bill, SF('L_ID', nOut.FData), False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);

        nSQL := 'Update %s Set T_HKRecord=''%s'' Where T_HKBills Like ''%%%s%%''';
        nSQL := Format(nSQL, [sTable_ZTTrucks, nHKID, nOut.FData]);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;
      //���ºϿ���¼

      if FListA.Values['InFact'] = sFlag_Yes then
      begin
        FListA.Values['Status'] := sFlag_TruckIn;
        FListA.Values['NextStatus'] := sFlag_TruckBFP;

        if FListC.Values['Type'] = sFlag_Dai then
        begin
          nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
          nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
           if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
            FListA.Values['NextStatus'] := sFlag_TruckZT;
          //��װ������
        end;

        nStr := SF('L_ID', nOut.FData);
        nSQL := MakeSQLByStr([
                SF('L_Status', FListA.Values['Status']),
                SF('L_NextStatus', FListA.Values['NextStatus']),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_InMan', FIn.FBase.FFrom.FUser)
                ], sTable_Bill, nStr, False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);

        nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
        nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
                nOut.FData]);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
        //���¶��г�������״̬
      end;  

      if FListA.Values['BuDan'] = sFlag_Yes then //����
      begin
        if FListA.Values['Seal'] <> '' then
        begin
          nStr := 'Update %s Set C_HasDone=C_HasDone+%.2f Where C_ID=''%s''';
          nStr := Format(nStr, [sTable_YT_CodeInfo,
                  StrToFloat(FListC.Values['Value']),
                  FListA.Values['Seal']]);
          nInt := gDBConnManager.WorkerExec(FDBConn, nStr);

          if nInt < 1 then
          begin
            nSQL := MakeSQLByStr([
              SF('C_ID', FListA.Values['Seal']),
              SF('C_Code', FListA.Values['HYDan']),
              SF('C_Stock', FListC.Values['StockNO']),
              SF('C_Freeze', '0', sfVal),
              SF('C_HasDone', FListC.Values['Value'], sfVal)
              ], sTable_YT_CodeInfo, '', True);
            gDBConnManager.WorkerExec(FDBConn, nSQL);
          end;
        end; //����ˮ���ŷ�����
      end else
      begin
        if FListA.Values['Seal'] <> '' then
        begin
          nStr := 'Update %s Set C_Freeze=C_Freeze+%.2f Where C_ID=''%s''';
          nStr := Format(nStr, [sTable_YT_CodeInfo,
                  StrToFloat(FListC.Values['Value']),
                  FListA.Values['Seal']]);
          nInt := gDBConnManager.WorkerExec(FDBConn, nStr);

          if nInt < 1 then
          begin
            nSQL := MakeSQLByStr([
              SF('C_ID', FListA.Values['Seal']),
              SF('C_Code', FListA.Values['HYDan']),
              SF('C_Stock', FListC.Values['StockNO']),
              SF('C_Freeze', FListC.Values['Value'], sfVal),
              SF('C_HasDone', '0', sfVal)
              ], sTable_YT_CodeInfo, '', True);
            gDBConnManager.WorkerExec(FDBConn, nSQL);
          end;
        end; //����ˮ���Ŷ�����
      end;
    end;

    nIdx := Length(FOut.FData);
    if Copy(FOut.FData, nIdx, 1) = ',' then
      System.Delete(FOut.FData, nIdx, 1);
    //xxxxx
    
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  //����΢����Ϣ
  FDBConn.FConn.BeginTrans;
  try
    SendMsgToWebMall(nOut.FData,cSendWeChatMsgType_AddBill);
    FDBConn.FConn.CommitTrans;
  except
     FDBConn.FConn.RollbackTrans;
    raise;
  end;

  try
    nSQL := AdjustListStrFormat(FOut.FData, '''', True, ',', False);
    //bill list

    if not TWorkerBusinessCommander.CallMe(cBC_SyncBillEdit, nSQL,
      sFlag_BillNew, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx
  except
    FListB.Clear;
    FListC.Clear;
    FListD.Clear;
    //init SQL List

    nVal := 0;
    SplitStr(FOut.FData, FListB, 0, ',', False);
    
    for nIdx := 0 to FListB.Count-1 do
    begin
      nStr := 'Select L_Value,L_Seal From %s ' +
              'Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, FListB[nIdx]]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then Continue;

        nVal := FieldByName('L_Value').AsFloat;
        nCode := FieldByName('L_Seal').AsString;
      end;

      nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
              'Where T_HKBills Like ''%%%s%%''';
      nStr := Format(nStr, [sTable_ZTTrucks, FListB[nIdx]]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
      begin
        nRID := Fields[0].AsString;
        nBill := Fields[2].AsString;
        SplitStr(Fields[1].AsString, FListD, 0, '.')
      end else
      begin
        nRID := '';
        FListD.Clear;
      end;

      if FListD.Count = 1 then
      begin
        nStr := 'Delete From %s Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, nRID]);

        FListC.Add(nStr);
      end else

      if FListD.Count > 1 then
      begin
        nInt := FListD.IndexOf(FListB[nIdx]);
        if nInt >= 0 then
          FListD.Delete(nInt);
        //�Ƴ��ϵ��б�

        if nBill = FListB[nIdx] then
          nBill := FListD[0];
        //����������

        nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
                'T_HKBills=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
                CombinStr(FListD, '.'), nRID]);
        //xxxxx

        FListC.Add(nStr);
        //���ºϵ���Ϣ
      end;

      if nCode <> '' then
      begin
        nStr := 'Update %s Set C_Freeze=C_Freeze-(%.2f) Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCode]);
        FListC.Add(nStr);
      end;

      nStr := 'Delete From %s Where L_ID=''%s''';
      nStr := Format(nStr, [sTable_Bill, FListB[nIdx]]);
      FListC.Add(nStr);
    end;

    FDBConn.FConn.BeginTrans;
    try
      for nIdx := 0 to FListC.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);

      FDBConn.FConn.CommitTrans;
    except
      FDBConn.FConn.RollbackTrans;
      raise;
    end;
    raise;
  end;
  //ͬ�������

  if FListA.Values['BuDan'] = sFlag_Yes then //����
  try
    nSQL := AdjustListStrFormat(FOut.FData, '''', True, ',', False);
    //bill list

    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill, nSQL, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx
  except
    nStr := 'Delete From %s Where L_ID In (%s)';
    nStr := Format(nStr, [sTable_Bill, nSQL]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    raise;
  end;

  {$IFDEF MicroMsg}
  with FListC do
  begin
    Clear;
    Values['bill'] := FOut.FData;
    Values['company'] := gSysParam.FHintText;
  end;

  if FListA.Values['BuDan'] = sFlag_Yes then
       nStr := cWXBus_OutFact
  else nStr := cWXBus_MakeCard;

  gWXPlatFormHelper.WXSendMsg(nStr, FListC.Text);
  {$ENDIF}
end;

//------------------------------------------------------------------------------
//Date: 2014-09-16
//Parm: ������[FIn.FData];���ƺ�[FIn.FExtParam]
//Desc: �޸�ָ���������ĳ��ƺ�
function TWorkerBusinessBills.ChangeBillTruck(var nData: string): Boolean;
var nIdx: Integer;
    nStr,nTruck: string;
begin
  Result := False;
  if not VerifyTruckNO(FIn.FExtParam, nData) then Exit;

  nStr := 'Select L_Truck,L_InTime From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <> 1 then
    begin
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    if Fields[1].AsString <> '' then
    begin
      nData := '������[ %s ]�����,�޷��޸ĳ��ƺ�.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;


    nTruck := Fields[0].AsString;
  end;

  nStr := 'Select R_ID,T_HKBills From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_ZTTrucks, nTruck]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    FListA.Clear;
    FListB.Clear;
    First;

    while not Eof do
    begin
      SplitStr(Fields[1].AsString, FListC, 0, '.');
      FListA.AddStrings(FListC);
      FListB.Add(Fields[0].AsString);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�����޸���Ϣ

    if (FListA.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListA.Count - 1 downto 0 do
      if CompareText(FIn.FData, FListA[nIdx]) <> 0 then
      begin
        nStr := 'Update %s Set L_Truck=''%s'' Where L_ID=''%s''';
        nStr := Format(nStr, [sTable_Bill, FIn.FExtParam, FListA[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�
      end;
    end;

    if (FListB.Count > 0) and (CompareText(nTruck, FIn.FExtParam) <> 0) then
    begin
      for nIdx:=FListB.Count - 1 downto 0 do
      begin
        nStr := 'Update %s Set T_Truck=''%s'' Where R_ID=%s';
        nStr := Format(nStr, [sTable_ZTTrucks, FIn.FExtParam, FListB[nIdx]]);

        gDBConnManager.WorkerExec(FDBConn, nStr);
        //ͬ���ϵ����ƺ�
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-30
//Parm: ��������[FIn.FData];��ֽ��[FIn.FExtParam]
//Desc: ����������������ֽ���Ŀͻ�
function TWorkerBusinessBills.BillSaleAdjust(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal,nMon: Double;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  //init

  //----------------------------------------------------------------------------
  nStr := 'Select L_CusID,L_StockNo,L_StockName,L_Value,L_Price,L_ZhiKa,' +
          'L_ZKMoney,L_OutFact From %s Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('������[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    if FieldByName('L_OutFact').AsString = '' then
    begin
      nData := '����������(������)���ܵ���.';
      Exit;
    end;

    FListB.Clear;
    with FListB do
    begin
      Values['CusID'] := FieldByName('L_CusID').AsString;
      Values['StockNo'] := FieldByName('L_StockNo').AsString;
      Values['StockName'] := FieldByName('L_StockName').AsString;
      Values['ZhiKa'] := FieldByName('L_ZhiKa').AsString;
      Values['ZKMoney'] := FieldByName('L_ZKMoney').AsString;
    end;
    
    nVal := FieldByName('L_Value').AsFloat;
    nMon := nVal * FieldByName('L_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select zk.*,ht.C_Area,cus.C_Name,cus.C_PY,sm.S_Name From $ZK zk ' +
          ' Left Join $HT ht On ht.C_ID=zk.Z_CID ' +
          ' Left Join $Cus cus On cus.C_ID=zk.Z_Customer ' +
          ' Left Join $SM sm On sm.S_ID=Z_SaleMan ' +
          'Where Z_ID=''$ZID''';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa),
          MI('$HT', sTable_SaleContract),
          MI('$Cus', sTable_Customer),
          MI('$SM', sTable_Salesman),
          MI('$ZID', FIn.FExtParam)]);
  //ֽ����Ϣ

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('ֽ��[ %s ]�Ѷ�ʧ.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_Freeze').AsString = sFlag_Yes then
    begin
      nData := Format('ֽ��[ %s ]�ѱ�����Ա����.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_InValid').AsString = sFlag_Yes then
    begin
      nData := Format('ֽ��[ %s ]�ѱ�����Ա����.', [FIn.FExtParam]);
      Exit;
    end;

    if FieldByName('Z_ValidDays').AsDateTime <= Date() then
    begin
      nData := Format('ֽ��[ %s ]����[ %s ]����.', [FIn.FExtParam,
               Date2Str(FieldByName('Z_ValidDays').AsDateTime)]);
      Exit;
    end;

    FListA.Clear;
    with FListA do
    begin
      Values['Project'] := FieldByName('Z_Project').AsString;
      Values['Area'] := FieldByName('C_Area').AsString;
      Values['CusID'] := FieldByName('Z_Customer').AsString;
      Values['CusName'] := FieldByName('C_Name').AsString;
      Values['CusPY'] := FieldByName('C_PY').AsString;
      Values['SaleID'] := FieldByName('Z_SaleMan').AsString;
      Values['SaleMan'] := FieldByName('S_Name').AsString;
      Values['ZKMoney'] := FieldByName('Z_OnlyMoney').AsString;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := 'Select D_Price From %s Where D_ZID=''%s'' And D_StockNo=''%s''';
  nStr := Format(nStr, [sTable_ZhiKaDtl, FIn.FExtParam, FListB.Values['StockNo']]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := 'ֽ��[ %s ]��û������Ϊ[ %s ]��Ʒ��.';
      nData := Format(nData, [FIn.FExtParam, FListB.Values['StockName']]);
      Exit;
    end;

    FListC.Clear;
    nStr := 'Update %s Set A_OutMoney=A_OutMoney-(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListB.Values['CusID']]);
    FListC.Add(nStr); //��ԭ���������

    if FListB.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) ' +
              'Where Z_ID=''%s'' And Z_OnlyMoney=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon,
              FListB.Values['ZhiKa'], sFlag_Yes]);
      FListC.Add(nStr); //��ԭ�����������
    end;

    nMon := nVal * FieldByName('D_Price').AsFloat;
    nMon := Float2Float(nMon, cPrecision, True);

    if not TWorkerBusinessCommander.CallMe(cBC_GetZhiKaMoney,
            FIn.FExtParam, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    if FloatRelation(nMon, StrToFloat(nOut.FData), rtGreater, cPrecision) then
    begin
      nData := '�ͻ�[ %s.%s ]����,��������:' + #13#10#13#10 +
               '��.�������: %.2fԪ' + #13#10 +
               '��.��������: %.2fԪ' + #13#10 +
               '��.�� �� ��: %.2fԪ' + #13#10#13#10 +
               '�뵽�����Ұ���"��������"����,Ȼ���ٴε���.';
      nData := Format(nData, [FListA.Values['CusID'], FListA.Values['CusName'],
               StrToFloat(nOut.FData), nMon,
               Float2Float(nMon - StrToFloat(nOut.FData), cPrecision, True)]);
      Exit;
    end;

    nStr := 'Update %s Set A_OutMoney=A_OutMoney+(%.2f) Where A_CID=''%s''';
    nStr := Format(nStr, [sTable_CusAccount, nMon, FListA.Values['CusID']]);
    FListC.Add(nStr); //���ӵ���������

    if FListA.Values['ZKMoney'] = sFlag_Yes then
    begin
      nStr := 'Update %s Set Z_FixedMoney=Z_FixedMoney+(%.2f) Where Z_ID=''%s''';
      nStr := Format(nStr, [sTable_ZhiKa, nMon, FIn.FExtParam]);
      FListC.Add(nStr); //�ۼ�������������
    end;

    nStr := MakeSQLByStr([SF('L_ZhiKa', FIn.FExtParam),
            SF('L_Project', FListA.Values['Project']),
            SF('L_Area', FListA.Values['Area']),
            SF('L_CusID', FListA.Values['CusID']),
            SF('L_CusName', FListA.Values['CusName']),
            SF('L_CusPY', FListA.Values['CusPY']),
            SF('L_SaleID', FListA.Values['SaleID']),
            SF('L_SaleMan', FListA.Values['SaleMan']),
            SF('L_Price', FieldByName('D_Price').AsFloat, sfVal),
            SF('L_ZKMoney', FListA.Values['ZKMoney'])
            ], sTable_Bill, SF('L_ID', FIn.FData), False);
    FListC.Add(nStr); //���ӵ���������
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListC.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-16
//Parm: ��������[FIn.FData]
//Desc: ɾ��ָ��������
function TWorkerBusinessBills.DeleteBill(var nData: string): Boolean;
var nIdx: Integer;
    nVal: Double;
    nHasOut: Boolean;
    nOut: TWorkerBusinessCommand;
    nStr,nP,nRID,nBill,nZK,nCode: string;
begin
  Result := False;
  //init

  nStr := 'Select L_ZhiKa,L_Project,L_Value,L_OutFact,L_Seal From %s ' +
          'Where L_ID=''%s''';
  nStr := Format(nStr, [sTable_Bill, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '������[ %s ]����Ч.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nZK  := FieldByName('L_ZhiKa').AsString;
    nVal := FieldByName('L_Value').AsFloat;
    nCode := FieldByName('L_Seal').AsString;
    nHasOut := FieldByName('L_OutFact').AsString <> '';
  end;

  nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
          'Where T_HKBills Like ''%%%s%%''';
  nStr := Format(nStr, [sTable_ZTTrucks, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    if RecordCount <> 1 then
    begin
      nData := '������[ %s ]�����ڶ�����¼��,�쳣��ֹ!';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nRID := Fields[0].AsString;
    nBill := Fields[2].AsString;
    SplitStr(Fields[1].AsString, FListA, 0, '.')
  end else
  begin
    nRID := '';
    FListA.Clear;
  end;

  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //bill list

  if not TWorkerBusinessCommander.CallMe(cBC_SyncBillEdit, nStr,
    sFlag_BillDel, @nOut) then
    raise Exception.Create(nOut.FData);
  //xxxxx
  //ͬ�������

  FDBConn.FConn.BeginTrans;
  try
    if FListA.Count = 1 then
    begin
      nStr := 'Delete From %s Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nRID]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else

    if FListA.Count > 1 then
    begin
      nIdx := FListA.IndexOf(FIn.FData);
      if nIdx >= 0 then
        FListA.Delete(nIdx);
      //�Ƴ��ϵ��б�

      if nBill = FIn.FData then
        nBill := FListA[0];
      //����������

      nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
              'T_HKBills=''%s'' Where R_ID=%s';
      nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
              CombinStr(FListA, '.'), nRID]);
      //xxxxx

      gDBConnManager.WorkerExec(FDBConn, nStr);
      //���ºϵ���Ϣ
    end;

    if nHasOut then //�ͷ����
    begin
      if nCode <> '' then
      begin
        nStr := 'Update %s Set C_HasDone=C_HasDone-(%.2f) Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCode]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end else //�ͷŶ���
    begin
      if nCode <> '' then
      begin
        nStr := 'Update %s Set C_Freeze=C_Freeze-(%.2f) Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCode]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
      end;
    end;

    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Bill]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('L_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $BB($FL,L_DelMan,L_DelDate) ' +
            'Select $FL,''$User'',$Now From $BI Where L_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$BB', sTable_BillBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$BI', sTable_Bill), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    
    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: ������[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�������󶨴ſ�
function TWorkerBusinessBills.SaveBillCard(var nData: string): Boolean;
var nStr,nSQL,nTruck,nType: string;
begin  
  nType := '';
  nTruck := '';
  Result := False;

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�������б�

  nSQL := 'Select L_ID,L_Card,L_Type,L_Truck,L_OutFact From %s ' +
          'Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('������[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      if FieldByName('L_OutFact').AsString <> '' then
      begin
        nData := '������[ %s ]�ѳ���,��ֹ�쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '������[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [FieldByName('L_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('L_Type').AsString;
      if (nType <> '') and ((nStr <> nType) or (nStr = sFlag_San)) then
      begin
        if nStr = sFlag_San then
             nData := '������[ %s ]ͬΪɢװ,���ܲ���.'
        else nData := '������[ %s ]��ˮ�����Ͳ�һ��,���ܲ���.';
          
        nData := Format(nData, [FieldByName('L_ID').AsString]);
        Exit;
      end;

      if nType = '' then
        nType := nStr;
      //xxxxx

      nStr := FieldByName('L_Card').AsString;
      //����ʹ�õĴſ�
        
      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  SplitStr(FIn.FData, FListA, 0, ',');
  //�������б�
  nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
  //�ſ��б�

  nSQL := 'Select L_ID,L_Type,L_Truck From %s Where L_Card In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      nStr := FieldByName('L_Type').AsString;
      if (nStr <> sFlag_Dai) or ((nType <> '') and (nStr <> nType)) then
      begin
        nData := '����[ %s ]����ʹ�øÿ�,�޷�����.';
        nData := Format(nData, [FieldByName('L_Truck').AsString]);
        Exit;
      end;

      nStr := FieldByName('L_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '����[ %s ]����ʹ�øÿ�,��ͬ�ƺŲ��ܲ���.';
        nData := Format(nData, [nStr]);
        Exit;
      end;

      nStr := FieldByName('L_ID').AsString;
      if FListA.IndexOf(nStr) < 0 then
        FListA.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nSQL := 'Select T_HKBills From %s Where T_Truck=''%s'' ';
  nSQL := Format(nSQL, [sTable_ZTTrucks, nTruck]);

  //���ڶ����г���
  nStr := '';
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    try
      nStr := nStr + Fields[0].AsString;
    finally
      Next;
    end;

    nStr := Copy(nStr, 1, Length(nStr)-1);
    nStr := StringReplace(nStr, '.', ',', [rfReplaceAll]);
  end; 

  nStr := AdjustListStrFormat(nStr, '''', True, ',', False);
  //�����н������б�

  nSQL := 'Select L_Card From %s Where L_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Bill, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  if RecordCount > 0 then
  begin
    First;

    while not Eof do
    begin
      if (Fields[0].AsString <> '') and
         (Fields[0].AsString <> FIn.FExtParam) then
      begin
        nData := '����[ %s ]�Ĵſ��Ų�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.�����ſ�: [%s]' + #13#10 +
                 '*.�����ſ�: [%s]' + #13#10#13#10 +
                 '��ͬ�ſ��Ų��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [nTruck, FIn.FExtParam, Fields[0].AsString]);
        Exit;
      end;

      Next;
    end;  
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nStr := AdjustListStrFormat2(FListA, '''', True, ',', False);
      //���¼����б�

      nSQL := 'Update %s Set L_Card=''%s'' Where L_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Bill, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Sale),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nStr, False);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData]
//Desc: ע���ſ�
function TWorkerBusinessBills.LogoffCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set L_Card=Null Where L_Card=''%s''';
    nStr := Format(nStr, [sTable_Bill, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, sFlag_CardInvalid, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ſ���[FIn.FData];��λ[FIn.FExtParam]
//Desc: ��ȡ�ض���λ����Ҫ�Ľ������б�
function TWorkerBusinessBills.GetPostBillItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsBill: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsBill := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_BillNo]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsBill := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //ǰ׺�ͳ��ȶ����㽻�����������,����Ϊ��������
  end;

  if not nIsBill then
  begin
    nStr := 'Select C_Status,C_Freeze From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FData]);
    //card status

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := Format('�ſ�[ %s ]��Ϣ�Ѷ�ʧ.', [FIn.FData]);
        Exit;
      end;

      if Fields[0].AsString <> sFlag_CardUsed then
      begin
        nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷����.';
        nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
        Exit;
      end;

      if Fields[1].AsString = sFlag_Yes then
      begin
        nData := '�ſ�[ %s ]�ѱ�����,�޷����.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;
    end;
  end;

  nStr := 'Select L_ID,L_ZhiKa,L_Project,L_CusID,L_CusName,L_Type,L_StockNo,' +
          'L_StockName,L_Truck,L_Value,L_Price,L_ZKMoney,L_Status,L_NextStatus,' +
          'L_Card,L_IsVIP,L_PValue,L_MValue,L_Seal,L_LineGroup,L_HYDan,L_HKRecord '+
          'From $Bill b ';
  //xxxxx

  if nIsBill then
       nStr := nStr + 'Where L_ID=''$CD'''
  else nStr := nStr + 'Where L_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$Bill', sTable_Bill), MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsBill then
           nData := '������[ %s ]����Ч.'
      else nData := '�ſ���[ %s ]û�н�����.';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, RecordCount);
    nIdx := 0;
    First;

    while not Eof do
    with nBills[nIdx] do
    begin
      FID         := FieldByName('L_ID').AsString;
      FZhiKa      := FieldByName('L_ZhiKa').AsString;
      FProject    := FieldByName('L_Project').AsString;
      FCusID      := FieldByName('L_CusID').AsString;
      FCusName    := FieldByName('L_CusName').AsString;
      FTruck      := FieldByName('L_Truck').AsString;
      FLineGroup  := FieldByName('L_LineGroup').AsString;

      FType       := FieldByName('L_Type').AsString;
      FStockNo    := FieldByName('L_StockNo').AsString;
      FStockName  := FieldByName('L_StockName').AsString;
      FValue      := FieldByName('L_Value').AsFloat;
      FPrice      := FieldByName('L_Price').AsFloat;

      FSeal       := FieldByName('L_Seal').AsString;
      FHYDan      := FieldByName('L_HYDan').AsString;

      FCard       := FieldByName('L_Card').AsString;
      FIsVIP      := FieldByName('L_IsVIP').AsString;
      FStatus     := FieldByName('L_Status').AsString; 
      FHKRecord   := FieldByName('L_HKRecord').AsString;
      FNextStatus := FieldByName('L_NextStatus').AsString;

      if FIsVIP = sFlag_TypeShip then
      begin
        FStatus    := sFlag_TruckZT;
        FNextStatus := sFlag_TruckOut;
      end;

      if FStatus = sFlag_BillNew then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;

      FPData.FValue := FieldByName('L_PValue').AsFloat;
      FMData.FValue := FieldByName('L_MValue').AsFloat;
      FSelected := True;

      Inc(nIdx);
      Next;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessBills.SavePostBillItems(var nData: string): Boolean;
var nStr,nSQL,nTmp,nCode,nRID,nBill: string;
    nUpdateID, nAddID: string;
    f,m,nVal,nMVal: Double;
    i,nIdx,nInt: Integer;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nBills);
  nInt := Length(nBills);

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if (nBills[0].FType = sFlag_San) and (nInt > 1) and
     (FIn.FExtParam <> sFlag_TruckOut) then
  begin
    nData := '��λ[ %s ]�ύ��ɢװ�ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    with nBills[0] do
    begin
      FStatus := sFlag_TruckIn;
      FNextStatus := sFlag_TruckBFP;
    end;

    if nBills[0].FType = sFlag_Dai then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_PoundIfDai]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
       if (RecordCount > 0) and (Fields[0].AsString = sFlag_No) then
        nBills[0].FNextStatus := sFlag_TruckZT;
      //��װ������
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nStr := SF('L_ID', nBills[nIdx].FID);
      nSQL := MakeSQLByStr([
              SF('L_Status', nBills[0].FStatus),
              SF('L_NextStatus', nBills[0].FNextStatus),
              SF('L_InTime', sField_SQLServer_Now, sfVal),
              SF('L_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InFact=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now,
              nBills[nIdx].FID]);
      FListA.Add(nSQL);
      //���¶��г�������״̬
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFP then //����Ƥ��
  begin
    FListB.Clear;
    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_NFStock]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      First;
      while not Eof do
      begin
        FListB.Add(Fields[0].AsString);
        Next;
      end;
    end;

    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '��λ[ %s ]�ύ��Ƥ������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    //--------------------------------------------------------------------------
    FListC.Clear;
    FListC.Values['Field'] := 'T_PValue';
    FListC.Values['Truck'] := nBills[nInt].FTruck;
    FListC.Values['Value'] := FloatToStr(nBills[nInt].FPData.FValue);

    if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
          FListC.Text, '', @nOut) then
      raise Exception.Create(nOut.FData);
    //���泵����ЧƤ��

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckBFP;
      if FType = sFlag_Dai then
           FNextStatus := sFlag_TruckZT
      else FNextStatus := sFlag_TruckFH;

      if FListB.IndexOf(FStockNo) >= 0 then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���

      nSQL := MakeSQLByStr([
              SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FOut.FData := nOut.FData;
      //���ذ񵥺�,�������հ�

      nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', FID),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FValue),
              SF('P_KZValue', 0, sfVal),
              SF('P_PValue', nBills[nInt].FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', nBills[nInt].FFactory),
              SF('P_PStation', nBills[nInt].FPData.FStation),
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckZT then //ջ̨�ֳ�
  begin
    nInt := -1;
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPData.FValue > 0 then
    begin
      nInt := nIdx;
      Break;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FStatus := sFlag_TruckZT;
      if nInt >= 0 then //�ѳ�Ƥ
           FNextStatus := sFlag_TruckBFM
      else FNextStatus := sFlag_TruckOut;

      if FYSValid = sFlag_Yes then
           nStr := sFlag_Yes
      else nStr := sFlag_No;

      nSQL := MakeSQLByStr([SF('L_Status', FStatus),
              SF('L_NextStatus', FNextStatus),
              SF('L_IsEmpty', nStr),

              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //���¶��г������״̬
    end;
  end else

  if FIn.FExtParam = sFlag_TruckFH then //�Ż��ֳ�
  begin
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if FYSValid = sFlag_Yes then
           nStr := sFlag_Yes
      else nStr := sFlag_No;

      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckFH),
              SF('L_NextStatus', sFlag_TruckBFM),
              SF('L_IsEmpty', nStr),

              SF('L_LadeTime', sField_SQLServer_Now, sfVal),
              SF('L_LadeMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := 'Update %s Set T_InLade=%s Where T_HKBills Like ''%%%s%%''';
      nSQL := Format(nSQL, [sTable_ZTTrucks, sField_SQLServer_Now, FID]);
      FListA.Add(nSQL);
      //���¶��г������״̬
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    nInt := -1;
    nMVal := 0;

    nAddID := '';
    nUpdateID := '';
    
    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FPoundID = sFlag_Yes then
    begin
      nMVal := nBills[nIdx].FMData.FValue;
      nInt := nIdx;
      Break;
    end;

    if nInt < 0 then
    begin
      nData := '��λ[ %s ]�ύ��ë������Ϊ0.';
      nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
      Exit;
    end;

    with nBills[nInt] do
    if FType = sFlag_San then //ɢװ��У���Ƿ񷢳�
    begin
      nVal := FValue;
      //������
      FValue :=Float2Float(nMVal - FPData.FValue, cPrecision, True) ;
      //�¾���,ʵ�������

      if (FKZValue <= 0) or (nBills[nInt].FPModel = sFlag_PoundCC) then
      begin
        f := FValue - nVal;
        //ԭ��Ʊ��������

        nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal)
              ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //���������

        nUpdateID := FID + ',' + nUpdateID;
        //����ϵͳ���¶�����

        if FSeal <> '' then
        begin
          nSQL := 'Update %s Set C_Freeze=C_Freeze+(%.2f) ' +
                  'Where C_ID=''%s''';
          nSQL := Format(nSQL, [sTable_YT_CodeInfo, f, FSeal]);
          FListA.Add(nSQL); //ˮ����
        end;
      end else //������
      begin
        FValue := FValue - FKZValue;
        //ԭ�������ɷ���
        f := FValue - nVal;
        //ԭ��Ʊ��������

        nStr := '����ʱ��ϸ��Ϣ��' + #13#10 +
                '��.Ƥ��:[%f] ' + #13#10 +
                '��.ë��:[%f] ' + #13#10 +
                '��.ԭ����:[%s]=>�����:[%f] ' + #13#10 +
                '��.ʵ�ʾ���:[%f] ' + #13#10 +
                '��.������:[%f]';
        nStr := Format(nStr, [FPData.FValue, FMData.FValue,FID,FValue,
                FValue +FKZValue, FKZValue]);
        WriteLog(nStr);

        nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal)
              ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //���������

        nUpdateID := FID + ',' + nUpdateID;
        //����ϵͳ���¶�����

        if FSeal <> '' then
        begin
          nSQL := 'Update %s Set C_Freeze=C_Freeze+(%.2f) ' +
                  'Where C_ID=''%s''';
          nSQL := Format(nSQL, [sTable_YT_CodeInfo, f, FSeal]);
          FListA.Add(nSQL); //������
        end;

        if not TWorkerBusinessCommander.CallMe(cBC_ReadYTCard, FMemo, '',
           @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end; //��ȡ����

        FListB.Text := PackerDecodeStr(nOut.FData);
        FListC.Text := PackerDecodeStr(FListB[0]);
        //������Ϣ

        if FCusID <> FListC.Values['XCB_Client'] then
        begin
          nData := '�ͻ���Ϣ��һ��,��������:' + #13#10#13#10 +
                   '��.����ͻ�: %s' + #13#10 +
                   '��.�ϵ��ͻ�: %s' + #13#10#13#10 +
                   '��ȷ����������Ƿ���ȷ.';
          nData := Format(nData, [FCusName, FListC.Values['XCB_ClientName']]);
          Exit;
        end;

        if FStockNo <> FListC.Values['XCB_Cement'] then
        begin
          nData := 'ˮ��Ʒ����Ϣ��һ��,��������:' + #13#10#13#10 +
                   '��.���Ʒ��: %s' + #13#10 +
                   '��.�ϵ�Ʒ��: %s' + #13#10#13#10 +
                   '��ȷ����������Ƿ���ȷ.';
          nData := Format(nData, [FStockName, FListC.Values['XCB_CementName']]);
          Exit;
        end;

        if not TWorkerBusinessCommander.CallMe(cBC_VerifyYTCard, FListB[0],
           sFlag_LoadExtInfo, @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end; //��֤������Ч�ԺͿ�����

        FListB.Text := PackerDecodeStr(nOut.FData);
        nVal := StrToFloat(FListB.Values['XCB_RemainNum']);
        //����ʣ����

        m := Float2Float(FKZValue - nVal, cPrecision, False);
        //�������Ƿ���

        if m > 0 then
        begin
          nData := '�ͻ�[ %s.%s ]������û���㹻����,��������:' + #13#10#13#10 +
                   '��.�������: %s' + #13#10 +
                   '��.��������: %.2f��' + #13#10 +
                   '��.����ȱ��: %.2f��' + #13#10+#13#10 +
                   '�뵽�����Ұ���������,Ȼ���ٴγ���.';
          nData := Format(nData, [FCusID, FCusName, FMemo, nVal, m]);
          Exit;
        end;

        if not TWorkerBusinessCommander.CallMe(cBC_GetYTBatchCode,
           PackerEncodeStr(FListB.Text), '', @nOut) then
        begin
          nData := nOut.FData;
          Exit;
        end; //��֤���κ���Ч�ԺͿ����� 
        FListB.Text := PackerDecodeStr(nOut.FData);
        
        //----------------------------------------------------------------------
        FListC.Values['Group'] :=sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_BillNo;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
              FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        nTmp := nOut.FData;
        //Save L_ID

        nAddID := nTmp + ',' + nAddID;
        //����ϵͳ�������

        nSQL := MakeSQLByStr([SF('L_ID', nTmp),
                SF('L_Card', FCard),
                SF('L_ZhiKa', FListB.Values['XCB_ID']),
                SF('L_Project', FListB.Values['XCB_CardId']),
                SF('L_Area', FListB.Values['pcb_name']),
                SF('L_CusID', FListB.Values['XCB_Client']),
                SF('L_CusName', FListB.Values['XCB_ClientName']),
                SF('L_CusPY', GetPinYinOfStr(FListB.Values['XCB_ClientName'])),

                SF('L_Type', FType),
                SF('L_StockNo', FListB.Values['XCB_Cement']),
                SF('L_StockName', FListB.Values['XCB_CementName']),
                SF('L_Value', FKZValue, sfVal),                                 //������
                SF('L_Price', '0', sfVal),
                SF('L_LineGroup', FLineGroup),

                SF('L_ZKMoney', sFlag_No),
                SF('L_Truck', FTruck),
                SF('L_HKRecord', FHKRecord),
                SF('L_Status', sFlag_TruckBFM),
                SF('L_NextStatus', sFlag_TruckOut),
                SF('L_InTime', sField_SQLServer_Now, sfVal),
                SF('L_PDate', sField_SQLServer_Now, sfVal),
                SF('L_PValue', FPData.FValue, sfVal),                           //ԭʼƤ��
                SF('L_MDate', sField_SQLServer_Now, sfVal),
                SF('L_MValue', FPData.FValue + FKZValue, sfVal),                //Ƥ��+������
                SF('L_LadeTime', sField_SQLServer_Now, sfVal),
                                    
                SF('L_Lading', sFlag_TiHuo),
                SF('L_IsVIP', sFlag_TypeCommon),
                SF('L_Seal', FListB.Values['XCB_CementCodeID']),
                SF('L_HYDan', FListB.Values['XCB_CementCode']),
                SF('L_TransID', FListB.Values['XCB_TransID']),
                SF('L_TransName', FListB.Values['XCB_TransName']),
                SF('L_Man', FIn.FBase.FFrom.FUser),
                SF('L_Date', sField_SQLServer_Now, sfVal)
                ], sTable_Bill, '', True);
        FListA.Add(nSQL); //������

        //----------------------------------------------------------------------
        FListC.Values['Group'] :=sFlag_BusGroup;
        FListC.Values['Object'] := sFlag_PoundID;
        //to get serial no

        if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
              FListC.Text, sFlag_Yes, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx

        nSQL := MakeSQLByStr([
              SF('P_ID', nOut.FData),
              SF('P_Type', sFlag_Sale),
              SF('P_Bill', nTmp),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', FType),
              SF('P_LimValue', FKZValue),                                       //������
              SF('P_KZValue', 0, sfVal),
              SF('P_PValue', FPData.FValue, sfVal),                             //ԭʼƤ��
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', FMData.FStation),
              SF('P_MValue', FPData.FValue + FKZValue, sfVal),                  //������+Ƥ��
              SF('P_MDate', sField_SQLServer_Now, sfVal),
              SF('P_MMan', FIn.FBase.FFrom.FUser),
              SF('P_MStation', FMData.FStation),
              SF('P_FactID', FFactory),
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
        FListA.Add(nSQL);

        nMVal:= nMVal - FKZValue;
        //��ȥ����ë��

        if FListB.Values['XCB_CementCodeID'] <> '' then
        begin
          nStr := 'Select Count(*) From %s Where C_ID=''%s''';
          nStr := Format(nStr, [sTable_YT_CodeInfo, FListB.Values['XCB_CementCodeID']]);

          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
          begin
            if Fields[0].AsInteger > 0 then
            begin
              nSQL := 'Update %s Set C_Freeze=C_Freeze+%.2f Where C_ID=''%s''';
              nSQL := Format(nSQL, [sTable_YT_CodeInfo,
                      FKZValue, FListB.Values['XCB_CementCodeID']]);
              FListA.Add(nSQL);
            end else
            begin
              nSQL := MakeSQLByStr([
                SF('C_ID', FListB.Values['XCB_CementCodeID']),
                SF('C_Code', FListB.Values['XCB_CementCode']),
                SF('C_Stock', FListB.Values['XCB_Cement']),
                SF('C_Freeze', FKZValue, sfVal),
                SF('C_HasDone', '0', sfVal)
                ], sTable_YT_CodeInfo, '', True);
              FListA.Add(nSQL);
            end;
          end;
        end; //����ˮ���Ŷ�����        
      end;
    end;

    //--------------------------------------------------------------------------
    nVal := 0;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nIdx < High(nBills) then
      begin
        FMData.FValue := FPData.FValue + FValue;
        nVal := nVal + FValue;
        //�ۼƾ���

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end else
      begin
        FMData.FValue := nMVal - nVal;
        //�ۼ����ۼƵľ���

        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', nBills[nInt].FMData.FStation)
                ], sTable_PoundLog, SF('P_Bill', FID), False);
        FListA.Add(nSQL);
      end;
    end;

    FListB.Clear;
    if nBills[nInt].FPModel <> sFlag_PoundCC then //����ģʽ,ë�ز���Ч
    begin
      nSQL := 'Select L_ID From %s Where L_Card=''%s'' And L_MValue Is Null';
      nSQL := Format(nSQL, [sTable_Bill, nBills[nInt].FCard]);
      //δ��ë�ؼ�¼

      with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
      if RecordCount > 0 then
      begin
        First;

        while not Eof do
        begin
          FListB.Add(Fields[0].AsString);
          Next;
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      if nBills[nInt].FPModel = sFlag_PoundCC then Continue;
      //����ģʽ,������״̬

      i := FListB.IndexOf(FID);
      if i >= 0 then
        FListB.Delete(i);
      //�ų����γ���

      nSQL := MakeSQLByStr([SF('L_Value', FValue, sfVal),
              SF('L_Status', sFlag_TruckBFM),
              SF('L_NextStatus', sFlag_TruckOut),
              SF('L_MValue', FMData.FValue , sfVal),
              SF('L_MDate', sField_SQLServer_Now, sfVal),
              SF('L_MMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL);
    end;

    if FListB.Count > 0 then
    begin
      nTmp := AdjustListStrFormat2(FListB, '''', True, ',', False);
      //δ���ؽ������б�

      nStr := Format('L_ID In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('L_PValue', nMVal, sfVal),
              SF('L_PDate', sField_SQLServer_Now, sfVal),
              SF('L_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�ص������¼��Ƥ��,���ڱ��ε�ë��

      nStr := Format('P_Bill In (%s)', [nTmp]);
      nSQL := MakeSQLByStr([
              SF('P_PValue', nMVal, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_PStation', nBills[nInt].FMData.FStation)
              ], sTable_PoundLog, nStr, False);
      FListA.Add(nSQL);
      //û�г�ë�صĹ�����¼��Ƥ��,���ڱ��ε�ë��
    end;

    nSQL := 'Select P_ID From %s Where P_Bill=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nBills[nInt].FID]);
    //δ��ë�ؼ�¼

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      FOut.FData := Fields[0].AsString;
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then
  begin
    FListB.Clear;
    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      FListB.Add(FID);
      //�������б�

      if TWorkerBusinessCommander.CallMe(cBC_DaiPercentToZero,'','', @nOut) then
           f := StrToFloatDef(nOut.FData, 0)
      else f := 0;
      nVal := TWorkerBusinessCommander.VerifyDaiValue(nBills[nIdx],f);
      //��ȡ������ȷ�ķ�����

      nSQL := MakeSQLByStr([SF('L_Status', sFlag_TruckOut),
              SF('L_Value', nVal, sfVal),
              SF('L_NextStatus', ''),
              SF('L_Card', ''),
              SF('L_OutFact', sField_SQLServer_Now, sfVal),
              SF('L_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Bill, SF('L_ID', FID), False);
      FListA.Add(nSQL); //���½�����

      if FSeal <> '' then
      begin
        nSQL := 'Update %s Set C_HasDone=C_HasDone+(%.2f),' +
                'C_Freeze=C_Freeze-(%.2f) Where C_ID=''%s''';
        nSQL := Format(nSQL, [sTable_YT_CodeInfo, nVal, FValue, FSeal]);
        FListA.Add(nSQL); //����ˮ����
      end;
    end;

    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockBill,
       FListB.Text, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    nSQL := 'Update %s Set C_Status=''%s'' Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, sFlag_CardIdle, nBills[0].FCard]);
    FListA.Add(nSQL); //���´ſ�״̬

    nStr := AdjustListStrFormat2(FListB, '''', True, ',', False);
    //�������б�

    nSQL := 'Select T_Line,Z_Name as T_Name,T_Bill,T_PeerWeight,T_Total,' +
            'T_Normal,T_BuCha,T_HKBills,Z_Group,T_LineGroup From %s ' +
            ' Left Join %s On Z_ID = T_Line ' +
            'Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, sTable_ZTLines, nStr]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    begin
      SetLength(FBillLines, RecordCount);
      //init

      if RecordCount > 0 then
      begin
        nIdx := 0;
        First;

        while not Eof do
        begin
          with FBillLines[nIdx] do
          begin
            FBill    := FieldByName('T_Bill').AsString;
            FLine    := FieldByName('T_Line').AsString;
            FName    := FieldByName('T_Name').AsString;
            FPerW    := FieldByName('T_PeerWeight').AsInteger;
            FTotal   := FieldByName('T_Total').AsInteger;
            FNormal  := FieldByName('T_Normal').AsInteger;
            FBuCha   := FieldByName('T_BuCha').AsInteger;
            FHKBills := FieldByName('T_HKBills').AsString;

            if FieldByName('Z_Group').AsString <> sFlag_LineGroupAll then
                 FLineGroup := FieldByName('Z_Group').AsString
            else FLineGroup := FieldByName('T_LineGroup').AsString;
          end;

          Inc(nIdx);
          Next;
        end;
      end;
    end;

    SendMsgToWebMall(nBills[0].FID,cSendWeChatMsgType_OutFactory);
    ModifyWebOrderStatus(nBills[0].FID);

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if (Pos(FID, FBillLines[i].FHKBills) > 0) and
          (FID <> FBillLines[i].FBill) then
       begin
          nInt := i;
          Break;
       end;
      //�Ͽ�,��������

      if nInt < 0 then Continue;
      //����װ����Ϣ

      with FBillLines[nInt] do
      begin
        if FPerW < 1 then Continue;
        //������Ч

        i := Trunc(FValue * 1000 / FPerW);
        //����

        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_LineGroup', FBillLines[nInt].FLineGroup),
                SF('L_DaiTotal', i, sfVal),
                SF('L_DaiNormal', i, sfVal),
                SF('L_DaiBuCha', 0, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //����װ����Ϣ

        FTotal := FTotal - i;
        FNormal := FNormal - i;
        //�ۼ��Ͽ�������װ����
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    with nBills[nIdx] do
    begin
      nInt := -1;
      for i:=Low(FBillLines) to High(FBillLines) do
       if FID = FBillLines[i].FBill then
       begin
          nInt := i;
          Break;
       end;
      //�Ͽ�����

      if nInt < 0 then Continue;
      //����װ����Ϣ

      with FBillLines[nInt] do
      begin
        nSQL := MakeSQLByStr([SF('L_LadeLine', FLine),
                SF('L_LineName', FName),
                SF('L_LineGroup', FBillLines[nInt].FLineGroup),
                SF('L_DaiTotal', FTotal, sfVal),
                SF('L_DaiNormal', FNormal, sfVal),
                SF('L_DaiBuCha', FBuCha, sfVal)
                ], sTable_Bill, SF('L_ID', FID), False);
        FListA.Add(nSQL); //����װ����Ϣ
      end;
    end;

    nSQL := 'Delete From %s Where T_Bill In (%s)';
    nSQL := Format(nSQL, [sTable_ZTTrucks, nStr]);
    FListA.Add(nSQL); //����װ������
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    //xxxxx

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;

  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    if Assigned(gHardShareData) then
      gHardShareData('TruckOut:' + nBills[0].FCard);
    //���������Զ�����

    if (nBills[nInt].FType = sFlag_San) and
       (nBills[nInt].FPModel <> sFlag_PoundCC) then
    begin
      nIdx := Length(nAddID);
      if Copy(nAddID, nIdx, 1) = ',' then
        System.Delete(nAddID, nIdx, 1);
      //xxxxx

      if Length(nAddID) > 0 then
      try
        nStr := AdjustListStrFormat(nTmp, '''', True, ',', False);
        //bill list

        if not TWorkerBusinessCommander.CallMe(cBC_SyncBillEdit, nStr,
          sFlag_BillNew, @nOut) then
          raise Exception.Create(nOut.FData);
        //xxxxx
      except
        FListB.Clear;
        FListC.Clear;
        FListD.Clear;
        //init SQL List

        nVal := 0;
        SplitStr(nTmp, FListB, 0, ',', False);
    
        for nIdx := 0 to FListB.Count-1 do
        begin
          nStr := 'Select L_Value,L_Seal From %s ' +
                  'Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, FListB[nIdx]]);

          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
          begin
            if RecordCount < 1 then Continue;

            nVal := FieldByName('L_Value').AsFloat;
            nCode := FieldByName('L_Seal').AsString;
          end;

          nStr := 'Select R_ID,T_HKBills,T_Bill From %s ' +
                  'Where T_HKBills Like ''%%%s%%''';
          nStr := Format(nStr, [sTable_ZTTrucks, FListB[nIdx]]);

          with gDBConnManager.WorkerQuery(FDBConn, nStr) do
          if RecordCount > 0 then
          begin
            nRID := Fields[0].AsString;
            nBill := Fields[2].AsString;
            SplitStr(Fields[1].AsString, FListD, 0, '.')
          end else
          begin
            nRID := '';
            FListD.Clear;
          end;

          if FListD.Count = 1 then
          begin
            nStr := 'Delete From %s Where R_ID=%s';
            nStr := Format(nStr, [sTable_ZTTrucks, nRID]);

            FListC.Add(nStr);
          end else

          if FListD.Count > 1 then
          begin
            nInt := FListD.IndexOf(FListB[nIdx]);
            if nInt >= 0 then
              FListD.Delete(nInt);
            //�Ƴ��ϵ��б�

            if nBill = FListB[nIdx] then
              nBill := FListD[0];
            //����������

            nStr := 'Update %s Set T_Bill=''%s'',T_Value=T_Value-(%.2f),' +
                    'T_HKBills=''%s'' Where R_ID=%s';
            nStr := Format(nStr, [sTable_ZTTrucks, nBill, nVal,
                    CombinStr(FListD, '.'), nRID]);
            //xxxxx

            FListC.Add(nStr);
            //���ºϵ���Ϣ
          end;

          if nCode <> '' then
          begin
            nStr := 'Update %s Set C_Freeze=C_Freeze-(%.2f) Where C_ID=''%s''';
            nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCode]);
            FListC.Add(nStr);
          end;

          nStr := 'Delete From %s Where L_ID=''%s''';
          nStr := Format(nStr, [sTable_Bill, FListB[nIdx]]);
          FListC.Add(nStr);
        end;

        FDBConn.FConn.BeginTrans;
        try
          for nIdx := 0 to FListC.Count - 1 do
            gDBConnManager.WorkerExec(FDBConn, FListC[nIdx]);

          FDBConn.FConn.CommitTrans;
        except
          FDBConn.FConn.RollbackTrans;
          raise;
        end;
        raise;
      end;
      //ͬ�������

      nIdx := Length(nUpdateID);
      if Copy(nUpdateID, nIdx, 1) = ',' then
        System.Delete(nUpdateID, nIdx, 1);
      //xxxxx

      if Length(nUpdateID) > 0 then
      begin
        nStr := AdjustListStrFormat(nUpdateID, '''', True, ',', False);
        //bill list

        TWorkerBusinessCommander.CallMe(cBC_SyncBillEdit, nStr,
          sFlag_BillPick, @nOut)
      end;  
    end;  
  end;

  {$IFDEF MicroMsg}
  nStr := '';
  for nIdx:=Low(nBills) to High(nBills) do
    nStr := nStr + nBills[nIdx].FID + ',';
  //xxxxx

  if FIn.FExtParam = sFlag_TruckOut then
  begin
    with FListA do
    begin
      Clear;
      Values['bill'] := nStr;
      Values['company'] := gSysParam.FHintText;
    end;

    gWXPlatFormHelper.WXSendMsg(cWXBus_OutFact, FListA.Text);
  end;
  {$ENDIF}
end;

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessBills, sPlug_ModuleBus);
end.
