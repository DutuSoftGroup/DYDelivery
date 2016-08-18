{*******************************************************************************
  ����: fendou116688@163.com 2016-02-27
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessDuanDao;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst, UWorkerBusinessCommand;

type
  TWorkerBusinessDuanDao = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveDDCard(var nData: string): Boolean;
    function LogoffDDCard(var nData: string): Boolean;

    function SaveDDBase(var nData: string): Boolean;
    function DeleteDDBase(var nData: string): Boolean;
    //�̵��ſ�����ɾ��

    function DeleteDuanDao(var nData: string): Boolean;
    //�̵���ϸɾ��

    function GetPostDDItems(var nData: string): Boolean;
    //��ȡ��λ�̵���
    function SavePostDDItems(var nData: string): Boolean;
    //�����λ�̵���
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
  end;

implementation

//------------------------------------------------------------------------------
class function TWorkerBusinessDuanDao.FunctionName: string;
begin
  Result := sBus_BusinessDuanDao;
end;

constructor TWorkerBusinessDuanDao.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessDuanDao.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessDuanDao.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessDuanDao.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessDuanDao.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveBills         : Result := SaveDDBase(nData);
   cBC_DeleteBill        : Result := DeleteDDBase(nData);
   cBC_DeleteOrder       : Result := DeleteDuanDao(nData);
   cBC_SaveBillCard      : Result := SaveDDCard(nData);
   cBC_LogoffCard        : Result := LogoffDDCard(nData);
   cBC_GetPostBills      : Result := GetPostDDItems(nData);
   cBC_SavePostBills     : Result := SavePostDDItems(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessDuanDao.SaveDDBase(var nData: string): Boolean;
var nStr, nTruck: string;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nTruck := FListA.Values['Truck'];
  //init card

  TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, nTruck, '', @nOut);
  //���泵�ƺ�

  FDBConn.FConn.BeginTrans;
  try
    FListC.Clear;
    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_TransBase;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    nStr := MakeSQLByStr([SF('B_ID', nOut.FData),
            SF('B_Truck', nTruck),
            SF('B_SrcAddr', FListA.Values['SrcAddr']),
            SF('B_DestAddr', FListA.Values['DestAddr']),

            SF('B_Type', sFlag_San),
            SF('B_StockNo', FListA.Values['StockNO']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_Status', sFlag_BillNew),
            SF('B_IsUsed', sFlag_No),

            SF('B_Man', FIn.FBase.FFrom.FUser),
            SF('B_Date', sField_SQLServer_Now, sfVal)
            ], sTable_TransBase, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;

    FOut.FData := nOut.FData;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015/9/19
//Parm: 
//Desc: ɾ���̵����뵥
function TWorkerBusinessDuanDao.DeleteDDBase(var nData: string): Boolean;
var nStr,nP, nCard: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where T_PID=''%s''';
  nStr := Format(nStr, [sTable_Transfer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '�̵����뵥[ %s ]��ʹ�ã���ֹɾ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  nStr := 'Select B_Card From %s Where B_ID=''%s''';
  nStr := Format(nStr, [sTable_TransBase, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nCard := Fields[0].AsString
  else nCard := '';

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_TransBase]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('B_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,B_DelMan,B_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where B_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_TransBaseBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_TransBase), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_TransBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if nCard <> '' then
    begin
      nStr := 'Update %s Set T_IDCard=Null Where T_IDCard=''%s''';
      nStr := Format(nStr, [sTable_Truck, nCard]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end;  

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2015/9/19
//Parm: 
//Desc: ɾ���̵����뵥
function TWorkerBusinessDuanDao.DeleteDuanDao(var nData: string): Boolean;
var nStr,nP, nBID: string;
    nIdx: Integer;
begin
  nStr := 'Select T_PID From %s Where T_ID=''%s''';
  nStr := Format(nStr, [sTable_Transfer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
       nBID := Fields[0].AsString
  else nBID := '';

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Transfer]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('T_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,T_DelMan,T_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where T_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_TransferBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_Transfer), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where T_ID=''%s''';
    nStr := Format(nStr, [sTable_Transfer, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := MakeSQLByStr([
            SF('B_TID', ''),
            SF('B_IsUsed', sFlag_No),
            SF('B_Status', sFlag_TruckNone),
            SF('B_NextStatus', sFlag_TruckNone)
            ], sTable_TransBase, SF('B_ID', nBID), False);
    gDBConnManager.WorkerExec(FDBConn, nStr);        

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;


//Date: 2016/2/27
//Parm: 
//Desc: �̵�ҵ�����ſ�
function TWorkerBusinessDuanDao.SaveDDCard(var nData: string): Boolean;
var nSQL, nStr, nTruck: string;
begin
  Result := False;
  //init card

  nSQL := 'Select T_IDCard, T_Truck From $Truck ' +
          ' Inner Join $TransBase on B_Truck=T_Truck ' +
          ' Where B_ID=''$BID''';
  nSQL := MacroValue(nSQL, [MI('$Truck', sTable_Truck),
          MI('$TransBase', sTable_TransBase), MI('$BID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�̵����뵥[ %s ]������.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;  

    nStr := FieldByName('T_IDCard').AsString;
    nTruck := FieldByName('T_Truck').AsString;
    if (nStr <> '') and (FIn.FExtParam <> nStr) then
    begin
      nData := '����[ %s ]�Ѱ���ſ�,��������:' + #13#10#13#10 +
               '��.ԭ�����: %s' + #13#10 +
               '��.�¿����: %s' + #13#10+#13#10 +
               '����ע���ſ�.';
      nData := Format(nData, [nTruck, nStr, FIn.FExtParam]);
      Exit;
    end;  
  end;  

  FDBConn.FConn.BeginTrans;
  try
    nStr := MakeSQLByStr([
            SF('B_Card', FIn.FExtParam)
            ], sTable_TransBase, SF('B_ID', FIn.FData), False);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nSQL := 'Update %s Set T_IDCard=''%s'' Where T_Truck =''%s''';
    nSQL := Format(nSQL, [sTable_Truck, FIn.FExtParam, nTruck]);
    gDBConnManager.WorkerExec(FDBConn, nSQL);

    nSQL := 'Select Count(*) From %s Where C_Card=''%s''';
    nSQL := Format(nSQL, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if Fields[0].AsInteger < 1 then
    begin
      nSQL := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nSQL := Format('C_Card=''%s''', [FIn.FExtParam]);
      nSQL := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_DuanDao),
              SF('C_Freeze', sFlag_No),
              SF('C_TruckNo', nTruck),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, nSQL, False);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2016/2/27
//Parm: 
//Desc: �̵�ҵ��ע���ſ�
function TWorkerBusinessDuanDao.LogoffDDCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set T_IDCard=Null Where T_IDCard=''%s''';
    nStr := Format(nStr, [sTable_Truck, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set B_Card=Null Where B_Card=''%s''';
    nStr := Format(nStr, [sTable_TransBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set C_Status=''%s'', C_Used=Null, C_TruckNo=Null ' +
            'Where C_Card=''%s''';
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
function TWorkerBusinessDuanDao.GetPostDDItems(var nData: string): Boolean;
var nStr: string;
    nBills: TLadingBillItems;
begin
  Result := False;

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
      nData := '�ſ�[ %s ]��ǰ״̬Ϊ[ %s ],�޷�ʹ��.';
      nData := Format(nData, [FIn.FData, CardStatusToStr(Fields[0].AsString)]);
      Exit;
    end;

    if Fields[1].AsString = sFlag_Yes then
    begin
      nData := '�ſ�[ %s ]�ѱ�����,�޷�ʹ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  nStr := 'Select * From $TransBase b ';
  nStr := nStr + 'Where B_Card=''$CD''';
  nStr := MacroValue(nStr, [MI('$TransBase', sTable_TransBase),
          MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ſ���[ %s ]û�е��˳���.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    SetLength(nBills, 1);
    with nBills[0] do
    begin
      FID         := FieldByName('B_TID').AsString;
      if FID = '' then
        FID       := FieldByName('B_ID').AsString;

      FZhiKa      := FieldByName('B_ID').AsString;
      FCusName    := FieldByName('B_SrcAddr').AsString + '-->' +
                     FieldByName('B_DestAddr').AsString;
      FTruck      := FieldByName('B_Truck').AsString;

      FType       := SFlag_San;
      FStockNo    := FieldByName('B_StockNo').AsString;
      FStockName  := FieldByName('B_StockName').AsString;

      FCard       := FieldByName('B_Card').AsString;
      FStatus     := FieldByName('B_Status').AsString;
      FNextStatus := FieldByName('B_NextStatus').AsString;

      FIsVIP      := FieldByName('B_IsUsed').AsString;

      if FIsVIP <> sFlag_Yes then
      begin
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;
      end;
      //���������ռ��״̬

      with FPData do
      begin
        FDate   := FieldByName('B_PDate').AsDateTime;
        FValue  := FieldByName('B_PValue').AsFloat;
        FOperator := FieldByName('B_PMan').AsString;
      end;

      FMemo         := FieldByName('B_SrcAddr').AsString;
      FYSValid      := FieldByName('B_DestAddr').AsString;
      FSelected := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessDuanDao.SavePostDDItems(var nData: string): Boolean;
var nSQL,nS,nN: string;
    nInt, nIdx: Integer;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  AnalyseBillItems(FIn.FData, nPound);
  nInt := Length(nPound);
  //��������

  if nInt < 1 then
  begin
    nData := '��λ[ %s ]�ύ�ĵ���Ϊ��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  if nInt > 1 then
  begin
    nData := '��λ[ %s ]�ύ�˶̵�ҵ��ϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;

  nSQL := 'Select B_Status, B_NextStatus From %s Where B_ID=''%s''';
  nSQL := Format(nSQL, [sTable_TransBase, nPound[0].FZhiKa]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�̵����뵥���[ %s ]������,�����°���.';
      nData := Format(nData, [nPound[0].FZhiKa]);
      Exit;
    end;

    nS := Fields[0].AsString;
    nN := Fields[1].AsString;
    //���뵥��ǰ״̬����һ״̬
  end;  

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    if nS = sFlag_TruckIn then
    begin
      Result := True;
      Exit;
    end;
    //�볧��¼δ������

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_Transfer;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //�������ɵ���Ϣ���
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
              SF('T_ID', nOut.FData),
              SF('T_Card', FCard),
              SF('T_Truck', FTruck),
              SF('T_PID', FZhiKa),
              SF('T_SrcAddr', FMemo),
              SF('T_DestAddr', FYSValid),
              SF('T_Type', FType),

              SF('T_StockNo', FStockNo),
              SF('T_StockName', FStockName),
              SF('T_Status', sFlag_TruckIn),
              SF('T_NextStatus', sFlag_TruckOut),
              SF('T_InTime', sField_SQLServer_Now, sfVal),
              SF('T_InMan', FIn.FBase.FFrom.FUser)
              ], sTable_Transfer, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('B_TID', nOut.FData),
              SF('B_IsUsed', sFlag_Yes),
              SF('B_Status', sFlag_TruckIn),
              SF('B_NextStatus', sFlag_TruckOut)
              ], sTable_TransBase, SF('B_ID', FZhiKa), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckOut then //����
  begin
    if nN = sFlag_TruckOut then
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
              SF('T_Status', sFlag_TruckOut),
              SF('T_NextStatus', ''),
              SF('T_OutFact', sField_SQLServer_Now, sfVal),
              SF('T_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_Transfer, SF('T_ID', FID), False);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('B_TID', ''),
              SF('B_IsUsed', sFlag_No),
              SF('B_Status', sFlag_TruckNone),
              SF('B_NextStatus', sFlag_TruckNone)
              ], sTable_TransBase, SF('B_ID', FZhiKa), False);
      FListA.Add(nSQL);
    end;
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
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessDuanDao.CallMe(const nCmd: Integer;
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

initialization
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessDuanDao, sPlug_ModuleBus);
end.
