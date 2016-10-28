{*******************************************************************************
  ����: dmzn@163.com 2013-12-04
  ����: ģ��ҵ�����
*******************************************************************************}
unit UWorkerBusinessCommand;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, DB, ADODB, SysUtils, UBusinessWorker, UBusinessPacker,
  UBusinessConst, UMgrDBConn, UMgrParam, ZnMD5, ULibFun, UFormCtrl, USysLoger,
  USysDB, UMITConst;

type
  TBusWorkerQueryField = class(TBusinessWorkerBase)
  private
    FIn: TWorkerQueryFieldData;
    FOut: TWorkerQueryFieldData;
  public
    class function FunctionName: string; override;
    function GetFlagStr(const nFlag: Integer): string; override;
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
  end;

  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  TWorkerBusinessCommander = class(TMITDBWorker)
  private
    FListA,FListB,FListC, FListD: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton
    function GetCardUsed(var nData: string): Boolean;
    //��ȡ��Ƭ����
    function Login(var nData: string):Boolean;
    function LogOut(var nData: string): Boolean;
    //��¼ע���������ƶ��ն�
    function GetServerNow(var nData: string): Boolean;
    //��ȡ������ʱ��
    function GetSerailID(var nData: string): Boolean;
    //��ȡ����
    function IsSystemExpired(var nData: string): Boolean;
    //ϵͳ�Ƿ��ѹ���
    function GetCustomerValidMoney(var nData: string): Boolean;
    //��ȡ�ͻ����ý�
    function GetZhiKaValidMoney(var nData: string): Boolean;
    //��ȡֽ�����ý�
    function CustomerHasMoney(var nData: string): Boolean;
    //��֤�ͻ��Ƿ���Ǯ
    function GetDaiPercentToZero(var nData: string): Boolean;
    function SaveTruck(var nData: string): Boolean;
    function UpdateTruck(var nData: string): Boolean;
    function UpdateTruckLasttime(var nData: string): Boolean;
    //���泵����Truck��
    function GetTruckPoundData(var nData: string): Boolean;
    function SaveTruckPoundData(var nData: string): Boolean;
    //��ȡ������������
    function ReadYTCard(var nData: string): Boolean;
    //��ȡ���������Ƭ
    function VerifyYTCard(var nData: string): Boolean;
    //��֤�����������Ч��
    function SyncYT_Sale(var nData: string): Boolean;
    //����������
    function SyncYT_Provide(var nData: string): Boolean;
    //��Ӧ��������
    function SyncYT_BillEdit(var nData: string): Boolean;
    //������״̬ͬ��
    function SaveLadingSealInfo(var nData: string): Boolean;
    //�޸ķ��������κ�
    function GetYTBatchCode(var nData: string): Boolean;
    //��ȡ���췢�������κ�
    function SyncYT_BatchCodeInfo(var nData: string): Boolean;
    //��ȡ����ϵͳ���鵥��Ϣ

    function SyncRemoteTransit(var nData: string): Boolean;
    function SyncRemoteSaleMan(var nData: string): Boolean;
    function SyncRemoteCustomer(var nData: string): Boolean;
    function SyncRemoteProviders(var nData: string): Boolean;
    function SyncRemoteMaterails(var nData: string): Boolean;
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
    class function VerifyDaiValue(nBill: TLadingBillItem;
      const nPercent: Double=0):Double;
    //��װ������
  end;

  TWorkerBusinessOrders = class(TMITDBWorker)
  private
    FListA,FListB,FListC: TStrings;
    //list
    FIn: TWorkerBusinessCommand;
    FOut: TWorkerBusinessCommand;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;
    //base funciton

    function SaveOrderBase(var nData: string):Boolean;
    function DeleteOrderBase(var nData: string):Boolean;
    function SaveOrder(var nData: string):Boolean;
    function DeleteOrder(var nData: string): Boolean;
    function SaveOrderCard(var nData: string): Boolean;
    function LogoffOrderCard(var nData: string): Boolean;
    function ChangeOrderTruck(var nData: string): Boolean;
    //�޸ĳ��ƺ�
    function GetGYOrderValue(var nData: string): Boolean;
    //��ȡ��Ӧ���ջ���

    function GetPostOrderItems(var nData: string): Boolean;
    //��ȡ��λ�ɹ���
    function SavePostOrderItems(var nData: string): Boolean;
    //�����λ�ɹ���
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

class function TBusWorkerQueryField.FunctionName: string;
begin
  Result := sBus_GetQueryField;
end;

function TBusWorkerQueryField.GetFlagStr(const nFlag: Integer): string;
begin
  inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_GetQueryField;
  end;
end;

function TBusWorkerQueryField.DoWork(var nData: string): Boolean;
begin
  FOut.FData := '*';
  FPacker.UnPackIn(nData, @FIn);

  case FIn.FType of
   cQF_Bill:
    FOut.FData := '*';
  end;

  Result := True;
  FOut.FBase.FResult := True;
  nData := FPacker.PackOut(@FOut);
end;

//------------------------------------------------------------------------------
//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      nData := FPacker.PackOut(FDataOut);

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TWorkerBusinessCommander.FunctionName: string;
begin
  Result := sBus_BusinessCommand;
end;

constructor TWorkerBusinessCommander.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessCommander.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  inherited;
end;

function TWorkerBusinessCommander.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessCommander.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/22
//Parm: ������¼
//Desc: ������װ������,�����ɢװ��ֱ�ӷ��ط���������װ����н���
class function TWorkerBusinessCommander.VerifyDaiValue(nBill: TLadingBillItem;
    const nPercent: Double): Double;
var nNet, nTmpVal, nTmpNet: Double;
begin
  Result := nBill.FValue;

  with nBill do
  begin
    if (FType = sFlag_San) or (nPercent<=0) then Exit;

    nNet := FMData.FValue - FPData.FValue;

    nTmpVal := Float2Float(FValue * nPercent * 1000, cPrecision, False);
    nTmpNet := Float2Float(nNet * 1000, cPrecision, False);

    if nTmpVal>=nTmpNet then Result := 0;
    //����\Ʊ�ر���С��50%��������)ʱ����Ϊ�ó��������⣬��������Ϊ0
  end;  
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessCommander.CallMe(const nCmd: Integer;
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

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessCommander.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_GetCardUsed         : Result := GetCardUsed(nData);
   cBC_ServerNow           : Result := GetServerNow(nData);
   cBC_GetSerialNO         : Result := GetSerailID(nData);
   cBC_IsSystemExpired     : Result := IsSystemExpired(nData);
   cBC_GetCustomerMoney    : Result := GetCustomerValidMoney(nData);
   cBC_GetZhiKaMoney       : Result := GetZhiKaValidMoney(nData);
   cBC_CustomerHasMoney    : Result := CustomerHasMoney(nData);
   cBC_DaiPercentToZero    : Result := GetDaiPercentToZero(nData);
   cBC_SaveTruckInfo       : Result := SaveTruck(nData);
   cBC_UpdateTruckInfo     : Result := UpdateTruck(nData);
   cBC_UpdateTruckLasttime : Result := UpdateTruckLasttime(nData);
   cBC_GetTruckPoundData   : Result := GetTruckPoundData(nData);
   cBC_SaveTruckPoundData  : Result := SaveTruckPoundData(nData);
   cBC_UserLogin           : Result := Login(nData);
   cBC_UserLogOut          : Result := LogOut(nData);

   cBC_ReadYTCard          : Result := ReadYTCard(nData);
   cBC_VerifyYTCard        : Result := VerifyYTCard(nData);
   cBC_SyncStockBill       : Result := SyncYT_Sale(nData);
   cBC_SyncStockOrder      : Result := SyncYT_Provide(nData);
   cBC_SyncBillEdit        : Result := SyncYT_BillEdit(nData);

   cBC_GetYTBatchCode      : Result := GetYTBatchCode(nData);
   cBC_SaveLadingSealInfo  : Result := SaveLadingSealInfo(nData);
   cBC_SyncYTBatchCodeInfo : Result := SyncYT_BatchCodeInfo(nData);

   cBC_SyncCustomer        : Result := SyncRemoteCustomer(nData);
   cBC_SyncSaleMan         : Result := SyncRemoteSaleMan(nData);
   cBC_SyncProvider        : Result := SyncRemoteProviders(nData);
   cBC_SyncMaterails       : Result := SyncRemoteMaterails(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

//Date: 2014-09-05
//Desc: ��ȡ��Ƭ���ͣ�����S;�ɹ�P;����O
function TWorkerBusinessCommander.GetCardUsed(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  nStr := 'Select C_Used From %s Where C_Card=''%s'' ' +
          'or C_Card3=''%s'' or C_Card2=''%s''';
  nStr := Format(nStr, [sTable_Card, FIn.FData, FIn.FData, FIn.FData]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    FOut.FData := Fields[0].AsString;
    Result := True;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: �û��������룻�����û�����
//Desc: �û���¼
function TWorkerBusinessCommander.Login(var nData: string): Boolean;
var nStr: string;
begin
  Result := False;

  FListA.Clear;
  FListA.Text := PackerDecodeStr(FIn.FData);
  if FListA.Values['User']='' then Exit;
  //δ�����û���

  nStr := 'Select U_Password From %s Where U_Name=''%s''';
  nStr := Format(nStr, [sTable_User, FListA.Values['User']]);
  //card status

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then Exit;

    nStr := Fields[0].AsString;
    if nStr<>FListA.Values['Password'] then Exit;
    {
    if CallMe(cBC_ServerNow, '', '', @nOut) then
         nStr := PackerEncodeStr(nOut.FData)
    else nStr := IntToStr(Random(999999));

    nInfo := FListA.Values['User'] + nStr;
    //xxxxx

    nStr := 'Insert into $EI(I_Group, I_ItemID, I_Item, I_Info) ' +
            'Values(''$Group'', ''$ItemID'', ''$Item'', ''$Info'')';
    nStr := MacroValue(nStr, [MI('$EI', sTable_ExtInfo),
            MI('$Group', sFlag_UserLogItem), MI('$ItemID', FListA.Values['User']),
            MI('$Item', PackerEncodeStr(FListA.Values['Password'])),
            MI('$Info', nInfo)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);  }

    Result := True;
  end;
end;
//------------------------------------------------------------------------------
//Date: 2015/9/9
//Parm: �û�������֤����
//Desc: �û�ע��
function TWorkerBusinessCommander.LogOut(var nData: string): Boolean;
//var nStr: string;
begin
  {nStr := 'delete From %s Where I_ItemID=''%s''';
  nStr := Format(nStr, [sTable_ExtInfo, PackerDecodeStr(FIn.FData)]);
  //card status

  
  if gDBConnManager.WorkerExec(FDBConn, nStr)<1 then
       Result := False
  else Result := True;     }

  Result := True;
end;

//Date: 2014-09-05
//Desc: ��ȡ��������ǰʱ��
function TWorkerBusinessCommander.GetServerNow(var nData: string): Boolean;
var nStr: string;
begin
  nStr := 'Select ' + sField_SQLServer_Now;
  //sql

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    FOut.FData := DateTime2Str(Fields[0].AsDateTime);
    Result := True;
  end;
end;

//Date: 2012-3-25
//Desc: �������������б��
function TWorkerBusinessCommander.GetSerailID(var nData: string): Boolean;
var nInt: Integer;
    nStr,nP,nB: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    Result := False;
    FListA.Text := FIn.FData;
    //param list

    nStr := 'Update %s Set B_Base=B_Base+1 ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sTable_SerialBase, FListA.Values['Group'],
            FListA.Values['Object']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Select B_Prefix,B_IDLen,B_Base,B_Date,%s as B_Now From %s ' +
            'Where B_Group=''%s'' And B_Object=''%s''';
    nStr := Format(nStr, [sField_SQLServer_Now, sTable_SerialBase,
            FListA.Values['Group'], FListA.Values['Object']]);
    //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      if RecordCount < 1 then
      begin
        nData := 'û��[ %s.%s ]�ı�������.';
        nData := Format(nData, [FListA.Values['Group'], FListA.Values['Object']]);

        FDBConn.FConn.RollbackTrans;
        Exit;
      end;

      nP := FieldByName('B_Prefix').AsString;
      nB := FieldByName('B_Base').AsString;
      nInt := FieldByName('B_IDLen').AsInteger;

      if FIn.FExtParam = sFlag_Yes then //�����ڱ���
      begin
        nStr := Date2Str(FieldByName('B_Date').AsDateTime, False);
        //old date

        if (nStr <> Date2Str(FieldByName('B_Now').AsDateTime, False)) and
           (FieldByName('B_Now').AsDateTime > FieldByName('B_Date').AsDateTime) then
        begin
          nStr := 'Update %s Set B_Base=1,B_Date=%s ' +
                  'Where B_Group=''%s'' And B_Object=''%s''';
          nStr := Format(nStr, [sTable_SerialBase, sField_SQLServer_Now,
                  FListA.Values['Group'], FListA.Values['Object']]);
          gDBConnManager.WorkerExec(FDBConn, nStr);

          nB := '1';
          nStr := Date2Str(FieldByName('B_Now').AsDateTime, False);
          //now date
        end;

        System.Delete(nStr, 1, 2);
        //yymmdd
        nInt := nInt - Length(nP) - Length(nStr) - Length(nB);
        FOut.FData := nP + nStr + StringOfChar('0', nInt) + nB;
      end else
      begin
        nInt := nInt - Length(nP) - Length(nB);
        nStr := StringOfChar('0', nInt);
        FOut.FData := nP + nStr + nB;
      end;
    end;

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-05
//Desc: ��֤ϵͳ�Ƿ��ѹ���
function TWorkerBusinessCommander.IsSystemExpired(var nData: string): Boolean;
var nStr: string;
    nDate: TDate;
    nInt: Integer;
begin
  nDate := Date();
  //server now

  nStr := 'Select D_Value,D_ParamB From %s ' +
          'Where D_Name=''%s'' and D_Memo=''%s''';
  nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_ValidDate]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nStr := 'dmzn_stock_' + Fields[0].AsString;
    nStr := MD5Print(MD5String(nStr));

    if nStr = Fields[1].AsString then
      nDate := Str2Date(Fields[0].AsString);
    //xxxxx
  end;

  nInt := Trunc(nDate - Date());
  Result := nInt > 0;

  if nInt <= 0 then
  begin
    nStr := 'ϵͳ�ѹ��� %d ��,����ϵ����Ա!!';
    nData := Format(nStr, [-nInt]);
    Exit;
  end;

  FOut.FData := IntToStr(nInt);
  //last days

  if nInt <= 7 then
  begin
    nStr := Format('ϵͳ�� %d ������', [nInt]);
    FOut.FBase.FErrDesc := nStr;
    FOut.FBase.FErrCode := sFlag_ForceHint;
  end;
end;

//Date: 2014-09-05
//Desc: ��ȡָ���ͻ��Ŀ��ý��
function TWorkerBusinessCommander.GetCustomerValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nCredit: Double;
begin
  nStr := 'Select * From %s Where A_CID=''%s''';
  nStr := Format(nStr, [sTable_CusAccount, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '���Ϊ[ %s ]�Ŀͻ��˻�������.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    nVal := FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat;
    //xxxxx

    nCredit := FieldByName('A_CreditLimit').AsFloat;
    nCredit := Float2PInt(nCredit, cPrecision, False) / cPrecision;

    if FIn.FExtParam = sFlag_Yes then
      nVal := nVal + nCredit;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    FOut.FData := FloatToStr(nVal);
    FOut.FExtParam := FloatToStr(nCredit);
    Result := True;
  end;
end;

//Date: 2014-09-05
//Desc: ��ȡָ��ֽ���Ŀ��ý��
function TWorkerBusinessCommander.GetZhiKaValidMoney(var nData: string): Boolean;
var nStr: string;
    nVal,nMoney: Double;
begin
  nStr := 'Select ca.*,Z_OnlyMoney,Z_FixedMoney From $ZK,$CA ca ' +
          'Where Z_ID=''$ZID'' and A_CID=Z_Customer';
  nStr := MacroValue(nStr, [MI('$ZK', sTable_ZhiKa), MI('$ZID', FIn.FData),
          MI('$CA', sTable_CusAccount)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      nData := '���Ϊ[ %s ]��ֽ��������,��ͻ��˻���Ч.';
      nData := Format(nData, [FIn.FData]);

      Result := False;
      Exit;
    end;

    FOut.FExtParam := FieldByName('Z_OnlyMoney').AsString;
    nMoney := FieldByName('Z_FixedMoney').AsFloat;

    nVal := FieldByName('A_InMoney').AsFloat -
            FieldByName('A_OutMoney').AsFloat -
            FieldByName('A_Compensation').AsFloat -
            FieldByName('A_FreezeMoney').AsFloat +
            FieldByName('A_CreditLimit').AsFloat;
    nVal := Float2PInt(nVal, cPrecision, False) / cPrecision;

    if FOut.FExtParam = sFlag_Yes then
    begin
      if nMoney > nVal then
        nMoney := nVal;
      //enough money
    end else nMoney := nVal;

    FOut.FData := FloatToStr(nMoney);
    Result := True;
  end;
end;

//Date: 2014-09-05
//Desc: ��֤�ͻ��Ƿ���Ǯ,�Լ������Ƿ����
function TWorkerBusinessCommander.CustomerHasMoney(var nData: string): Boolean;
var nStr,nName: string;
    nM,nC: Double;
begin
  FIn.FExtParam := sFlag_No;
  Result := GetCustomerValidMoney(nData);
  if not Result then Exit;

  nM := StrToFloat(FOut.FData);
  FOut.FData := sFlag_Yes;
  if nM > 0 then Exit;

  nStr := 'Select C_Name From %s Where C_ID=''%s''';
  nStr := Format(nStr, [sTable_Customer, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount > 0 then
         nName := Fields[0].AsString
    else nName := '��ɾ��';
  end;

  nC := StrToFloat(FOut.FExtParam);
  if (nC <= 0) or (nC + nM <= 0) then
  begin
    nData := Format('�ͻ�[ %s ]���ʽ�����.', [nName]);
    Result := False;
    Exit;
  end;

  nStr := 'Select MAX(C_End) From %s Where C_CusID=''%s'' and C_Money>=0';
  nStr := Format(nStr, [sTable_CusCredit, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if (Fields[0].AsDateTime > Str2Date('2000-01-01')) and
     (Fields[0].AsDateTime < Date()) then
  begin
    nData := Format('�ͻ�[ %s ]�������ѹ���.', [nName]);
    Result := False;
  end;
end;

//Date: 2015-10-22
//Desc:
function TWorkerBusinessCommander.GetDaiPercentToZero(var nData: string): Boolean;
var nPercent: Double;
    nStr: string;
begin
  nStr := 'Select D_Value From %s Where D_Name=''%s'' ' +
          'And D_Memo=''%s'' ';
  nStr := Format(nStr, [sTable_SysDict, sFlag_PoundWuCha,
          sFlag_DaiPercentToZero]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
        nPercent := Fields[0].AsFloat
  else  nPercent := 0;

  FOut.FData := FloatToStr(nPercent);
  Result := True;
  //�̶�����
end;

//Date: 2014-10-02
//Parm: ���ƺ�[FIn.FData];
//Desc: ���泵����sTable_Truck��
function TWorkerBusinessCommander.SaveTruck(var nData: string): Boolean;
var nStr: string;
begin
  Result := True;
  FIn.FData := UpperCase(FIn.FData);
  
  nStr := 'Select Count(*) From %s Where T_Truck=''%s''';
  nStr := Format(nStr, [sTable_Truck, FIn.FData]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if Fields[0].AsInteger < 1 then
  begin
    nStr := 'Insert Into %s(T_Truck, T_PY) Values(''%s'', ''%s'')';
    nStr := Format(nStr, [sTable_Truck, FIn.FData, GetPinYinOfStr(FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2016-02-16
//Parm: ���ƺ�(Truck); ���ֶ���(Field);����ֵ(Value)
//Desc: ���³�����Ϣ��sTable_Truck��
function TWorkerBusinessCommander.UpdateTruck(var nData: string): Boolean;
var nStr: string;
    nValInt: Integer;
    nValFloat: Double;
begin
  Result := True;
  FListA.Text := FIn.FData;

  if FListA.Values['Field'] = 'T_PValue' then
  begin
    nStr := 'Select T_PValue, T_PTime From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, FListA.Values['Truck']]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nValInt := Fields[1].AsInteger;
      nValFloat := Fields[0].AsFloat;
    end else Exit;

    nValFloat := nValFloat * nValInt + StrToFloatDef(FListA.Values['Value'], 0);
    nValFloat := nValFloat / (nValInt + 1);
    nValFloat := Float2Float(nValFloat, cPrecision);

    nStr := 'Update %s Set T_PValue=%.2f, T_PTime=T_PTime+1 Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nValFloat, FListA.Values['Truck']]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
  end;
end;

//Date: 2016/8/8
//Parm: ���ӱ�ǩ
//Desc: ���³����ʱ��
function TWorkerBusinessCommander.UpdateTruckLasttime(var nData: string): Boolean;
var nStr, nHYCard: string;
begin
  nHYCard := SF('T_Card', FIn.FData);

  nStr := MakeSQLByStr([SF('T_LastTime', sField_SQLServer_Now, sfVal)],
          sTable_Truck, nHYCard, False);
  Result := gDBConnManager.WorkerExec(FDBConn, nStr) > 0;
end;

//Date: 2014-09-25
//Parm: ���ƺ�[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
function TWorkerBusinessCommander.GetTruckPoundData(var nData: string): Boolean;
var nStr: string;
    nPound: TLadingBillItems;
begin
  SetLength(nPound, 1);
  FillChar(nPound[0], SizeOf(TLadingBillItem), #0);

  nStr := 'Select * From %s Where P_Truck=''%s'' And ' +
          'P_MValue Is Null And P_PModel=''%s''';
  nStr := Format(nStr, [sTable_PoundLog, FIn.FData, sFlag_PoundPD]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr),nPound[0] do
  begin
    if RecordCount > 0 then
    begin
      FCusID      := FieldByName('P_CusID').AsString;
      FCusName    := FieldByName('P_CusName').AsString;
      FTruck      := FieldByName('P_Truck').AsString;

      FType       := FieldByName('P_MType').AsString;
      FStockNo    := FieldByName('P_MID').AsString;
      FStockName  := FieldByName('P_MName').AsString;

      with FPData do
      begin
        FStation  := FieldByName('P_PStation').AsString;
        FValue    := FieldByName('P_PValue').AsFloat;
        FDate     := FieldByName('P_PDate').AsDateTime;
        FOperator := FieldByName('P_PMan').AsString;
      end;  

      FFactory    := FieldByName('P_FactID').AsString;
      FPModel     := FieldByName('P_PModel').AsString;
      FPType      := FieldByName('P_Type').AsString;
      FPoundID    := FieldByName('P_ID').AsString;

      FStatus     := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckBFM;
      FSelected   := True;
    end else
    begin
      FTruck      := FIn.FData;
      FPModel     := sFlag_PoundPD;

      FStatus     := '';
      FNextStatus := sFlag_TruckBFP;
      FSelected   := True;
    end;
  end;

  FOut.FData := CombineBillItmes(nPound);
  Result := True;
end;

//Date: 2014-09-25
//Parm: ��������[FIn.FData]
//Desc: ��ȡָ�����ƺŵĳ�Ƥ����(ʹ�����ģʽ,δ����)
function TWorkerBusinessCommander.SaveTruckPoundData(var nData: string): Boolean;
var nStr,nSQL: string;
    nPound: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  AnalyseBillItems(FIn.FData, nPound);
  //��������

  with nPound[0] do
  begin
    if FPoundID = '' then
    begin
      TWorkerBusinessCommander.CallMe(cBC_SaveTruckInfo, FTruck, '', @nOut);
      //���泵�ƺ�

      FListC.Clear;
      FListC.Values['Group'] := sFlag_BusGroup;
      FListC.Values['Object'] := sFlag_PoundID;

      if not CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
        raise Exception.Create(nOut.FData);
      //xxxxx

      FPoundID := nOut.FData;
      //new id

      if FPModel = sFlag_PoundLS then
           nStr := sFlag_Other
      else nStr := sFlag_Provide;

      nSQL := MakeSQLByStr([
              SF('P_ID', FPoundID),
              SF('P_Type', nStr),
              SF('P_Truck', FTruck),
              SF('P_CusID', FCusID),
              SF('P_CusName', FCusName),
              SF('P_MID', FStockNo),
              SF('P_MName', FStockName),
              SF('P_MType', sFlag_San),
              SF('P_PValue', FPData.FValue, sfVal),
              SF('P_PDate', sField_SQLServer_Now, sfVal),
              SF('P_PMan', FIn.FBase.FFrom.FUser),
              SF('P_FactID', FFactory),
              SF('P_PStation', FPData.FStation),
              SF('P_Direction', '����'),
              SF('P_PModel', FPModel),
              SF('P_Status', sFlag_TruckBFP),
              SF('P_Valid', sFlag_Yes),
              SF('P_PrintNum', 1, sfVal)
              ], sTable_PoundLog, '', True);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end else
    begin
      nStr := SF('P_ID', FPoundID);
      //where

      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //����ʱ,����Ƥ�ش�,����Ƥë������
      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
      end;

      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    FOut.FData := FPoundID;
    Result := True;
  end;
end;

//Date: 2015-09-13
//Parm: ���ݺ�[FData];��ѯ����[FExtParam]
//Desc: ���ݲ�ѯ����,������.XS_Card_Base�в�ѯ��Ƭ��Ϣ
function TWorkerBusinessCommander.ReadYTCard(var nData: string): Boolean;
var nStr: string;
    nWorker: PDBWorker;
begin
  nStr := 'select XCB_ID,' +                      //�ڲ����
          '  XCB_CardId,' +                       //���ۿ�Ƭ���
          '  XCB_Origin,' +                       //��Ƭ��Դ
          '  XCB_BillID,' +                       //��Դ���ݺ�
          '  XCB_SetDate,' +                      //��������
          '  XCB_CardType,' +                     //��Ƭ����
          '  XCB_SourceType,' +                   //��Դ����
          '  XCB_Option,' +                       //���Ʒ�ʽ:0,�ص���;1,������
          '  XCB_Client,' +                       //�ͻ����
          '  xob.XOB_Name as XCB_ClientName,' +   //�ͻ�����
          '  xgd.XOB_Name as XCB_WorkAddr,' +     //���̹���
          '  XCB_Alias,' +                        //�ͻ�����
          '  XCB_OperMan,' +                      //ҵ��Ա
          '  XCB_Area,' +                         //��������
          '  XCB_CementType as XCB_Cement,' +     //Ʒ�ֱ��
          '  PCM_Name as XCB_CementName,' +       //Ʒ������
          '  XCB_LadeType,' +                     //�����ʽ
          '  XCB_Number,' +                       //��ʼ����
          '  XCB_FactNum,' +                      //�ѿ�����
          '  XCB_PreNum,' +                       //ԭ������
          '  XCB_ReturnNum,' +                    //�˻�����
          '  XCB_OutNum,' +                       //ת������
          '  XCB_RemainNum,' +                    //ʣ������
          '  XCB_ValidS,XCB_ValidE,' +            //�����Ч��
          '  XCB_AuditState,' +                   //���״̬
          '  XCB_Status,' +                       //��Ƭ״̬:0,ͣ��;1,����;2,���;3,����
          '  XCB_IsImputed,' +                    //��Ƭ�Ƿ����
          '  XCB_IsOnly,' +                       //�Ƿ�һ��һƱ
          '  XCB_Del,' +                          //ɾ�����:0,����;1,ɾ��
          '  XCB_Creator,' +                      //������
          '  pub.pub_name as XCB_CreatorNM,' +    //��������
          '  XCB_CDate,' +                        //����ʱ��
          '  XCB_Firm,' +                         //��������
          '  pbf.pbf_name as XCB_FirmName,' +     //��������
          '  pcb.pcb_id, pcb.pcb_name, ' +        //����Ƭ��
          '  xcg.xob_id as XCB_TransID, ' +       //���䵥λ���
          '  xcg.XOB_Name as XCB_TransName ' +    //���䵥λ
          'from XS_Card_Base xcb' +
          '  left join XS_Compy_Base xob on xob.XOB_ID = xcb.XCB_Client' +
          '  left join XS_Compy_Base xgd on xgd.XOB_ID = xcb.xcb_sublader' +
          '  left join PB_Code_Material pcm on pcm.PCM_ID = xcb.XCB_CementType' +
          '  Left Join pb_code_block pcb On pcb.pcb_id=xob.xob_block' +
          '  Left Join pb_basic_firm pbf On pbf.pbf_id=xcb.xcb_firm' +
          '  Left Join PB_USER_BASE pub on pub.pub_id=xcb.xcb_creator ' +
          '  Left Join XS_Card_Freight xcf on xcf.Xcf_Card=xcb.xcb_ID ' +
          '  Left Join XS_Compy_Base xcg on xcg.xob_id=xcf.xcf_tran ' +
          'where rownum <= 10';
  //��ѯ����,���ؼ�¼������10��

  if FIn.FData <> '' then
    nStr := nStr + Format(' and XCB_CardID=''%s''', [FIn.FData]);
  //�����Ų�ѯ

  if FIn.FExtParam <> '' then
    nStr := nStr + Format(' and (%s)', [FIn.FExtParam]);
  //���Ӳ�ѯ����

  Result := False;
  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        if FIn.FData = '' then
             nData := '����ϵͳ��δ�ҵ���������������.'
        else nData := Format('����:[ %s ]��Ч,�����Ѿ���ʧ.', [FIn.FData]);

        Exit;
      end;

      FListA.Clear;
      FListB.Clear;
      First;

      while not Eof do
      begin
        FListB.Values['XCB_ID']         := FieldByName('XCB_ID').AsString;
        FListB.Values['XCB_CardId']     := FieldByName('XCB_CardId').AsString;
        FListB.Values['XCB_Origin']     := FieldByName('XCB_Origin').AsString;
        FListB.Values['XCB_BillID']     := FieldByName('XCB_BillID').AsString;
        FListB.Values['XCB_SetDate']    := DateTime2Str(FieldByName('XCB_SetDate').AsDateTime);
        FListB.Values['XCB_CardType']   := FieldByName('XCB_CardType').AsString;
        FListB.Values['XCB_SourceType'] := FieldByName('XCB_SourceType').AsString;
        FListB.Values['XCB_Option']     := FieldByName('XCB_Option').AsString;
        FListB.Values['XCB_Client']     := FieldByName('XCB_Client').AsString;
        FListB.Values['XCB_ClientName'] := FieldByName('XCB_ClientName').AsString;
        FListB.Values['XCB_WorkAddr']   := FieldByName('XCB_WorkAddr').AsString;
        FListB.Values['XCB_Alias']      := FieldByName('XCB_Alias').AsString;
        FListB.Values['XCB_OperMan']    := FieldByName('XCB_OperMan').AsString;
        FListB.Values['XCB_Area']       := FieldByName('XCB_Area').AsString;
        FListB.Values['XCB_Cement']     := FieldByName('XCB_Cement').AsString;
        FListB.Values['XCB_CementName'] := FieldByName('XCB_CementName').AsString;
        FListB.Values['XCB_LadeType']   := FieldByName('XCB_LadeType').AsString;
        FListB.Values['XCB_Number']     := FloatToStr(FieldByName('XCB_Number').AsFloat);
        FListB.Values['XCB_FactNum']    := FloatToStr(FieldByName('XCB_FactNum').AsFloat);
        FListB.Values['XCB_PreNum']     := FloatToStr(FieldByName('XCB_PreNum').AsFloat);
        FListB.Values['XCB_ReturnNum']  := FloatToStr(FieldByName('XCB_ReturnNum').AsFloat);
        FListB.Values['XCB_OutNum']     := FloatToStr(FieldByName('XCB_OutNum').AsFloat);
        FListB.Values['XCB_RemainNum']  := FloatToStr(FieldByName('XCB_RemainNum').AsFloat);
        FListB.Values['XCB_AuditState'] := FieldByName('XCB_AuditState').AsString;
        FListB.Values['XCB_Status']     := FieldByName('XCB_Status').AsString;
        FListB.Values['XCB_IsOnly']     := FieldByName('XCB_IsOnly').AsString;
        FListB.Values['XCB_Del']        := FieldByName('XCB_Del').AsString;
        FListB.Values['XCB_Creator']    := FieldByName('XCB_Creator').AsString;
        FListB.Values['XCB_CreatorNM']  := FieldByName('XCB_CreatorNM').AsString;
        FListB.Values['XCB_CDate']      := DateTime2Str(FieldByName('XCB_CDate').AsDateTime);
        FListB.Values['XCB_Firm']       := FieldByName('XCB_Firm').AsString;
        FListB.Values['XCB_FirmName']   := FieldByName('XCB_FirmName').AsString;
        FListB.Values['pcb_id']         := FieldByName('pcb_id').AsString;
        FListB.Values['pcb_name']       := FieldByName('pcb_name').AsString;
        FListB.Values['XCB_TransID']    := FieldByName('XCB_TransID').AsString;
        FListB.Values['XCB_TransName']  := FieldByName('XCB_TransName').AsString;

        FListA.Add(PackerEncodeStr(FListB.Text));
        Next;
      end;

      FOut.FData := PackerEncodeStr(FListA.Text);
      Result := True;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2015-09-14
//Parm: ��ReadYTCard��ѯ���ļ�¼[FData];������չ��Ϣ[FIn.FExtParam]
//Desc: ��֤��¼�Ƿ���Ч,�����ܷ񿪵�
function TWorkerBusinessCommander.VerifyYTCard(var nData: string): Boolean;
var nStr: string;
    nVal: Double;
    nWorker: PDBWorker;
begin
  with FListA do
  begin
    Result := False;
    nData := '';
    Text := PackerDecodeStr(FIn.FData);

    if Values['XCB_Del'] <> '0' then
    begin
      nStr := '��.����:[ %s ]��ɾ��,�򱻹���Ա�ر�.' + #13#10;
      nData := Format(nStr, [Values['XCB_CardId']]);
    end;

    if (Values['XCB_IsOnly'] <> '1') and (Values['XCB_AuditState'] <> '201') then
    begin
      nStr := '��.����:[ %s ]δͨ������Ա���.' + #13#10;
      nData := nData + Format(nStr, [Values['XCB_CardId']]);
    end;
    //XCB_IsOnlyΪ1ʱ��һ��һƱ�ȹ����������

    if Values['XCB_Status'] <> '1' then
    begin
      nStr := '��.����:[ %s ]δ����,��ͣ�û�����.' + #13#10;
      nData := nData + Format(nStr, [Values['XCB_CardId']]);
    end;

    nStr := Values['XCB_RemainNum'];
    if not IsNumber(nStr, True) then
    begin
      nStr := '��.����:[ %s ]ʣ������ȡʧ��.' + #13#10;
      nData := nData + Format(nStr, [Values['XCB_CardId']]);
      Exit;
    end;

    if nData <> ''  then Exit;
    //���д���,����У�鶳����

    //--------------------------------------------------------------------------
    nWorker := nil;
    try
      //nStr := 'select XCB_FactRemain from V_CARD_BASE1 t where XCB_ID=''%s''';
      nStr := 'select XCB_FactRemain from V_CARD_BASE t where XCB_ID=''%s''';
      //֧�ֲ�ѯ����
      nStr := Format(nStr, [Values['XCB_ID']]);
      //��ѯʣ����
      
      with gDBConnManager.SQLQuery(nStr, nWorker, sFlag_DB_YT) do
      begin
        if RecordCount > 0 then
             nVal := Fields[0].AsFloat
        else nVal := 0;

        {$IFDEF DEBUG}
        nStr := '����:[%s]=>����ϵͳʣ����[%f]';
        nStr := Format(nStr, [Values['XCB_ID'], Fields[0].AsFloat]);
        WriteLog(nStr);
        {$ENDIF}
      end;

      if nVal > 0 then
      begin
        nStr := 'Select * From %s Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CardInfo, Values['XCB_ID']]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        if RecordCount > 0 then
        begin
          First;
          nVal := nVal - FieldByName('C_Freeze').AsFloat;
          //�۳��ѿ�δ��
          nVal := Float2Float(nVal, cPrecision, False);

          {$IFDEF DEBUG}
          nStr := '����:[%s]=>һ��ͨϵͳ������[%f]';
          nStr := Format(nStr, [Values['XCB_ID'], FieldByName('C_Freeze').AsFloat]);
          WriteLog(nStr);
          {$ENDIF}
        end;
      end;

      if (nVal <= 0) and (Pos(sFlag_AllowZeroNum, FIn.FExtParam) < 1) then
      begin
        nStr := '��.����:[ %s ]�ɿ�Ʊ��Ϊ0,�޷����.' + #13#10;
        nData := nData + Format(nStr, [Values['XCB_CardId']]);
        Exit;
      end;

      Values['XCB_RemainNum'] := FloatToStr(nVal);
      //������

      //--------------------------------------------------------------------------
      if Pos(sFlag_LoadExtInfo, FIn.FExtParam) < 1 then
      begin
        FOut.FData := PackerEncodeStr(FListA.Text);
        Result := True;
        Exit;
      end; //�Ƿ���ض���������Ϣ

      nStr := 'Select D_Memo From %s Where D_ParamB=''%s''';
      nStr := Format(nStr, [sTable_SysDict, Values['XCB_Cement']]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
        begin
          nStr := 'Ʒ��[ %s.%s ]û�����ֵ�������,����ϵ����Ա.';
          nStr := Format(nStr, [Values['XCB_Cement'], Values['XCB_CementName']]);

          nData := nStr;
          Exit;
        end;

        Values['XCB_CementType'] := Fields[0].AsString;
        //��ɢ����
      end;

      FOut.FData := PackerEncodeStr(FListA.Text);
      Result := True;
    finally
      gDBConnManager.ReleaseConnection(nWorker);
    end;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm: 
//Desc: ͬ������ϵͳ�ͻ���Ϣ
function TWorkerBusinessCommander.SyncRemoteCustomer(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  nStr := 'Select C_Param From %s Where C_XuNi<>''%s''';
  nStr := Format(nStr, [sTable_Customer, sFlag_Yes]);

  FListB.Clear;
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nStr := 'Select XOB_ID,XOB_Code,XOB_Name,XOB_JianPin,XOB_Status ' +
            'From XS_Compy_Base ' +
            'Where XOB_IsClient=''1''';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('XOB_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('XOB_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('C_ID', FieldByName('XOB_Code').AsString),
                  SF('C_Name', FieldByName('XOB_Name').AsString),
                  SF('C_PY', FieldByName('XOB_JianPin').AsString),
                  SF('C_Param', FieldByName('XOB_ID').AsString),
                  SF('C_XuNi', sFlag_No)
                  ], sTable_Customer, '', True);
          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where C_Param=''%s''';
          nStr := Format(nStr, [sTable_Customer, FieldByName('XOB_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //��������
    
      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm: 
//Desc: ͬ������ϵͳҵ��Ա��Ϣ
function TWorkerBusinessCommander.SyncRemoteSaleMan(var nData: string): Boolean;
begin
  Result := True;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm: 
//Desc: ͬ������ϵͳ��Ӧ����Ϣ
function TWorkerBusinessCommander.SyncRemoteProviders(var nData: string): Boolean;
var nStr,nSaler: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  FListB.Clear;
  nStr := 'Select P_ID From P_Provider';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nSaler := '������ҵ��Ա';
    nStr := 'Select XOB_ID,XOB_Code,XOB_Name,XOB_JianPin,XOB_Status ' +
            'From XS_Compy_Base ' +
            'Where XOB_IsSupy=''1'' or XOB_IsMetals=''1''';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('XOB_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('XOB_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('P_ID', FieldByName('XOB_ID').AsString),
                  SF('P_Name', FieldByName('XOB_Name').AsString),
                  SF('P_PY', GetPinYinOfStr(FieldByName('XOB_Name').AsString)),
                  SF('P_Memo', FieldByName('XOB_Code').AsString),
                  SF('P_Saler', nSaler)
                  ], sTable_Provider, '', True);
          //xxxxx

          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where P_ID=''%s''';
          nStr := Format(nStr, [sTable_Provider, FieldByName('XOB_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //��������

      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm:
//Desc: ͬ������ϵͳԭ������Ϣ
function TWorkerBusinessCommander.SyncRemoteMaterails(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  FListB.Clear;
  nStr := 'Select M_ID From P_Materails';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nStr := 'Select PCM_ID,PCM_MaterId,PCM_Name,PCM_Kind,PCY_Name,PCM_Status ' +
            'From PB_Code_Material pcm ' +
            'Left join PB_Code_MaterType pcy on pcm.PCM_Kind=pcy.PCY_ID ';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('PCM_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('PCM_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('PCM_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('M_ID', FieldByName('PCM_ID').AsString),
                SF('M_Name', FieldByName('PCM_Name').AsString),
                SF('M_PY', GetPinYinOfStr(FieldByName('PCM_Name').AsString)),
                SF('M_Memo', FieldByName('PCM_MaterId').AsString +
                  FieldByName('PCY_Name').AsString)
                ], sTable_Materails, '', True);
          //xxxxx

          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where M_ID=''%s''';
          nStr := Format(nStr, [sTable_Materails, FieldByName('PCM_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('PCM_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;

    for nIdx:=0 to FListA.Count - 1 do
      gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
    FDBConn.FConn.CommitTrans;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/10/13
//Parm:
//Desc: ͬ������ϵͳ���䵥λ��Ϣ
function TWorkerBusinessCommander.SyncRemoteTransit(var nData: string): Boolean;
var nStr,nSaler: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  Result := True;

  FListB.Clear;
  nStr := 'Select T_ID From S_Translator';
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount>0 then
  begin
    First;

    while not Eof do
    begin
      if Fields[0].AsString<>'' then FListB.Add(Fields[0].AsString);

      Next;
    end;  
  end;

  nDBWorker := nil;
  try
    nSaler := '������ҵ��Ա';
    nStr := 'Select XOB_ID,XOB_Code,XOB_Name,XOB_JianPin,XOB_Status ' +
            'From XS_Compy_Base ' +
            'Where XOB_IsTransit=''1''';
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        if FieldByName('XOB_ID').AsString = '' then Continue;
        //invalid

        if FieldByName('XOB_Status').AsString = '1' then
        begin  //Add
          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          Continue;
          //Has Saved

          nStr := MakeSQLByStr([SF('T_ID', FieldByName('XOB_ID').AsString),
                  SF('T_Name', FieldByName('XOB_Name').AsString),
                  SF('T_PY', GetPinYinOfStr(FieldByName('XOB_Name').AsString)),
                  SF('T_Memo', FieldByName('XOB_Code').AsString),
                  SF('T_Saler', nSaler)
                  ], sTable_Translator, '', True);
          //xxxxx

          FListA.Add(nStr);

        end else
        begin  //valid
          nStr := 'Delete From %s Where T_ID=''%s''';
          nStr := Format(nStr, [sTable_Translator, FieldByName('XOB_ID').AsString]);
          //xxxxx

          if (FListB.Count>0) and
          (FListB.IndexOf(FieldByName('XOB_ID').AsString)>=0) then
          FListA.Add(nStr);
          //Has Saved
        end;
      finally
        Next;
      end;
    end;

    if FListA.Count > 0 then
    try
      FDBConn.FConn.BeginTrans;
      //��������

      for nIdx:=0 to FListA.Count - 1 do
        gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]);
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

//Date: 2015-09-16
//Parm: ����;������·
//Desc: ����nTable��Ψһ��¼��
function YT_NewID(const nTable: string; const nWorker: PDBWorker): string;
begin
  with nWorker.FExec do
  begin
    Close;
    SQL.Text := '{call GetID(?,?)}';

    Parameters.Clear;
    Parameters.CreateParameter('P1', ftString , pdInput, Length(nTable), nTable);
    Parameters.CreateParameter('P2', ftString, pdOutput, 20, '') ;
    ExecSQL;

    Result := Parameters.ParamByName('P2').Value;
  end;
end;

//Date: 2015/11/3
//Parm: ������·
//Desc: ��ȡ����ϵͳ�������
function YT_GetSpell(const nWorker: PDBWorker): string;
var nBegin, nEnd, nNow: TDateTime;
begin
  Result := '';
  //init

  nNow := Time;
  with nWorker.FExec do
  begin
    Close;
    SQL.Text := 'select * from PB_Code_Spell';
    Open;

    if RecordCount<=0 then  Exit;

    First;
    while not Eof do
    try
      nBegin := FieldByName('PCP_BEGINTIME').AsDateTime;
      nEnd   := FieldByName('PCP_ENDTIME').AsDateTime;

      if nBegin>nEnd then nEnd := nEnd + 1;

      if nBegin>nNow then Continue;
      //��ǰʱ��С�ڿ�ʼʱ��

      if nEnd < nNow then Continue;
      //����ʱ����ڿ�ʼʱ��

      Result := FieldByName('PCP_ID').AsString;
      Exit;
    finally
      Next;
    end;
  end;
end;

//Date: 2015-11-03
//Parm: ���ݿ���䣻������·
//Desc: ���ɲ�����������
function YT_NewInsertLog(const nSQL: string; const nWorker: PDBWorker): string;
var nStr, nSQLTmp, nPltID: string;
begin
  Result := '';
  //init

  nPltID := YT_NewID('PB_LOG_TRANSACTION', nWorker);
  nStr := MakeSQLByStr([SF('PLT_ID', nPltID),
          SF('PLT_Status', '0')
          ], 'PB_Log_Transaction', '', True);
  Result := Result + nStr + ';';
  //ͬ�������

  nSQLTmp := StringReplace(nSQL, '''', '''''', [rfReplaceAll, rfIgnoreCase]);
  nStr := MakeSQLByStr([SF('PLS_TRANSACTION', nPltID),
          SF('PLS_ORDER', 0),
          SF('PLS_SQL', nSQLTmp)
          ], 'PB_Log_Sql', '', True);
  Result := Result + nStr + ';';
  //ͬ������ִ������
end;
//------------------------------------------------------------------------------
//Date: 2015/9/26
//Parm: 
//Desc: תOracleDateTime
function DateTime2StrOracle(const nDT: TDateTime): string;
var nStr :string;
begin
  nStr := 'to_date(''%s'', ''yyyy-mm-dd hh24-mi-ss'')';
  Result := Format(nStr, [DateTime2Str(nDT)]);
end;

function Date2StrOracle(const nDT: TDateTime): string;
var nStr :string;
begin
  nStr := 'to_date(''%s'', ''yyyy-mm-dd'')';
  Result := Format(nStr, [Date2Str(nDT)]);
end;

//Date: 2015-09-16
//Parm: ������(���)[FIn.FData]
//Desc: ͬ���������������ݵ����췢������
function TWorkerBusinessCommander.SyncYT_Sale(var nData: string): Boolean;
var nIdx: Integer;
    nDS: TDataSet;
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
    nDateMin, nSetDate: TDateTime;
    nStr,nSQL,nPID,nSpell, nFreID, nFreType: string;
    nVal,nFreVal, nFrePrice: Double;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

  nSQL := 'Select bill.*, plog.P_ID, ' +         //�������Ϣ
          'bcreater.U_Memo As bCreaterID, ' +    //���쿪ƱԱ���
          'pcreater.U_Memo As pCreaterID, ' +    //�����Ƥ˾��Ա
          'mcreater.U_Memo As mCreaterID  ' +    //�����ë˾��Ա
          ' From $BILL bill ' +
          ' Left Join $USER bcreater On bcreater.U_Name=bill.L_Man ' +
          ' Left Join $USER pcreater On pcreater.U_Name=bill.L_PMan ' +
          ' Left Join $USER mcreater On mcreater.U_Name=bill.L_MMan ' +
          ' Left Join $PLOG plog On plog.P_Bill=bill.L_ID ' +
          'Where L_ID In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BILL', sTable_Bill), MI('$USER', sTable_User),
          MI('$PLOG', sTable_PoundLog), MI('$IN', nStr)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '������[ %s ]��Ϣ�Ѷ�ʧ.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    SetLength(nBills, RecordCount);
    nIdx := 0;

    FListA.Clear;
    First;

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('L_ID').AsString;
        FZhiKa      := FieldByName('L_ZhiKa').AsString;
        FCusID      := FieldByName('L_CusID').AsString;
        FCard       := '0';
        //Ĭ�Ϸ�һ��һƱ

        FSeal       := FieldByName('L_Seal').AsString;
        FHYDan      := FieldByName('L_HYDan').AsString;

        FTruck      := FieldByName('L_Truck').AsString;
        FStockNo    := FieldByName('L_StockNo').AsString;
        FValue      := FieldByName('L_Value').AsFloat;
        FYSValid    := FieldByName('L_IsEmpty').AsString;

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //������

        FPoundID := FieldByName('P_ID').AsString;
        //�񵥱��
        if FPoundID = '' then
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          FPoundID := nOut.FData;
        end;

        nDateMin := Str2Date('2000-01-01');
        //��С���ڲο�

        with FPData do
        begin
          FValue    := FieldByName('L_PValue').AsFloat;
          FDate     := FieldByName('L_PDate').AsDateTime;
          FOperator := FieldByName('pCreaterID').AsString;

          if FOperator = '' then
            FOperator := FieldByName('L_PMan').AsString;
          //xxxx

          if FDate < nDateMin then
            FDate := FieldByName('L_Date').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        with FMData do
        begin
          FValue    := FieldByName('L_MValue').AsFloat;
          FDate     := FieldByName('L_MDate').AsDateTime;
          FOperator := FieldByName('mCreaterID').AsString;

          if FOperator = '' then
            FOperator := FieldByName('L_MMan').AsString;
          //xxxx

          if FDate < nDateMin then
            FDate := FieldByName('L_OutFact').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        FYTID := FieldByName('L_YTID').AsString;
        FMemo := FieldByName('L_Memo').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);
  //�����б�

  nSQL := 'select * From %s Where XCB_ID in (%s)';
  nSQL := Format(nSQL, ['XS_Card_Base', nStr]);
  //��ѯ������

  nWorker := nil;
  try
    nDS := gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_YT);
    with nDS do
    begin
      if RecordCount < 1 then
      begin
        nData := '����ϵͳ: ������[ %s ]��Ϣ�Ѷ�ʧ.';
        nData := Format(nData, [CombinStr(FListA, ',', False)]);
        Exit;
      end;

      FListA.Clear;
      FListA.Add('begin');
      //init sql list

      for nIdx:=Low(nBills) to High(nBills) do
      begin
        First;
        //init cursor

        if nBills[nIdx].FValue<=0 then Continue;
        //������Ϊ0

        if nBills[nIdx].FYSValid = sFlag_Yes then Continue;
        //�ճ�����

        while not Eof do
        begin
          nStr := FieldByName('XCB_ID').AsString;
          if nStr = nBills[nIdx].FZhiKa then Break;
          Next;
        end;

        if Eof then Continue;
        //������ʧ���账��

        nSetDate := nBills[nIdx].FMData.FDate;
        //nSetDate

        if nBills[nIdx].FYTID = '' then
        begin
          nBills[nIdx].FYTID := YT_NewID('XS_LADE_BASE', nWorker);
          //��¼���

          nSQL := MakeSQLByStr([SF('XLB_ID', nBills[nIdx].FYTID),
                  SF('XLB_LadeId', nBills[nIdx].FID),
                  SF('XLB_SetDate', Date2StrOracle(nSetDate), sfVal),
                  SF('XLB_LadeType', '103'),
                  SF('XLB_Origin', '101'),
                  SF('XLB_Client', nBills[nIdx].FCusID),
                  SF('XLB_Cement', nBills[nIdx].FStockNo),
                  SF('XLB_CementSwap', nBills[nIdx].FStockNo),
                  SF('XLB_Number', nBills[nIdx].FValue, sfVal),

                  SF('XLB_Price', '0.00', sfVal),
                  SF('XLB_CardPrice', '0.00', sfVal),
                  SF('XLB_Total', '0.00', sfVal),
                  SF('XLB_FactTotal', '0.00', sfVal),
                  SF('XLB_ScaleDifNum', '0.00', sfVal),
                  SF('XLB_InvoNum', '0.00', sfVal),

                  SF('XLB_SendArea', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_CarCode', nBills[nIdx].FTruck),
                  SF('XLB_Quantity', '0', sfVal),
                  SF('XLB_PrintNum', '0', sfVal),
                  SF('XLB_IsCarry', '0'),
                  SF('XLB_IsOut', '0'),
                  SF('XLB_IsCheck', '1'),
                  SF('XLB_IsDoor', '0'),
                  SF('XLB_IsBack', '0'),
                  SF('XLB_IsInvo', '0'),
                  SF('XLB_Approve', '0'),
                  SF('XLB_TCollate', '0'),
                  SF('XLB_Collate', '0'),
                  SF('XLB_OutStore', '0'),
                  SF('XLB_ISTUNE', '0'),

                  SF('XLB_Firm', FieldByName('XCB_Firm').AsString),
                  SF('XLB_Status', '1'),
                  SF('XLB_Del', '0'),
                  SF('XLB_Creator', nBills[nIdx].FMData.FOperator),
                  SF('XLB_CDate', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_KDATE', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_ISONLY', FieldByName('XCB_ISONLY').AsString),
                  SF('XLB_ISSUPPLY', '0')
                  ], 'XS_Lade_Base', '', True);
          FListA.Add(nSQL + ';'); //�����������

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������

          nSQL := MakeSQLByStr([SF('XLD_ID', YT_NewID('XS_LADE_DETAIL', nWorker)),
                  SF('XLD_Lade', nBills[nIdx].FYTID),
                  SF('XLD_Client', nBills[nIdx].FCusID),
                  SF('XLD_Card',  nBills[nIdx].FZhiKa),
                  SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                  SF('XLD_Gap', '0', sfVal),
                  SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLD_Order', '0', sfVal)
                  ], 'XS_Lade_Detail', '', True);
          FListA.Add(nSQL + ';'); //�����������ϸ��

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������

          nSQL := SF('L_ID', nBills[nIdx].FID);
          nSQL := MakeSQLByStr([
                  SF('L_YTID', nBills[nIdx].FYTID)
                  ],sTable_Bill, nSQL, False);
          gDBConnManager.WorkerExec(FDBConn, nSQL);        
        end;  

        //nRID := YT_NewID('XS_LADE_BASE', nWorker);
        //��¼���

        nSQL := MakeSQLByStr([
                SF('XLB_CementCode', nBills[nIdx].FHYDan),
                SF('XLB_FactNum', nBills[nIdx].FValue, sfVal),
                SF('XLB_Remark', nBills[nIdx].FMemo),

                SF('XLB_Area', FieldByName('XCB_Area').AsString),
                {$IFDEF ADDRETURN}
                SF('XLB_Return', FieldByName('XCB_Return').AsString),
                {$ENDIF}

                SF('XLB_OutTime', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLB_DoorTime', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLB_IsCarry', '1'),
                SF('XLB_IsOut', '1'),
                SF('XLB_IsCheck', '0'),
                SF('XLB_IsDoor', '1'),
                SF('XLB_Gather', '1')
                ], 'XS_Lade_Base', SF('XLB_ID', nBills[nIdx].FYTID), False);
        FListA.Add(nSQL + ';'); //�����������

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nBills[nIdx].FPrice := FieldByName('XCB_Price').AsFloat;
        nVal := nBills[nIdx].FPrice * nBills[nIdx].FValue;
        nVal := Float2Float(nVal, cPrecision, True);
        //�۸�

        nSQL := MakeSQLByStr([
                SF('XLD_Client', nBills[nIdx].FCusID),
                SF('XLD_Card',  nBills[nIdx].FZhiKa),
                SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                SF('XLD_Price', nBills[nIdx].FPrice, sfVal),
                SF('XLD_CardPrice', nBills[nIdx].FPrice, sfVal),
                SF('XLD_Gap', '0', sfVal),
                SF('XLD_Total', nVal, sfVal),
                SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                SF('XLD_Order', '0', sfVal),
                SF('XLD_FactNum', '0', sfVal),
                SF('XLD_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                SF('XLD_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                SF('XLD_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                ], 'XS_Lade_Detail', SF('XLD_Lade', nBills[nIdx].FYTID), False);
        FListA.Add(nSQL + ';'); //�����������ϸ��

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nPID := YT_NewID('DB_TURN_PRODUOUT', nWorker);
        nSQL := MakeSQLByStr([SF('DTP_ID', nPID),
                SF('DTP_Card', nBills[nIdx].FZhiKa),
                SF('DTP_ScaleBill', nBills[nIdx].FID),
                SF('DTP_Origin',  '101'),

                SF('DTP_Vehicle', nBills[nIdx].FTruck),
                SF('DTP_OutDate', Date2StrOracle(nSetDate), sfVal),
                SF('DTP_Material', nBills[nIdx].FStockNo),
                SF('DTP_CementCode', nBills[nIdx].FHYDan),
                SF('DTP_Lade', nBills[nIdx].FYTID),

                SF('DTP_Scale',  nBills[nIdx].FPData.FStation),
                SF('DTP_Creator', nBills[nIdx].FPData.FOperator),
                SF('DTP_CDate', DateTime2StrOracle(nBills[nIdx].FPData.FDate),sfVal),
                SF('DTP_SecondScale',  nBills[nIdx].FMData.FStation),
                SF('DTP_GMan', nBills[nIdx].FMData.FOperator),
                SF('DTP_GDate', DateTime2StrOracle(nBills[nIdx].FMData.FDate),sfVal),

                SF('DTP_Firm', FieldByName('XCB_Firm').AsString),
                SF('DTP_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                SF('DTP_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                SF('DTP_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal),

                SF('DTP_ISBalance', '0'),
                SF('DTP_IsSupply', '0'),
                SF('DTP_Status', '1'),
                SF('DTP_Del', '0')
                ], 'DB_Turn_ProduOut', '', True);
        FListA.Add(nSQL + ';'); //ˮ�����ϳ�����

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nSQL := MakeSQLByStr([SF('DTU_ID', YT_NewID('DB_TURN_PRODUDTL', nWorker)),
                SF('DTU_Del', '0'),
                SF('DTU_PID', nPID),
                SF('DTU_LadeID', nBills[nIdx].FYTID),
                SF('DTU_Firm', FieldByName('XCB_Firm').AsString),
                SF('DTU_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                SF('DTU_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                SF('DTU_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                ], 'DB_Turn_ProduDtl', '', True);
        FListA.Add(nSQL + ';'); //ˮ�����ϳ�����ϸ��

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nSpell := YT_GetSpell(nWorker);
        nSQL := MakeSQLByStr([SF('XLO_Lade', nBills[nIdx].FYTID),
                SF('XLO_SetDate', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLO_Creator', 'zx-delivery'),
                SF('XLO_CDate', DateTime2StrOracle(nSetDate), sfVal),
                SF('XLO_FIRM', FieldByName('XCB_Firm').AsString),
                SF('XLO_SPELL', nSpell),
                SF('XLO_ISCANDEL', '0')
                ], 'XS_Lade_OutDoor', '', True);
        FListA.Add(nSQL + ';'); //��������ŵǼǱ�

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nSQL := 'Update %s Set XCB_FactNum=XCB_FactNum+(%.2f),' +
                'XCB_RemainNum=XCB_RemainNum-(%.2f) Where XCB_ID=''%s''';
        nSQL := Format(nSQL, ['XS_Card_Base', nBills[nIdx].FValue,
                nBills[nIdx].FValue, nBills[nIdx].FZhiKa]);
        FListA.Add(nSQL + ';'); //���¶���

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nBills[nIdx].FCard := FieldByName('XCB_IsOnly').AsString;
        //�Ƿ�һ��һƱ

        if nBills[nIdx].FSeal <> '' then
        begin
          nStr := YT_NewID('XS_LADE_CEMENTCODE', nWorker);
          //id

          nSQL := MakeSQLByStr([SF('XLM_ID', nStr),
                  SF('XLM_LADE', nBills[nIdx].FYTID),
                  SF('XLM_CEMENTCODE', nBills[nIdx].FSeal),
                  SF('XLM_NUMBER', nBills[nIdx].FValue, sfVal)
                  ], 'XS_Lade_CementCode', '', True);
          FListA.Add(nSQL + ';'); //�������κ�ʹ����

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������
        end;
      end;
    end;

    for nIdx:=Low(nBills) to High(nBills) do
    if nBills[nIdx].FCard = '1' then //�����һ��һƱ
    begin
      nVal := nBills[nIdx].FPrice * nBills[nIdx].FValue;
      nVal := Float2Float(nVal, cPrecision, True);
      //ˮ����

      nSQL := MakeSQLByStr([
              SF('XCB_Number', nBills[nIdx].FValue, sfVal),
              SF('XCB_TotalSum', nVal, sfVal),
              SF('XCB_ToTal', nVal, sfVal),
              SF('XCB_IsCanAudit', '1')
              ], 'XS_Card_Base', SF('XCB_ID', nBills[nIdx].FZhiKa), False);
      FListA.Add(nSQL + ';'); //�����������:������,�ܽ��,ˮ����,״̬

      nSQL := YT_NewInsertLog(nSQL+';', nWorker);
      FListA.Add(nSQL);
      //����ͬ�������

      nSQL := 'Update %s Set XRC_Total=%.2f Where XRC_BillID=''%s'' ' +
              'And XRC_Origin=''101'' And XRC_FreType=''999''';
      nSQL := Format(nSQL, ['XS_Rece_Receivable', nVal,
              nBills[nIdx].FZhiKa]);
      FListA.Add(nSQL + ';'); //����Ӧ�տ��:ˮ����

      nSQL := YT_NewInsertLog(nSQL+';', nWorker);
      FListA.Add(nSQL);
      //����ͬ�������

      nSQL  := 'Select * From %s Where XCF_Card=''%s''';
      nSQL  := Format(nSQL, ['XS_Card_Freight', nBills[nIdx].FZhiKa]);

      with gDBConnManager.WorkerQuery(nWorker, nSQL) do
      begin
        First;

        while not Eof do
        try
          nFreID := FieldByName('XCF_ID').AsString;
          nFreType := FieldByName('XCF_Type').AsString;
          nFrePrice := FieldByName('XCF_Price').AsFloat;

          nFreVal := nFrePrice * nBills[nIdx].FValue;
          nFreVal := Float2Float(nFreVal, cPrecision, True);
          //�˷ѽ��

          nSQL := 'Update %s Set XRC_Total=%.2f Where XRC_BillID=''%s'' ' +
                  'And XRC_Origin=''101'' And XRC_FreType=''%s''';
          nSQL := Format(nSQL, ['XS_Rece_Receivable', nFreVal,
                  nBills[nIdx].FZhiKa, nFreType]);
          FListA.Add(nSQL + ';'); //����Ӧ�տ��:�˷ѽ��

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������

          nSQL := 'Update %s Set XCB_TotalSum=XCB_TotalSum+(%.2f) ' +
                  'Where XCB_ID=''%s''';
          nSQL := Format(nSQL, ['XS_Card_Base', nFreVal, nBills[nIdx].FZhiKa]);
          FListA.Add(nSQL + ';'); //�����������:�ܽ��

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������

          nSQL := 'Update %s Set XCF_Total=%.2f Where XCF_ID=''%s''';
          nSQL := Format(nSQL, ['XS_Card_Freight', nFreVal,
                  nFreID]);
          FListA.Add(nSQL + ';'); //�����˷ѱ�

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������
        finally
          Next;
        end;
      end;
    end;

    //nWorker.FConn.BeginTrans;
    try
      nStr := 'commit;' + #13#10 +
              'exception' + #13#10 +
              ' when others then rollback; raise;' + #13#10 +
              'end;';
      FListA.Add(nStr);
      //oracle����ȷ�ύ

      gDBConnManager.WorkerExec(nWorker, FListA.Text);
      //ִ�нű�

      //nWorker.FConn.CommitTrans;
      Result := True;
    except
      on E:Exception do
      begin
        //nWorker.FConn.RollbackTrans;
        nData := 'ͬ����������ʱ��������,����: ' + E.Message;
        Exit;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2015-09-16
//Parm: �񵥺�(����)[FIn.FData]
//Desc: ͬ��ԭ�Ϲ������ݵ�����ɹ�����
function TWorkerBusinessCommander.SyncYT_Provide(var nData: string): Boolean;
var nStr,nSQL,nRID: string;
    nIdx,nErrNum: Integer;
    nDateMin: TDateTime;
    nWorker: PDBWorker;
    nBills: TLadingBillItems;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;
  FListA.Text := FIn.FData;
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);

  nSQL := 'Select D_ID,D_OID,O_ProID,O_StockNo,O_Truck,' +
          'D_Value,D_KZValue,D_AKValue,D_YSResult,' +
          'D_PValue,D_PDate,D_PMan,' +
          'D_MValue,D_MDate,D_MMan,' +
          'D_InTime,D_OutFact,D_PID ' +
          'From %s ' +
          '  Left Join %s On D_OID=O_ID ' +
          'Where D_ID In (%s) ';
  nSQL := Format(nSQL, [sTable_OrderDtl, sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '�ɹ���ⵥ[ %s ]��Ϣ�Ѷ�ʧ.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    if FieldByName('D_YSResult').AsString=sFlag_No then
    begin   //���Ͼ��գ����ش���Ϣ
      Result := True;
      Exit;
    end;  

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    SetLength(nBills, RecordCount);
    nIdx := 0;

    FListA.Clear;
    First;

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('D_ID').AsString;
        FZhiKa      := FieldByName('D_OID').AsString;

        FCusID      := FieldByName('O_ProID').AsString;
        FTruck      := FieldByName('O_Truck').AsString;
        FStockNo    := FieldByName('O_StockNo').AsString;
        FValue      := FieldByName('D_Value').AsFloat;
        FKZValue    := FieldByName('D_KZValue').AsFloat;

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //������

        FPoundID := FieldByName('D_PID').AsString;
        //�񵥱��
        if FPoundID = '' then
        begin
          if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
            raise Exception.Create(nOut.FData);
          FPoundID := nOut.FData;
        end;

        nDateMin := Str2Date('2000-01-01');
        //��С���ڲο�

        with FPData do
        begin
          FValue    := FieldByName('D_PValue').AsFloat;
          FDate     := FieldByName('D_PDate').AsDateTime;
          FOperator := FieldByName('D_PMan').AsString;

          if FDate < nDateMin then
            FDate := FieldByName('D_InTime').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;

        with FMData do
        begin
          FValue    := FieldByName('D_MValue').AsFloat;
          FDate     := FieldByName('D_MDate').AsDateTime;
          FOperator := FieldByName('D_MMan').AsString;

          if FDate < nDateMin then
            FDate := FieldByName('D_OutFact').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  nWorker := nil;
  try
    nWorker := gDBConnManager.GetConnection(sFlag_DB_YT, nErrNum);

    if not Assigned(nWorker) then
    begin
      nStr := Format('����[ %s ]���ݿ�ʧ��(ErrCode: %d).', [sFlag_DB_YT, nErrNum]);
      WriteLog(nStr);
      raise Exception.Create(nStr);
    end;

    if not nWorker.FConn.Connected then
      nWorker.FConn.Connected := True;
    //conn db

    FListA.Clear;
    FListA.Add('begin');
    //init sql list

    for nIdx:=Low(nBills) to High(nBills) do
    begin
      nRID := YT_NewID('DB_TURN_MATERIN', nWorker);
      //��¼���

      nSQL := MakeSQLByStr([SF('DTM_ID', nRID),
              SF('DTM_Card', nBills[nIdx].FZhiKa),
              SF('DTM_ScaleBill', nBills[nIdx].FID),

              SF('DTM_IsTBalance', '0'),
              SF('DTM_IsBalance', '0'),
              SF('DTM_IsStore', '0'),
              SF('DTM_Status', '1'),
              SF('DTM_Del', '0'),

              SF('DTM_Impur', '0'),
              SF('DTM_Corner', '0'),
              SF('DTM_Freight', '0'),
              SF('DTM_CGWeight', '0'),
              SF('DTM_CTWeight', '0'),
              SF('DTM_CNWeight', '0'),
              SF('DTM_PrintNum', '0'),
              {$IFDEF GZBSZ}
              SF('DTM_COLTYPE', '103'),
              {$ENDIF}

              SF('DTM_IsPlan', '0'),
              SF('DTM_KeepNum', '0'),
              SF('DTM_OtherNum', '0'),
              SF('DTM_ColPrice', '0'),
              SF('DTM_ColTotal', '0'),
              SF('DTM_FundWeight', '0'),

              SF('DTM_Vehicle', nBills[nIdx].FTruck),

              SF('DTM_InDate', Date2StrOracle(nBills[nIdx].FMData.FDate), sfVal),
              SF('DTM_CDate', DateTime2StrOracle(nBills[nIdx].FPData.FDate),sfVal),
              SF('DTM_TDate', DateTime2StrOracle(nBills[nIdx].FMData.FDate),sfVal),
              SF('DTM_Material', nBills[nIdx].FStockNo),
              SF('DTM_Company', nBills[nIdx].FCusID),
              SF('DTM_FIRM', gSysParam.FProvFirm),
              SF('DTM_TYPE', '101'),

              SF('DTM_RWeight', nBills[nIdx].FKZValue, sfVal),
              SF('DTM_GWeight', nBills[nIdx].FMData.FValue, sfVal),
              SF('DTM_TWeight', nBills[nIdx].FPData.FValue, sfVal),
              SF('DTM_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                   nBills[nIdx].FPData.FValue-nBills[nIdx].FKZValue, cPrecision,
                   True), sfVal)
              ], 'DB_Turn_MaterIn', '', True);
      FListA.Add(nSQL + ';'); //���Ͻ�����

      nSQL := YT_NewInsertLog(nSQL + ';', nWorker);
      FListA.Add(nSQL);
    end;

    //nWorker.FConn.BeginTrans;
    try
      nStr := 'commit;' + #13#10 +
              'exception' + #13#10 +
              ' when others then rollback; raise;' + #13#10 +
              'end;';
      FListA.Add(nStr);
      //oracle����ȷ�ύ

     gDBConnManager.WorkerExec(nWorker, FListA.Text);
     //ִ�нű�

      //nWorker.FConn.CommitTrans;
      Result := True;
    except
      on E:Exception do
      begin
        //nWorker.FConn.RollbackTrans;
        nData := 'ͬ����������ʱ��������,����: ' + E.Message;
        Exit;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

function TWorkerBusinessCommander.SyncYT_BillEdit(var nData: string): Boolean;
var nIdx: Integer;
    nWorker: PDBWorker;
    nStr, nSQL: string;
    nPrice, nVal: Double;
    nBills: TLadingBillItems;
    nDateMin, nSetDate: TDateTime;
begin
  Result := False;
  nStr := FIn.FData;

  nSQL := 'Select bill.*, plog.P_ID, ' +         //�������Ϣ
          'bcreater.U_Memo As bCreaterID, ' +    //���쿪ƱԱ���
          'pcreater.U_Memo As pCreaterID, ' +    //�����Ƥ˾��Ա
          'mcreater.U_Memo As mCreaterID  ' +    //�����ë˾��Ա
          ' From $BILL bill ' +
          ' Left Join $USER bcreater On bcreater.U_Name=bill.L_Man ' +
          ' Left Join $USER pcreater On pcreater.U_Name=bill.L_PMan ' +
          ' Left Join $USER mcreater On mcreater.U_Name=bill.L_MMan ' +
          ' Left Join $PLOG plog On plog.P_Bill=bill.L_ID ' +
          'Where L_ID In ($IN)';
  nSQL := MacroValue(nSQL, [MI('$BILL', sTable_Bill), MI('$USER', sTable_User),
          MI('$PLOG', sTable_PoundLog), MI('$IN', nStr)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '������[ %s ]��Ϣ�Ѷ�ʧ.';
      nData := Format(nData, [CombinStr(FListA, ',', False)]);
      Exit;
    end;

    First;
    nIdx := 0;
    FListA.Clear;
    SetLength(nBills, RecordCount);

    while not Eof do
    begin
      with nBills[nIdx] do
      begin
        FID         := FieldByName('L_ID').AsString;
        FZhiKa      := FieldByName('L_ZhiKa').AsString;
        FCusID      := FieldByName('L_CusID').AsString;

        FTruck      := FieldByName('L_Truck').AsString;
        FStockNo    := FieldByName('L_StockNo').AsString;
        FValue      := FieldByName('L_Value').AsFloat;

        if FListA.IndexOf(FZhiKa) < 0 then
          FListA.Add(FZhiKa);
        //������

        nDateMin := Str2Date('2000-01-01');
        //��С���ڲο�

        with FMData do
        begin
          FDate     := FieldByName('L_Date').AsDateTime;
          FOperator := FieldByName('bCreaterID').AsString;

          if FOperator = '' then
            FOperator := FieldByName('L_Man').AsString;
          //xxxx

          if FDate < nDateMin then
            FDate := FieldByName('L_OutFact').AsDateTime;
          //xxxxx

          if FDate < nDateMin then
            FDate := Date();
          //xxxxx
        end;
        //��ʱ��¼��Ʊ��Ϣ

        FYTID := FieldByName('L_YTID').AsString;
        FMemo := FieldByName('L_Memo').AsString;
      end;

      Inc(nIdx);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  nStr := AdjustListStrFormat2(FListA, '''', True, ',', False, False);
  //�����б�

  nSQL := 'select * From %s Where XCB_ID in (%s)';
  nSQL := Format(nSQL, ['XS_Card_Base', nStr]);
  //��ѯ������

  nWorker := nil;
  try
    with gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        nData := '����ϵͳ: ������[ %s ]��Ϣ�Ѷ�ʧ.';
        nData := Format(nData, [CombinStr(FListA, ',', False)]);
        Exit;
      end;

      FListA.Clear;
      FListA.Add('begin');
      //init sql list

      FListB.Clear;
      //init Local sql List

      for nIdx:=Low(nBills) to High(nBills) do
      begin
        First;
        //init cursor

        //if nBills[nIdx].FValue<=0 then Continue;
        //������Ϊ0,����Ա�Ѿ�ȷ�ϣ����豣��

        while not Eof do
        begin
          nStr := FieldByName('XCB_ID').AsString;
          if nStr = nBills[nIdx].FZhiKa then Break;
          Next;
        end;

        if Eof then Continue;
        //������ʧ���账��

        nSetDate := nBills[nIdx].FMData.FDate;
        //nSetDate

        if FIn.FExtParam = sFlag_BillNew then
        begin
          nBills[nIdx].FYTID := YT_NewID('XS_LADE_BASE', nWorker);
          //��¼���

          nSQL := MakeSQLByStr([SF('XLB_ID', nBills[nIdx].FYTID),
                  SF('XLB_LadeId', nBills[nIdx].FID),
                  SF('XLB_SetDate', Date2StrOracle(nSetDate), sfVal),
                  SF('XLB_LadeType', '103'),
                  SF('XLB_Origin', '101'),
                  SF('XLB_Client', nBills[nIdx].FCusID),
                  SF('XLB_Cement', nBills[nIdx].FStockNo),
                  SF('XLB_CementSwap', nBills[nIdx].FStockNo),
                  //SF('XLB_CementCode', nBills[nIdx].FHYDan),
                  SF('XLB_Number', nBills[nIdx].FValue, sfVal),
                  //SF('XLB_FactNum', nBills[nIdx].FValue, sfVal),

                  SF('XLB_Price', '0.00', sfVal),
                  SF('XLB_CardPrice', '0.00', sfVal),
                  SF('XLB_Total', '0.00', sfVal),
                  SF('XLB_FactTotal', '0.00', sfVal),
                  SF('XLB_ScaleDifNum', '0.00', sfVal),
                  SF('XLB_InvoNum', '0.00', sfVal),
                  SF('XLB_Area', gSysParam.FSaleArea),

                  SF('XLB_SendArea', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_CarCode', nBills[nIdx].FTruck),
                  SF('XLB_Quantity', '0', sfVal),
                  SF('XLB_PrintNum', '0', sfVal),
                  //SF('XLB_OutTime', DateTime2StrOracle(nSetDate), sfVal),
                  //SF('XLB_DoorTime', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_IsCarry', '0'),
                  SF('XLB_IsOut', '0'),
                  SF('XLB_IsCheck', '1'),
                  SF('XLB_IsDoor', '0'),
                  SF('XLB_IsBack', '0'),
                  //SF('XLB_Gather', '1'),
                  SF('XLB_IsInvo', '0'),
                  SF('XLB_Approve', '0'),
                  SF('XLB_TCollate', '0'),
                  SF('XLB_Collate', '0'),
                  SF('XLB_OutStore', '0'),
                  SF('XLB_ISTUNE', '0'),

                  SF('XLB_Firm', FieldByName('XCB_Firm').AsString),
                  SF('XLB_Status', '1'),
                  SF('XLB_Del', '0'),
                  SF('XLB_Creator', nBills[nIdx].FMData.FOperator),
                  SF('XLB_CDate', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLB_KDATE', DateTime2StrOracle(nSetDate), sfVal),
                  SF('XLB_ISONLY', FieldByName('XCB_ISONLY').AsString),
                  SF('XLB_ISSUPPLY', '0')
                  ], 'XS_Lade_Base', '', True);
          FListA.Add(nSQL + ';'); //�����������

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������

          nPrice := FieldByName('XCB_Price').AsFloat;
          nVal := nPrice * nBills[nIdx].FValue;
          nVal := Float2Float(nVal, cPrecision, True);
          //���

          nSQL := MakeSQLByStr([SF('XLD_ID', YT_NewID('XS_LADE_DETAIL', nWorker)),
                  SF('XLD_Lade', nBills[nIdx].FYTID),
                  SF('XLD_Client', nBills[nIdx].FCusID),
                  SF('XLD_Card',  nBills[nIdx].FZhiKa),
                  SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                  SF('XLD_Price', nPrice, sfVal),
                  SF('XLD_CardPrice', nPrice, sfVal),
                  SF('XLD_Gap', '0', sfVal),
                  SF('XLD_Total', nVal, sfVal),
                  SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLD_Order', '0', sfVal)
                  //SF('XLD_FactNum', '0', sfVal),
                  //SF('XLD_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                  //SF('XLD_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                  //SF('XLD_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                  //   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                  ], 'XS_Lade_Detail', '', True);
          FListA.Add(nSQL + ';'); //�����������ϸ��

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������

          nSQL := SF('L_ID', nBills[nIdx].FID);
          nSQL := MakeSQLByStr([
                  SF('L_YTID', nBills[nIdx].FYTID)
                  ],sTable_Bill, nSQL, False);
          FListB.Add(nSQL);
        end else

        if FIn.FExtParam = sFlag_BillDel then
        begin
          nSQL := SF('XLB_ID', nBills[nIdx].FYTID);
          nSQL := MakeSQLByStr([
                  SF('XLB_Del', '1')
                  ], 'XS_Lade_Base', nSQL, False);
          FListA.Add(nSQL + ';'); //�����������

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������
        end else

        if FIn.FExtParam = sFlag_BillPick then
        begin
          nPrice := FieldByName('XCB_Price').AsFloat;
          nVal := nPrice * nBills[nIdx].FValue;
          nVal := Float2Float(nVal, cPrecision, True);
          //���

          nSQL := SF('XLD_Lade', nBills[nIdx].FYTID);

          nSQL := MakeSQLByStr([SF('XLD_Client', nBills[nIdx].FCusID),
                  SF('XLD_Card',  nBills[nIdx].FZhiKa),
                  SF('XLD_Number', nBills[nIdx].FValue, sfVal),
                  SF('XLD_Price', nPrice, sfVal),
                  SF('XLD_CardPrice', nPrice, sfVal),
                  SF('XLD_Gap', '0', sfVal),
                  SF('XLD_Total', nVal, sfVal),
                  SF('XLD_PROID', FieldByName('XCB_SubLader').AsString),
                  SF('XLD_Order', '0', sfVal)
                  //SF('XLD_FactNum', '0', sfVal),
                  //SF('XLD_GWeight', nBills[nIdx].FMData.FValue, sfVal),
                  //SF('XLD_TWeight', nBills[nIdx].FPData.FValue, sfVal),
                  //SF('XLD_NWeight', Float2Float(nBills[nIdx].FMData.FValue -
                  //   nBills[nIdx].FPData.FValue, cPrecision, True), sfVal)
                  ], 'XS_Lade_Detail', nSQL, False);
          FListA.Add(nSQL + ';'); //�����������ϸ��

          nSQL := YT_NewInsertLog(nSQL+';', nWorker);
          FListA.Add(nSQL);
          //����ͬ�������
        end
      end;

      FDBConn.FConn.BeginTrans;
      try
        nStr := 'commit;' + #13#10 +
                'exception' + #13#10 +
                ' when others then rollback; raise;' + #13#10 +
                'end;';
        FListA.Add(nStr);
        //oracle����ȷ�ύ

        gDBConnManager.WorkerExec(nWorker, FListA.Text);
        //ִ�нű�

        for nIdx := 0 to FListB.Count - 1 do
          gDBConnManager.WorkerExec(FDBConn, FListB[nIdx]);
        //xxxxx

        FDBConn.FConn.CommitTrans;
        Result := True;
      except
        on E:Exception do
        begin
          FDBConn.FConn.RollbackTrans;
          nData := 'ͬ���������������ʱ��������,����: ' + E.Message;
          Exit;
        end;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
end;

//Date: 2016/8/13
//Parm: �������(FIn.FData);�µ����κ�(FIn.FExtParam)
//Desc: ��������������κ�
function TWorkerBusinessCommander.SaveLadingSealInfo(var nData: string): Boolean;
var nVal: Double;
    nIdx: Integer;
    nHasOut: Boolean;
    nWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
    nStr, nSQL, nCNO, nSNO, nComentCode, nYTID, nHYDan, nSeal: string;
begin
  Result := False;
  FListA.Clear;
  //init

  nSQL := 'Select * From %s Where L_ID=''%s''';
  nSQL := Format(nSQL, [sTable_Bill, FIn.FData]);
  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := '������[ %s ]��Ϣ�Ѷ�ʧ.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nHasOut := FieldByName('L_OutFact').AsString <> '';
    nComentCode := FieldByName('L_HYDan').AsString;
    nCNO := FieldByName('L_Seal').AsString;
    nVal := FieldByName('L_Value').AsFloat;
    nYTID:= FieldByName('L_YTID').AsString;
    nSNO := FieldByName('L_StockNO').AsString;

    FListA.Values['HYDan'] := FIn.FExtParam;
    FListA.Values['Value'] := FloatToStr(nVal);
    FListA.Values['XCB_CementName'] := FieldByName('L_StockName').AsString;
  end;

  if not TWorkerBusinessCommander.CallMe(cBC_GetYTBatchCode,
     PackerEncodeStr(FListA.Text), '', @nOut) then
  begin
    nData := nOut.FData;
    Exit;
  end; //��֤���κ���Ч�ԺͿ�����

  FListA.Text := PackerDecodeStr(nOut.FData);
  nHYDan := FListA.Values['XCB_CementCode'];
  nSeal  := FListA.Values['XCB_CementCodeID'];

  nWorker := nil;
  try
    nSQL := 'Select * From XS_Lade_Base Where  XLB_LadeId=''%s''';
    nSQL := Format(nSQL, [FIn.FData]);
    
    with gDBConnManager.SQLQuery(nSQL, nWorker, sFlag_DB_YT) do
    begin
      if RecordCount < 1 then
      begin
        nData := '����ϵͳ: ������[ %s ]��Ϣ�Ѷ�ʧ.';
        nData := Format(nData, [FIn.FData]);
        Exit;
      end;

      FListA.Clear;
      FListB.Clear;

      if nHasOut then    //�ѳ��������������ϵͳ���κ�
      begin
        FListA.Add('begin');
        //init sql list

        nSQL := SF('XLB_ID', nYTID);
        nSQL := MakeSQLByStr([
                SF('XLB_CementCode', nHYDan)
                ], 'XS_Lade_Base', nSQL, False);
        FListA.Add(nSQL + ';'); //�����������

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nSQL := SF('DTP_Lade', nYTID);
        nSQL := MakeSQLByStr([
                SF('DTP_CementCode', nHYDan)
                ], 'DB_Turn_ProduOut', nSQL, False);
        FListA.Add(nSQL + ';'); //���۳����б�

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nSQL := SF('XLM_LADE', nYTID);
        nSQL := MakeSQLByStr([
                SF('XLM_CEMENTCODE', nSeal)
                ], 'XS_Lade_CementCode', nSQL, False);
        FListA.Add(nSQL + ';'); //��������ʹ���б�

        nSQL := YT_NewInsertLog(nSQL+';', nWorker);
        FListA.Add(nSQL);
        //����ͬ�������

        nStr := 'commit;' + #13#10 +
                'exception' + #13#10 +
                ' when others then rollback; raise;' + #13#10 +
                'end;';
        FListA.Add(nStr);
        //oracle����ȷ�ύ

        nStr := 'Update %s Set C_HasDone=C_HasDone+%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nSeal]);
        nIdx := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nIdx < 1 then
        begin
          nSQL := MakeSQLByStr([
            SF('C_ID', nSeal),
            SF('C_Code', nHYDan),
            SF('C_Stock', nSNO),
            SF('C_Freeze', '0', sfVal),
            SF('C_HasDone', nVal, sfVal)
            ], sTable_YT_CodeInfo, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
        //����������;

        nStr := 'Update %s Set C_HasDone=C_HasDone-%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCNO]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
        //���¾�����

        nSQL := SF('L_ID', FIn.FData);
        nSQL := MakeSQLByStr([
                SF('L_HYDan', nHYDan),
                SF('L_Seal', nSeal)
                ],sTable_Bill, nSQL, False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end else

      begin            //δ�����������һ��ͨϵͳ���κŶ�����
        nStr := 'Update %s Set C_Freeze=C_Freeze+%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nSeal]);
        nIdx := gDBConnManager.WorkerExec(FDBConn, nStr);

        if nIdx < 1 then
        begin
          nSQL := MakeSQLByStr([
            SF('C_ID', nSeal),
            SF('C_Code', nHYDan),
            SF('C_Stock', nSNO),
            SF('C_Freeze', nVal, sfVal),
            SF('C_HasDone', '0', sfVal)
            ], sTable_YT_CodeInfo, '', True);
          gDBConnManager.WorkerExec(FDBConn, nSQL);
        end;
        //����������;

        nStr := 'Update %s Set C_Freeze=C_Freeze-%.2f Where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, nVal, nCNO]);
        gDBConnManager.WorkerExec(FDBConn, nStr);
        //���¾�����

        nSQL := SF('L_ID', FIn.FData);
        nSQL := MakeSQLByStr([
                SF('L_HYDan', nHYDan),
                SF('L_Seal', nSeal)
                ],sTable_Bill, nSQL, False);
        gDBConnManager.WorkerExec(FDBConn, nSQL);
      end;

      if FListA.Count > 0 then
        gDBConnManager.WorkerExec(nWorker, FListA.Text);
      //ִ�нű�
    end;

    Result := True;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;   
end;

function TWorkerBusinessCommander.GetYTBatchCode(var nData: string): Boolean;
var nStr: string;
    nVal: Double;
    nSelect: Boolean;
    nIdx,nInt: Integer;
    nDBWorker: PDBWorker;
begin
  Result := False;
  FListA.Text := PackerDecodeStr(FIn.FData);
  //Init

  with FListA do
  begin
    if Values['XCB_OutASH'] = '' then
    begin
      nStr := 'Select D_Value From %s Where D_Name=''%s'' And D_Memo=''%s''';
      nStr := Format(nStr, [sTable_SysDict, sFlag_SysParam, sFlag_HYPackers]);

      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      if RecordCount > 0 then
         Values['XCB_OutASH'] := Fields[0].AsString;
    end;   

    nInt := 0;
    nDBWorker := nil;
    try
      if Trim(Values['HYDan']) <> '' then  //�������κ�
      begin
        nStr := 'Select cno_count, cno_id, cno_cementcode ' +
                'From CF_Notify_OutWork ' +
                'Where (CNO_Cementcode=''%s'') AND ' +
                '      (CNO_Status = 1) AND ' +
                '      (CNO_Del = 0) AND ' +
                '      (CNO_SetDate<=Sysdate) ' +
                'order by cno_setdate ';
        nStr := Format(nStr, [Values['HYDan']]);
        with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
        if RecordCount > 0 then
        begin
          nVal := FieldByName('cno_count').AsFloat;
          Values['XCB_CementCodeID'] := FieldByName('cno_id').AsString;
          Values['XCB_CementCode'] := FieldByName('cno_cementcode').AsString;
        end
        else
        begin
          nData := '��.ˮ����: %s' + #13#10 +
                   '��.ˮ������: %s' + #13#10 +
                   '��.��������: ˮ���Ų�����,�޷���Ʊ.';
          nData := Format(nData, [Values['HYDan'],
                   Values['XCB_CementName']]);
          Exit;
        end;

        nStr := 'select C_Freeze from %s where C_ID=''%s''';
        nStr := Format(nStr, [sTable_YT_CodeInfo, Values['XCB_CementCodeID']]);

        with gDBConnManager.WorkerQuery(FDBConn, nStr) do
        begin
          if RecordCount > 0 then
            nVal := nVal - Fields[0].AsFloat;
          //�ۼ��Ѷ���
        end;

        nStr := 'select nvl(SUM(xlc.XLM_Number), 0) AS XCV_UserCount ' +
                'from XS_Lade_CementCode xlc' +
                ' LEFT OUTER JOIN XS_Lade_Base xlb on xlb.XLB_ID = xlc.XLM_Lade ' +
                'WHERE (xlc.xlm_cementcode = ''%s'') and ' +
                ' (xlb.XLB_Del = 0) AND (xlb.XLB_Status = 1) ' +
                'GROUP BY xlc.XLM_CementCode';
        //xxxxx

        nStr := Format(nStr, [Values['XCB_CementCodeID']]);
        //��ѯ�ѷ���

        with gDBConnManager.WorkerQuery(nDBWorker, nStr) do
        begin
          if RecordCount > 0 then
            nVal := nVal - FieldByName('XCV_UserCount').AsFloat;
          //�ۼ��ѷ���
        end;

        nVal := nVal - StrToFloatDef(Values['Value'], 0);
        //��ȥ���η�����

        if nVal <= 0 then
        begin
          nData := '��.ˮ����: %s' + #13#10 +
                   '��.ˮ������: %s' + #13#10 +
                   '��.��������: �ñ����������,�޷���Ʊ.';
          nData := Format(nData, [Values['HYDan'],
                   Values['XCB_CementName']]);
          Exit;
        end;

        FOut.FData := PackerEncodeStr(FListA.Text);
        Result := True;
      end else                            //��ѡ���κ�

      begin
        //----------------------------------------------------------------------
        nStr := 'select cno.cno_id,cno.cno_cementcode,cno.cno_count,cnd.cnd_OutASH from ' +
                'CF_Notify_OutWorkDtl cnd' +
                ' Left Join CF_Notify_OutWork cno On cno.cno_id=cnd.cnd_notifyid ' +
                'where (cnd.Cnd_Cement = ''%s'') and' +
                '      (cno.cno_cementcode <> '' '') and' +
                '      (cno.cno_status = 1) AND' +
                '      (cno.CNO_Del = 0) AND' +
                '      (cno.CNO_SetDate<=Sysdate)' +
                'order by cno.cno_setdate ';
        //xxxxx

        nStr := Format(nStr, [Values['XCB_Cement']]);
        //��ѯ���κż�¼

        with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
        if RecordCount > 0 then
        begin
          First;
          FListD.Clear;

          while not Eof do
          try
            nStr := FieldByName('cnd_OutASH').AsString;
            if Values['XCB_OutASH'] <> '' then
            begin
              FListB.Clear;
              SplitStr(nStr, FListB, 0, ',', False);

              FListC.Clear;
              SplitStr(Values['XCB_OutASH'], FListC, 0, ',', False);

              nSelect := False;
              for nIdx := 0 to FListB.Count-1 do
              begin
                if Length(FListB[nIdx]) < 1 then Continue;

                nSelect := FListC.IndexOf(FListB[nIdx]) >= 0;
                if nSelect then Break;
              end;

              if not nSelect then Continue;
              //����������
            end;

            FListC.Clear;
            nVal := FieldByName('cno_count').AsFloat;

            FListC.Values['XCB_CementCodeID'] := FieldByName('cno_id').AsString;
            FListC.Values['XCB_CementCode'] := FieldByName('cno_cementcode').AsString;
            FListC.Values['XCB_OutASH'] := FieldByName('cnd_OutASH').AsString;
            //��������

            nStr := 'select C_Freeze from %s where C_ID=''%s''';
            nStr := Format(nStr, [sTable_YT_CodeInfo, FListC.Values['XCB_CementCodeID']]);

            with gDBConnManager.WorkerQuery(FDBConn, nStr) do
            begin
              if RecordCount > 0 then
                nVal := nVal - Fields[0].AsFloat;
              //�ۼ��Ѷ���
            end;

            FListC.Values['XCB_CementValue']  := FloatToStr(nVal);
            //������

            if nVal > 0 then
              FListD.Add(PackerEncodeStr(FListC.Text));
            //����������0  
          finally
            Next;
          end;

          FListB.Clear;
          //����ʣ��������0�ļ�¼
        
          for nIdx := 0 to FListD.Count - 1 do
          begin
            FListC.Text := PackerDecodeStr(FListD[nIdx]);
            nVal := StrToFloatDef(FListC.Values['XCB_CementValue'], 0);

            nStr := 'select nvl(SUM(xlc.XLM_Number), 0) AS XCV_UserCount ' +
                    'from XS_Lade_CementCode xlc' +
                    ' LEFT OUTER JOIN XS_Lade_Base xlb on xlb.XLB_ID = xlc.XLM_Lade ' +
                    'WHERE (xlc.xlm_cementcode = ''%s'') and ' +
                    ' (xlb.XLB_Del = 0) AND (xlb.XLB_Status = 1) ' +
                    'GROUP BY xlc.XLM_CementCode';
            //xxxxx

            nStr := Format(nStr, [FListC.Values['XCB_CementCodeID']]);
            //��ѯ�ѷ���

            with gDBConnManager.WorkerQuery(nDBWorker, nStr) do
            begin
              if RecordCount > 0 then
                nVal := nVal - FieldByName('XCV_UserCount').AsFloat;
              //�ۼ��ѷ���
            end;

            if nVal > 0 then
            begin
              if nInt = 0 then
              begin
                Values['XCB_CementCodeID'] := FListC.Values['XCB_CementCodeID'];
                Values['XCB_CementCode'] := FListC.Values['XCB_CementCode'];
              end;

              nVal := Float2Float(nVal, cPrecision, False);
              FListC.Values['XCB_CementValue'] := FloatToStr(nVal);
              FListB.Add(PackerEncodeStr(FListC.Text));
              Inc(nInt);
            end;
          end;

          if (nInt <= 0) or (FListB.Count < 1) then
          begin
            nData := '��.ˮ����: %s' + #13#10 +
                     '��.ˮ������: %s' + #13#10 +
                     '��.��������: �޿���ˮ����,�޷���Ʊ.';
            nData := Format(nData, [Values['XCB_Cement'],
                     Values['XCB_CementName']]);
            Exit;
          end;

          Values['XCB_CementRecords'] := PackerEncodeStr(FListB.Text);
        end;

        FOut.FData := PackerEncodeStr(FListA.Text);
        Result := True;
      end;
    finally
      gDBConnManager.ReleaseConnection(nDBWorker);
    end;
  end;
end;

//Date: 2016/10/21
//Parm: �������κ�(FIn.FData)
//Desc: ͬ���������κ���Ϣ
function TWorkerBusinessCommander.SyncYT_BatchCodeInfo(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nDBWorker: PDBWorker;
begin
  FListA.Clear;
  FListB.Clear;
  Result := False;

  nDBWorker := nil;
  try
    nStr := 'Select * From v_notify_print Where CNO_Del=''0'' ';
    //��ɾ�������κŲ�ͬ��

    if FIn.FData <> '' then
    begin
      nStr := nStr + ' And Paw_analy=''%s''';
      nStr := Format(nStr, [FIn.FData]);
    end;  
    //ָ��ͬ�������κ�

    with gDBConnManager.SQLQuery(nStr, nDBWorker, sFlag_DB_YT) do
    if RecordCount > 0 then
    begin
      First;

      while not Eof do
      try
        nStr := SF('Paw_analy', FieldByName('Paw_analy').AsString);
        nStr := MakeSQLByStr([
                SF('CNO_ID', FieldByName('CNO_ID').AsString),
                SF('CNO_NotifyID', FieldByName('CNO_NotifyID').AsString),
                SF('CNO_CementCode', FieldByName('CNO_CementCode').AsString),
                SF('CNO_CementYear', FieldByName('CNO_CementYear').AsString),
                SF('CNO_PackCode', FieldByName('CNO_PackCode').AsString),
                SF('CNO_Cement', FieldByName('CNO_Cement').AsString),
                SF('CNO_Depositary', FieldByName('CNO_Depositary').AsString),
                SF('CNO_Count', FieldByName('CNO_Count').AsString),
                SF('CNO_RemainCount', FieldByName('CNO_RemainCount').AsString),
                SF('CNO_PackDate', FieldByName('CNO_PackDate').AsString),
                SF('CNO_SetDate', FieldByName('CNO_SetDate').AsString),
                SF('CNO_OperMan', FieldByName('CNO_OperMan').AsString),
                SF('CNO_ClientID', FieldByName('CNO_ClientID').AsString),
                SF('CNO_Status', FieldByName('CNO_Status').AsString),
                SF('CNO_Del', FieldByName('CNO_Del').AsString),
                SF('CNO_Creator', FieldByName('CNO_Creator').AsString),
                SF('CNO_CDate', FieldByName('CNO_CDate').AsString),
                SF('CNO_Mender', FieldByName('CNO_Mender').AsString),
                SF('CNO_MDate', FieldByName('CNO_MDate').AsString),
                SF('CNO_Firm', FieldByName('CNO_Firm').AsString),
                SF('CNO_Remark', FieldByName('CNO_Remark').AsString),

                SF('PAW_ID', FieldByName('PAW_ID').AsString),
                SF('PAW_Analy', FieldByName('PAW_Analy').AsString),
                SF('PAW_Cement', FieldByName('PAW_Cement').AsString),
                SF('PAW_Intensity', FieldByName('PAW_Intensity').AsString),
                SF('PAW_Store', FieldByName('PAW_Store').AsString),
                SF('PAW_OutDate', FieldByName('PAW_OutDate').AsString),
                SF('PAW_Outnumber', FieldByName('PAW_Outnumber').AsString),
                SF('PAW_Stability', FieldByName('PAW_Stability').AsString),
                SF('PAW_ProduDate', FieldByName('PAW_ProduDate').AsString),
                SF('PAW_MoldDate', FieldByName('PAW_MoldDate').AsString),
                SF('PAW_Cohereend', FieldByName('PAW_Cohereend').AsString),
                SF('PAW_Facttab', FieldByName('PAW_Facttab').AsString),
                SF('PAW_Thick', FieldByName('PAW_Thick').AsString),
                SF('PAW_Fine', FieldByName('PAW_Fine').AsString),
                SF('PAW_Waterash', FieldByName('PAW_Waterash').AsString),
                SF('PAW_SurfaceArea', FieldByName('PAW_SurfaceArea').AsString),
                SF('PAW_Mixture', FieldByName('PAW_Mixture').AsString),
                SF('PAW_MoldMan', FieldByName('PAW_MoldMan').AsString),
                SF('PAW_WhipMan', FieldByName('PAW_WhipMan').AsString),
                SF('PAW_CohereMan', FieldByName('PAW_CohereMan').AsString),
                SF('PAW_BreakMan', FieldByName('PAW_BreakMan').AsString),
                SF('PAW_Remark', FieldByName('PAW_Remark').AsString),
                SF('PAW_3Dcensor', FieldByName('PAW_3Dcensor').AsString),
                SF('PAW_3Dconceit', FieldByName('PAW_3Dconceit').AsString),
                SF('PAW_3DcenMan', FieldByName('PAW_3DcenMan').AsString),
                SF('PAW_3DcenDate', FieldByName('PAW_3DcenDate').AsString),
                SF('PAW_28Dcensor', FieldByName('PAW_28Dcensor').AsString),
                SF('PAW_28Dconceit', FieldByName('PAW_28Dconceit').AsString),
                SF('PAW_28DcenMan', FieldByName('PAW_28DcenMan').AsString),
                SF('PAW_28DcenDate', FieldByName('PAW_28DcenDate').AsString),
                SF('PAW_IsAudit', FieldByName('PAW_IsAudit').AsString),
                SF('PAW_AuditMan', FieldByName('PAW_AuditMan').AsString),
                SF('PAW_AuditDate', FieldByName('PAW_AuditDate').AsString),
                SF('PAW_Del', FieldByName('PAW_Del').AsString),
                SF('PAW_Creator', FieldByName('PAW_Creator').AsString),
                SF('PAW_CDate', FieldByName('PAW_CDate').AsString),
                SF('PAW_Mender', FieldByName('PAW_Mender').AsString),
                SF('PAW_MDate', FieldByName('PAW_MDate').AsString),

                SF('PAW_Temp0', FieldByName('PAW_Temp0').AsString),
                SF('PAW_Temp1', FieldByName('PAW_Temp1').AsString),
                SF('PAW_Temp2', FieldByName('PAW_Temp2').AsString),
                SF('PAW_Temp3', FieldByName('PAW_Temp3').AsString),
                SF('PAW_Temp4', FieldByName('PAW_Temp4').AsString),
                SF('PAW_Temp5', FieldByName('PAW_Temp5').AsString),
                SF('PAW_Temp6', FieldByName('PAW_Temp6').AsString),
                SF('PAW_Temp7', FieldByName('PAW_Temp7').AsString),
                SF('PAW_Temp8', FieldByName('PAW_Temp8').AsString),
                SF('PAW_Temp9', FieldByName('PAW_Temp9').AsString),

                SF('PAW_Temp10', FieldByName('PAW_Temp10').AsString),
                SF('PAW_Temp11', FieldByName('PAW_Temp11').AsString),
                SF('PAW_Temp12', FieldByName('PAW_Temp12').AsString),
                SF('PAW_Temp13', FieldByName('PAW_Temp13').AsString),
                SF('PAW_Temp14', FieldByName('PAW_Temp14').AsString),
                SF('PAW_Temp15', FieldByName('PAW_Temp15').AsString),
                SF('PAW_Temp16', FieldByName('PAW_Temp16').AsString),
                SF('PAW_Temp17', FieldByName('PAW_Temp17').AsString),
                SF('PAW_Temp18', FieldByName('PAW_Temp18').AsString),
                SF('PAW_Temp19', FieldByName('PAW_Temp19').AsString),

                SF('PAW_Temp20', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp21', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp22', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp23', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp24', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp25', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp26', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp27', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp28', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp29', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp30', FieldByName('PAW_Temp30').AsString),
                SF('PAW_Temp31', FieldByName('PAW_Temp31').AsString),
                SF('PAW_Temp32', FieldByName('PAW_Temp32').AsString),
                SF('PAW_Temp33', FieldByName('PAW_Temp33').AsString),
                SF('PAW_Temp34', FieldByName('PAW_Temp34').AsString),
                SF('PAW_Temp35', FieldByName('PAW_Temp35').AsString),
                SF('PAW_Temp36', FieldByName('PAW_Temp36').AsString),
                SF('PAW_Temp37', FieldByName('PAW_Temp37').AsString),
                SF('PAW_Temp38', FieldByName('PAW_Temp38').AsString),
                SF('PAW_Temp39', FieldByName('PAW_Temp39').AsString),

                SF('PAW_Temp40', FieldByName('PAW_Temp40').AsString),
                SF('PAW_Temp41', FieldByName('PAW_Temp41').AsString),
                SF('PAW_Temp42', FieldByName('PAW_Temp42').AsString),
                SF('PAW_Temp43', FieldByName('PAW_Temp43').AsString),
                SF('PAW_Temp44', FieldByName('PAW_Temp44').AsString),
                SF('PAW_Temp45', FieldByName('PAW_Temp45').AsString),
                SF('PAW_Temp46', FieldByName('PAW_Temp46').AsString),
                SF('PAW_Temp47', FieldByName('PAW_Temp47').AsString),
                SF('PAW_Temp48', FieldByName('PAW_Temp48').AsString),
                SF('PAW_Temp49', FieldByName('PAW_Temp49').AsString),

                SF('PAW_Temp50', FieldByName('PAW_Temp50').AsString),
                SF('PAW_Temp51', FieldByName('PAW_Temp51').AsString),
                SF('PAW_Temp52', FieldByName('PAW_Temp52').AsString),
                SF('PAW_Temp53', FieldByName('PAW_Temp53').AsString),
                SF('PAW_Temp54', FieldByName('PAW_Temp54').AsString),
                SF('PAW_Temp55', FieldByName('PAW_Temp55').AsString),
                SF('PAW_Temp56', FieldByName('PAW_Temp56').AsString),
                SF('PAW_Temp57', FieldByName('PAW_Temp57').AsString),
                SF('PAW_Temp58', FieldByName('PAW_Temp58').AsString),
                SF('PAW_Temp59', FieldByName('PAW_Temp59').AsString),

                SF('PAW_Temp60', FieldByName('PAW_Temp60').AsString),
                SF('PAW_Temp61', FieldByName('PAW_Temp61').AsString),
                SF('PAW_Temp62', FieldByName('PAW_Temp62').AsString),
                SF('PAW_Temp63', FieldByName('PAW_Temp63').AsString),
                SF('PAW_Temp64', FieldByName('PAW_Temp64').AsString),
                SF('PAW_Temp65', FieldByName('PAW_Temp65').AsString),
                SF('PAW_Temp66', FieldByName('PAW_Temp66').AsString),
                SF('PAW_Temp67', FieldByName('PAW_Temp67').AsString),
                SF('PAW_Temp68', FieldByName('PAW_Temp68').AsString),
                SF('PAW_Temp69', FieldByName('PAW_Temp69').AsString),

                SF('PAW_Temp70', FieldByName('PAW_Temp70').AsString),
                SF('PAW_Temp71', FieldByName('PAW_Temp71').AsString),
                SF('PAW_Temp72', FieldByName('PAW_Temp72').AsString),
                SF('PAW_Temp73', FieldByName('PAW_Temp73').AsString),
                SF('PAW_Temp74', FieldByName('PAW_Temp74').AsString),
                SF('PAW_Temp75', FieldByName('PAW_Temp75').AsString),
                SF('PAW_Temp76', FieldByName('PAW_Temp76').AsString),
                SF('PAW_Temp77', FieldByName('PAW_Temp77').AsString),
                SF('PAW_Temp78', FieldByName('PAW_Temp78').AsString),
                SF('PAW_Temp79', FieldByName('PAW_Temp79').AsString),

                SF('PAW_Temp80', FieldByName('PAW_Temp80').AsString),
                SF('PAW_Temp81', FieldByName('PAW_Temp81').AsString),
                SF('PAW_Temp82', FieldByName('PAW_Temp82').AsString),
                SF('PAW_Temp83', FieldByName('PAW_Temp83').AsString),
                SF('PAW_Temp84', FieldByName('PAW_Temp84').AsString),
                SF('PAW_Temp85', FieldByName('PAW_Temp85').AsString),
                SF('PAW_Temp86', FieldByName('PAW_Temp86').AsString),
                SF('PAW_Temp87', FieldByName('PAW_Temp87').AsString),
                SF('PAW_Temp88', FieldByName('PAW_Temp88').AsString),
                SF('PAW_Temp89', FieldByName('PAW_Temp89').AsString),

                SF('PAW_Temp90', FieldByName('PAW_Temp90').AsString),
                SF('PAW_Temp91', FieldByName('PAW_Temp91').AsString),
                SF('PAW_Temp92', FieldByName('PAW_Temp92').AsString),
                SF('PAW_Temp93', FieldByName('PAW_Temp93').AsString),
                SF('PAW_Temp94', FieldByName('PAW_Temp94').AsString),
                SF('PAW_Temp95', FieldByName('PAW_Temp95').AsString),
                SF('PAW_Temp96', FieldByName('PAW_Temp96').AsString),
                SF('PAW_Temp97', FieldByName('PAW_Temp97').AsString),
                SF('PAW_Temp98', FieldByName('PAW_Temp98').AsString),
                SF('PAW_Temp99', FieldByName('PAW_Temp99').AsString),

                SF('PAW_Temp100', FieldByName('PAW_Temp100').AsString),
                SF('PAW_Temp101', FieldByName('PAW_Temp101').AsString),
                SF('PAW_Temp102', FieldByName('PAW_Temp102').AsString),
                SF('PAW_Temp103', FieldByName('PAW_Temp103').AsString),
                SF('PAW_Temp104', FieldByName('PAW_Temp104').AsString),
                SF('PAW_Temp105', FieldByName('PAW_Temp105').AsString),
                SF('PAW_Temp106', FieldByName('PAW_Temp106').AsString),
                SF('PAW_Temp107', FieldByName('PAW_Temp107').AsString),
                SF('PAW_Temp108', FieldByName('PAW_Temp108').AsString),
                SF('PAW_Temp109', FieldByName('PAW_Temp109').AsString),

                SF('PAW_Temp110', FieldByName('PAW_Temp110').AsString),
                SF('PAW_Temp111', FieldByName('PAW_Temp111').AsString),
                SF('PAW_Temp112', FieldByName('PAW_Temp112').AsString),
                SF('PAW_Temp113', FieldByName('PAW_Temp113').AsString),
                SF('PAW_Temp114', FieldByName('PAW_Temp114').AsString),
                SF('PAW_Temp115', FieldByName('PAW_Temp115').AsString),
                SF('PAW_Temp116', FieldByName('PAW_Temp116').AsString),
                SF('PAW_Temp117', FieldByName('PAW_Temp117').AsString),
                SF('PAW_Temp118', FieldByName('PAW_Temp118').AsString),
                SF('PAW_Temp119', FieldByName('PAW_Temp119').AsString),

                SF('PAW_Temp120', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp121', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp122', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp123', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp124', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp125', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp126', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp127', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp128', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp129', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp130', FieldByName('PAW_Temp130').AsString),
                SF('PAW_Temp131', FieldByName('PAW_Temp131').AsString),
                SF('PAW_Temp132', FieldByName('PAW_Temp132').AsString),
                SF('PAW_Temp133', FieldByName('PAW_Temp133').AsString),
                SF('PAW_Temp134', FieldByName('PAW_Temp134').AsString),
                SF('PAW_Temp135', FieldByName('PAW_Temp135').AsString),
                SF('PAW_Temp136', FieldByName('PAW_Temp136').AsString),
                SF('PAW_Temp137', FieldByName('PAW_Temp137').AsString),
                SF('PAW_Temp138', FieldByName('PAW_Temp138').AsString),
                SF('PAW_Temp139', FieldByName('PAW_Temp139').AsString)
                ],sTable_YT_Batchcode, nStr, False);
        //������Ϣ
        FListA.Add(nStr);
        //�ȸ��£�����ʧ�������

        nStr := MakeSQLByStr([
                SF('CNO_ID', FieldByName('CNO_ID').AsString),
                SF('CNO_NotifyID', FieldByName('CNO_NotifyID').AsString),
                SF('CNO_CementCode', FieldByName('CNO_CementCode').AsString),
                SF('CNO_CementYear', FieldByName('CNO_CementYear').AsString),
                SF('CNO_PackCode', FieldByName('CNO_PackCode').AsString),
                SF('CNO_Cement', FieldByName('CNO_Cement').AsString),
                SF('CNO_Depositary', FieldByName('CNO_Depositary').AsString),
                SF('CNO_Count', FieldByName('CNO_Count').AsString),
                SF('CNO_RemainCount', FieldByName('CNO_RemainCount').AsString),
                SF('CNO_PackDate', FieldByName('CNO_PackDate').AsString),
                SF('CNO_SetDate', FieldByName('CNO_SetDate').AsString),
                SF('CNO_OperMan', FieldByName('CNO_OperMan').AsString),
                SF('CNO_ClientID', FieldByName('CNO_ClientID').AsString),
                SF('CNO_Status', FieldByName('CNO_Status').AsString),
                SF('CNO_Del', FieldByName('CNO_Del').AsString),
                SF('CNO_Creator', FieldByName('CNO_Creator').AsString),
                SF('CNO_CDate', FieldByName('CNO_CDate').AsString),
                SF('CNO_Mender', FieldByName('CNO_Mender').AsString),
                SF('CNO_MDate', FieldByName('CNO_MDate').AsString),
                SF('CNO_Firm', FieldByName('CNO_Firm').AsString),
                SF('CNO_Remark', FieldByName('CNO_Remark').AsString),

                SF('PAW_ID', FieldByName('PAW_ID').AsString),
                SF('PAW_Analy', FieldByName('PAW_Analy').AsString),
                SF('PAW_Cement', FieldByName('PAW_Cement').AsString),
                SF('PAW_Intensity', FieldByName('PAW_Intensity').AsString),
                SF('PAW_Store', FieldByName('PAW_Store').AsString),
                SF('PAW_OutDate', FieldByName('PAW_OutDate').AsString),
                SF('PAW_Outnumber', FieldByName('PAW_Outnumber').AsString),
                SF('PAW_Stability', FieldByName('PAW_Stability').AsString),
                SF('PAW_ProduDate', FieldByName('PAW_ProduDate').AsString),
                SF('PAW_MoldDate', FieldByName('PAW_MoldDate').AsString),
                SF('PAW_Cohereend', FieldByName('PAW_Cohereend').AsString),
                SF('PAW_Facttab', FieldByName('PAW_Facttab').AsString),
                SF('PAW_Thick', FieldByName('PAW_Thick').AsString),
                SF('PAW_Fine', FieldByName('PAW_Fine').AsString),
                SF('PAW_Waterash', FieldByName('PAW_Waterash').AsString),
                SF('PAW_SurfaceArea', FieldByName('PAW_SurfaceArea').AsString),
                SF('PAW_Mixture', FieldByName('PAW_Mixture').AsString),
                SF('PAW_MoldMan', FieldByName('PAW_MoldMan').AsString),
                SF('PAW_WhipMan', FieldByName('PAW_WhipMan').AsString),
                SF('PAW_CohereMan', FieldByName('PAW_CohereMan').AsString),
                SF('PAW_BreakMan', FieldByName('PAW_BreakMan').AsString),
                SF('PAW_Remark', FieldByName('PAW_Remark').AsString),
                SF('PAW_3Dcensor', FieldByName('PAW_3Dcensor').AsString),
                SF('PAW_3Dconceit', FieldByName('PAW_3Dconceit').AsString),
                SF('PAW_3DcenMan', FieldByName('PAW_3DcenMan').AsString),
                SF('PAW_3DcenDate', FieldByName('PAW_3DcenDate').AsString),
                SF('PAW_28Dcensor', FieldByName('PAW_28Dcensor').AsString),
                SF('PAW_28Dconceit', FieldByName('PAW_28Dconceit').AsString),
                SF('PAW_28DcenMan', FieldByName('PAW_28DcenMan').AsString),
                SF('PAW_28DcenDate', FieldByName('PAW_28DcenDate').AsString),
                SF('PAW_IsAudit', FieldByName('PAW_IsAudit').AsString),
                SF('PAW_AuditMan', FieldByName('PAW_AuditMan').AsString),
                SF('PAW_AuditDate', FieldByName('PAW_AuditDate').AsString),
                SF('PAW_Del', FieldByName('PAW_Del').AsString),
                SF('PAW_Creator', FieldByName('PAW_Creator').AsString),
                SF('PAW_CDate', FieldByName('PAW_CDate').AsString),
                SF('PAW_Mender', FieldByName('PAW_Mender').AsString),
                SF('PAW_MDate', FieldByName('PAW_MDate').AsString),

                SF('PAW_Temp0', FieldByName('PAW_Temp0').AsString),
                SF('PAW_Temp1', FieldByName('PAW_Temp1').AsString),
                SF('PAW_Temp2', FieldByName('PAW_Temp2').AsString),
                SF('PAW_Temp3', FieldByName('PAW_Temp3').AsString),
                SF('PAW_Temp4', FieldByName('PAW_Temp4').AsString),
                SF('PAW_Temp5', FieldByName('PAW_Temp5').AsString),
                SF('PAW_Temp6', FieldByName('PAW_Temp6').AsString),
                SF('PAW_Temp7', FieldByName('PAW_Temp7').AsString),
                SF('PAW_Temp8', FieldByName('PAW_Temp8').AsString),
                SF('PAW_Temp9', FieldByName('PAW_Temp9').AsString),

                SF('PAW_Temp10', FieldByName('PAW_Temp10').AsString),
                SF('PAW_Temp11', FieldByName('PAW_Temp11').AsString),
                SF('PAW_Temp12', FieldByName('PAW_Temp12').AsString),
                SF('PAW_Temp13', FieldByName('PAW_Temp13').AsString),
                SF('PAW_Temp14', FieldByName('PAW_Temp14').AsString),
                SF('PAW_Temp15', FieldByName('PAW_Temp15').AsString),
                SF('PAW_Temp16', FieldByName('PAW_Temp16').AsString),
                SF('PAW_Temp17', FieldByName('PAW_Temp17').AsString),
                SF('PAW_Temp18', FieldByName('PAW_Temp18').AsString),
                SF('PAW_Temp19', FieldByName('PAW_Temp19').AsString),

                SF('PAW_Temp20', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp21', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp22', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp23', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp24', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp25', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp26', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp27', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp28', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp29', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp30', FieldByName('PAW_Temp30').AsString),
                SF('PAW_Temp31', FieldByName('PAW_Temp31').AsString),
                SF('PAW_Temp32', FieldByName('PAW_Temp32').AsString),
                SF('PAW_Temp33', FieldByName('PAW_Temp33').AsString),
                SF('PAW_Temp34', FieldByName('PAW_Temp34').AsString),
                SF('PAW_Temp35', FieldByName('PAW_Temp35').AsString),
                SF('PAW_Temp36', FieldByName('PAW_Temp36').AsString),
                SF('PAW_Temp37', FieldByName('PAW_Temp37').AsString),
                SF('PAW_Temp38', FieldByName('PAW_Temp38').AsString),
                SF('PAW_Temp39', FieldByName('PAW_Temp39').AsString),

                SF('PAW_Temp40', FieldByName('PAW_Temp40').AsString),
                SF('PAW_Temp41', FieldByName('PAW_Temp41').AsString),
                SF('PAW_Temp42', FieldByName('PAW_Temp42').AsString),
                SF('PAW_Temp43', FieldByName('PAW_Temp43').AsString),
                SF('PAW_Temp44', FieldByName('PAW_Temp44').AsString),
                SF('PAW_Temp45', FieldByName('PAW_Temp45').AsString),
                SF('PAW_Temp46', FieldByName('PAW_Temp46').AsString),
                SF('PAW_Temp47', FieldByName('PAW_Temp47').AsString),
                SF('PAW_Temp48', FieldByName('PAW_Temp48').AsString),
                SF('PAW_Temp49', FieldByName('PAW_Temp49').AsString),

                SF('PAW_Temp50', FieldByName('PAW_Temp50').AsString),
                SF('PAW_Temp51', FieldByName('PAW_Temp51').AsString),
                SF('PAW_Temp52', FieldByName('PAW_Temp52').AsString),
                SF('PAW_Temp53', FieldByName('PAW_Temp53').AsString),
                SF('PAW_Temp54', FieldByName('PAW_Temp54').AsString),
                SF('PAW_Temp55', FieldByName('PAW_Temp55').AsString),
                SF('PAW_Temp56', FieldByName('PAW_Temp56').AsString),
                SF('PAW_Temp57', FieldByName('PAW_Temp57').AsString),
                SF('PAW_Temp58', FieldByName('PAW_Temp58').AsString),
                SF('PAW_Temp59', FieldByName('PAW_Temp59').AsString),

                SF('PAW_Temp60', FieldByName('PAW_Temp60').AsString),
                SF('PAW_Temp61', FieldByName('PAW_Temp61').AsString),
                SF('PAW_Temp62', FieldByName('PAW_Temp62').AsString),
                SF('PAW_Temp63', FieldByName('PAW_Temp63').AsString),
                SF('PAW_Temp64', FieldByName('PAW_Temp64').AsString),
                SF('PAW_Temp65', FieldByName('PAW_Temp65').AsString),
                SF('PAW_Temp66', FieldByName('PAW_Temp66').AsString),
                SF('PAW_Temp67', FieldByName('PAW_Temp67').AsString),
                SF('PAW_Temp68', FieldByName('PAW_Temp68').AsString),
                SF('PAW_Temp69', FieldByName('PAW_Temp69').AsString),

                SF('PAW_Temp70', FieldByName('PAW_Temp70').AsString),
                SF('PAW_Temp71', FieldByName('PAW_Temp71').AsString),
                SF('PAW_Temp72', FieldByName('PAW_Temp72').AsString),
                SF('PAW_Temp73', FieldByName('PAW_Temp73').AsString),
                SF('PAW_Temp74', FieldByName('PAW_Temp74').AsString),
                SF('PAW_Temp75', FieldByName('PAW_Temp75').AsString),
                SF('PAW_Temp76', FieldByName('PAW_Temp76').AsString),
                SF('PAW_Temp77', FieldByName('PAW_Temp77').AsString),
                SF('PAW_Temp78', FieldByName('PAW_Temp78').AsString),
                SF('PAW_Temp79', FieldByName('PAW_Temp79').AsString),

                SF('PAW_Temp80', FieldByName('PAW_Temp80').AsString),
                SF('PAW_Temp81', FieldByName('PAW_Temp81').AsString),
                SF('PAW_Temp82', FieldByName('PAW_Temp82').AsString),
                SF('PAW_Temp83', FieldByName('PAW_Temp83').AsString),
                SF('PAW_Temp84', FieldByName('PAW_Temp84').AsString),
                SF('PAW_Temp85', FieldByName('PAW_Temp85').AsString),
                SF('PAW_Temp86', FieldByName('PAW_Temp86').AsString),
                SF('PAW_Temp87', FieldByName('PAW_Temp87').AsString),
                SF('PAW_Temp88', FieldByName('PAW_Temp88').AsString),
                SF('PAW_Temp89', FieldByName('PAW_Temp89').AsString),

                SF('PAW_Temp90', FieldByName('PAW_Temp90').AsString),
                SF('PAW_Temp91', FieldByName('PAW_Temp91').AsString),
                SF('PAW_Temp92', FieldByName('PAW_Temp92').AsString),
                SF('PAW_Temp93', FieldByName('PAW_Temp93').AsString),
                SF('PAW_Temp94', FieldByName('PAW_Temp94').AsString),
                SF('PAW_Temp95', FieldByName('PAW_Temp95').AsString),
                SF('PAW_Temp96', FieldByName('PAW_Temp96').AsString),
                SF('PAW_Temp97', FieldByName('PAW_Temp97').AsString),
                SF('PAW_Temp98', FieldByName('PAW_Temp98').AsString),
                SF('PAW_Temp99', FieldByName('PAW_Temp99').AsString),

                SF('PAW_Temp100', FieldByName('PAW_Temp100').AsString),
                SF('PAW_Temp101', FieldByName('PAW_Temp101').AsString),
                SF('PAW_Temp102', FieldByName('PAW_Temp102').AsString),
                SF('PAW_Temp103', FieldByName('PAW_Temp103').AsString),
                SF('PAW_Temp104', FieldByName('PAW_Temp104').AsString),
                SF('PAW_Temp105', FieldByName('PAW_Temp105').AsString),
                SF('PAW_Temp106', FieldByName('PAW_Temp106').AsString),
                SF('PAW_Temp107', FieldByName('PAW_Temp107').AsString),
                SF('PAW_Temp108', FieldByName('PAW_Temp108').AsString),
                SF('PAW_Temp109', FieldByName('PAW_Temp109').AsString),

                SF('PAW_Temp110', FieldByName('PAW_Temp110').AsString),
                SF('PAW_Temp111', FieldByName('PAW_Temp111').AsString),
                SF('PAW_Temp112', FieldByName('PAW_Temp112').AsString),
                SF('PAW_Temp113', FieldByName('PAW_Temp113').AsString),
                SF('PAW_Temp114', FieldByName('PAW_Temp114').AsString),
                SF('PAW_Temp115', FieldByName('PAW_Temp115').AsString),
                SF('PAW_Temp116', FieldByName('PAW_Temp116').AsString),
                SF('PAW_Temp117', FieldByName('PAW_Temp117').AsString),
                SF('PAW_Temp118', FieldByName('PAW_Temp118').AsString),
                SF('PAW_Temp119', FieldByName('PAW_Temp119').AsString),

                SF('PAW_Temp120', FieldByName('PAW_Temp20').AsString),
                SF('PAW_Temp121', FieldByName('PAW_Temp21').AsString),
                SF('PAW_Temp122', FieldByName('PAW_Temp22').AsString),
                SF('PAW_Temp123', FieldByName('PAW_Temp23').AsString),
                SF('PAW_Temp124', FieldByName('PAW_Temp24').AsString),
                SF('PAW_Temp125', FieldByName('PAW_Temp25').AsString),
                SF('PAW_Temp126', FieldByName('PAW_Temp26').AsString),
                SF('PAW_Temp127', FieldByName('PAW_Temp27').AsString),
                SF('PAW_Temp128', FieldByName('PAW_Temp28').AsString),
                SF('PAW_Temp129', FieldByName('PAW_Temp29').AsString),

                SF('PAW_Temp130', FieldByName('PAW_Temp130').AsString),
                SF('PAW_Temp131', FieldByName('PAW_Temp131').AsString),
                SF('PAW_Temp132', FieldByName('PAW_Temp132').AsString),
                SF('PAW_Temp133', FieldByName('PAW_Temp133').AsString),
                SF('PAW_Temp134', FieldByName('PAW_Temp134').AsString),
                SF('PAW_Temp135', FieldByName('PAW_Temp135').AsString),
                SF('PAW_Temp136', FieldByName('PAW_Temp136').AsString),
                SF('PAW_Temp137', FieldByName('PAW_Temp137').AsString),
                SF('PAW_Temp138', FieldByName('PAW_Temp138').AsString),
                SF('PAW_Temp139', FieldByName('PAW_Temp139').AsString)
                ],sTable_YT_Batchcode, '', True);
        //������Ϣ

        nIdx := FListA.Count - 1;
        FListB.Values['Index_' + IntToStr(nIdx)] := PackerEncodeStr(nStr);
        //����ʧ���������Ϣ
      finally
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;

  if FListA.Count > 0 then
  try
    FDBConn.FConn.BeginTrans;

    for nIdx:=0 to FListA.Count - 1 do
    if gDBConnManager.WorkerExec(FDBConn, FListA[nIdx]) < 1 then
      gDBConnManager.WorkerExec(FDBConn, PackerDecodeStr(FListB.Values['Index_' + IntToStr(nIdx)]));
    FDBConn.FConn.CommitTrans;

    Result := True;
  except
    if FDBConn.FConn.InTransaction then
      FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;


//------------------------------------------------------------------------------
class function TWorkerBusinessOrders.FunctionName: string;
begin
  Result := sBus_BusinessPurchaseOrder;
end;

constructor TWorkerBusinessOrders.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  inherited;
end;

destructor TWorkerBusinessOrders.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  inherited;
end;

function TWorkerBusinessOrders.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessCommand;
  end;
end;

procedure TWorkerBusinessOrders.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2015-8-5
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TWorkerBusinessOrders.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;

  case FIn.FCommand of
   cBC_SaveOrder            : Result := SaveOrder(nData);
   cBC_DeleteOrder          : Result := DeleteOrder(nData);
   cBC_SaveOrderBase        : Result := SaveOrderBase(nData);
   cBC_DeleteOrderBase      : Result := DeleteOrderBase(nData);
   cBC_SaveOrderCard        : Result := SaveOrderCard(nData);
   cBC_LogoffOrderCard      : Result := LogoffOrderCard(nData);
   cBC_ModifyBillTruck      : Result := ChangeOrderTruck(nData);
   cBC_GetPostOrders        : Result := GetPostOrderItems(nData);
   cBC_SavePostOrders       : Result := SavePostOrderItems(nData);
   cBC_GetGYOrderValue      : Result := GetGYOrderValue(nData);
   else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Invalid Command).';
    end;
  end;
end;

function TWorkerBusinessOrders.SaveOrderBase(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderBase;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('B_ID', nOut.FData),
            SF('B_BStatus', FListA.Values['IsValid']),

            SF('B_Project', FListA.Values['Project']),
            SF('B_Area', FListA.Values['Area']),

            SF('B_Value', StrToFloat(FListA.Values['Value']),sfVal),
            SF('B_RestValue', StrToFloat(FListA.Values['Value']),sfVal),
            SF('B_LimValue', StrToFloat(FListA.Values['LimValue']),sfVal),
            SF('B_WarnValue', StrToFloat(FListA.Values['WarnValue']),sfVal),

            SF('B_SentValue', 0,sfVal),
            SF('B_FreezeValue', 0,sfVal),

            SF('B_ProID', FListA.Values['ProviderID']),
            SF('B_ProName', FListA.Values['ProviderName']),
            SF('B_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('B_SaleID', FListA.Values['SaleID']),
            SF('B_SaleMan', FListA.Values['SaleMan']),
            SF('B_SalePY', GetPinYinOfStr(FListA.Values['SaleMan'])),

            SF('B_StockType', sFlag_San),
            SF('B_StockNo', FListA.Values['StockNO']),
            SF('B_StockName', FListA.Values['StockName']),

            SF('B_Man', FIn.FBase.FFrom.FUser),
            SF('B_Date', sField_SQLServer_Now, sfVal)
            ], sTable_OrderBase, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

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
end;
//------------------------------------------------------------------------------
//Date: 2015/9/19
//Parm: 
//Desc: ɾ���ɹ����뵥
function TWorkerBusinessOrders.DeleteOrderBase(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where O_BID=''%s''';
  nStr := Format(nStr, [sTable_Order, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '�ɹ����뵥[ %s ]��ʹ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_OrderBase]);
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
    nStr := MacroValue(nStr, [MI('$OB', sTable_OrderBaseBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_OrderBase), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where B_ID=''%s''';
    nStr := Format(nStr, [sTable_OrderBase, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//------------------------------------------------------------------------------
//Date: 2015/9/20
//Parm: 
//Desc: ��ȡ��Ӧ���ջ���
function TWorkerBusinessOrders.GetGYOrderValue(var nData: string): Boolean;
var nSQL: string;
    nVal, nSent, nLim, nWarn, nFreeze,nMax: Double;
begin
  Result := False;
  //init

  nSQL := 'Select B_Value,B_SentValue,B_RestValue, ' +
          'B_LimValue,B_WarnValue,B_FreezeValue ' +
          'From $OrderBase b1 inner join $Order o1 on b1.B_ID=o1.O_BID ' +
          'Where O_ID=''$ID''';
  nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
          MI('$Order', sTable_Order), MI('$ID', FIn.FData)]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount<1 then
    begin
      nData := '�ɹ����뵥[%s]��Ϣ�Ѷ�ʧ';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;

    nVal    := FieldByName('B_Value').AsFloat;
    nSent   := FieldByName('B_SentValue').AsFloat;
    nLim    := FieldByName('B_LimValue').AsFloat;
    nWarn   := FieldByName('B_WarnValue').AsFloat;
    nFreeze := FieldByName('B_FreezeValue').AsFloat;

    nMax := nVal - nSent - nFreeze;
  end;  

  with FListB do
  begin
    Clear;

    if nVal>0 then
         Values['NOLimite'] := sFlag_No
    else Values['NOLimite'] := sFlag_Yes;

    Values['MaxValue']    := FloatToStr(nMax);
    Values['LimValue']    := FloatToStr(nLim);
    Values['WarnValue']   := FloatToStr(nWarn);
    Values['FreezeValue'] := FloatToStr(nFreeze);
  end;

  FOut.FData := PackerEncodeStr(FListB.Text);
  Result := True;
end;  


//Date: 2015-8-5
//Desc: ����ɹ���
function TWorkerBusinessOrders.SaveOrder(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nVal: Double;
    nOut: TWorkerBusinessCommand;
begin
  FListA.Text := PackerDecodeStr(FIn.FData);
  nVal := StrToFloat(FListA.Values['Value']);
  //unpack Order

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    FOut.FData := '';
    //bill list

    FListC.Values['Group'] :=sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_Order;
    //to get serial no

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
          FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := FOut.FData + nOut.FData + ',';
    //combine Order

    nStr := MakeSQLByStr([SF('O_ID', nOut.FData),

            SF('O_CType', FListA.Values['CardType']),
            SF('O_Project', FListA.Values['Project']),
            SF('O_Area', FListA.Values['Area']),

            SF('O_BID', FListA.Values['SQID']),
            SF('O_Value', nVal,sfVal),

            SF('O_ProID', FListA.Values['ProviderID']),
            SF('O_ProName', FListA.Values['ProviderName']),
            SF('O_ProPY', GetPinYinOfStr(FListA.Values['ProviderName'])),

            SF('O_SaleID', FListA.Values['SaleID']),
            SF('O_SaleMan', FListA.Values['SaleMan']),
            SF('O_SalePY', GetPinYinOfStr(FListA.Values['SaleMan'])),

            SF('O_Type', sFlag_San),
            SF('O_StockNo', FListA.Values['StockNO']),
            SF('O_StockName', FListA.Values['StockName']),

            SF('O_Truck', FListA.Values['Truck']),
            SF('O_Man', FIn.FBase.FFrom.FUser),
            SF('O_Date', sField_SQLServer_Now, sfVal)
            ], sTable_Order, '', True);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    if FListA.Values['CardType'] = sFlag_OrderCardL then
    begin
      nStr := 'Update %s Set B_FreezeValue=B_FreezeValue+%.2f ' +
              'Where B_ID = ''%s'' and B_Value>0';
      nStr := Format(nStr, [sTable_OrderBase, nVal,FListA.Values['SQID']]);
      gDBConnManager.WorkerExec(FDBConn, nStr);
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
end;

//Date: 2015-8-5
//Desc: ����ɹ���
function TWorkerBusinessOrders.DeleteOrder(var nData: string): Boolean;
var nStr,nP: string;
    nIdx: Integer;
begin
  Result := False;
  //init

  nStr := 'Select Count(*) From %s Where D_OID=''%s''';
  nStr := Format(nStr, [sTable_OrderDtl, FIn.FData]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if Fields[0].AsInteger > 0 then
    begin
      nData := '�ɹ���[ %s ]��ʹ��.';
      nData := Format(nData, [FIn.FData]);
      Exit;
    end;
  end;

  FDBConn.FConn.BeginTrans;
  try
    //--------------------------------------------------------------------------
    nStr := Format('Select * From %s Where 1<>1', [sTable_Order]);
    //only for fields
    nP := '';

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    begin
      for nIdx:=0 to FieldCount - 1 do
       if (Fields[nIdx].DataType <> ftAutoInc) and
          (Pos('O_Del', Fields[nIdx].FieldName) < 1) then
        nP := nP + Fields[nIdx].FieldName + ',';
      //�����ֶ�,������ɾ��

      System.Delete(nP, Length(nP), 1);
    end;

    nStr := 'Insert Into $OB($FL,O_DelMan,O_DelDate) ' +
            'Select $FL,''$User'',$Now From $OO Where O_ID=''$ID''';
    nStr := MacroValue(nStr, [MI('$OB', sTable_OrderBak),
            MI('$FL', nP), MI('$User', FIn.FBase.FFrom.FUser),
            MI('$Now', sField_SQLServer_Now),
            MI('$OO', sTable_Order), MI('$ID', FIn.FData)]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Delete From %s Where O_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    FDBConn.FConn.CommitTrans;
    Result := True;
  except
    FDBConn.FConn.RollbackTrans;
    raise;
  end;
end;

//Date: 2014-09-17
//Parm: �ɹ�����[FIn.FData];�ſ���[FIn.FExtParam]
//Desc: Ϊ�ɹ����󶨴ſ�
function TWorkerBusinessOrders.SaveOrderCard(var nData: string): Boolean;
var nStr,nSQL,nTruck: string;
begin
  Result := False;
  nTruck := '';

  FListB.Text := FIn.FExtParam;
  //�ſ��б�
  nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
  //�ɹ����б�

  nSQL := 'Select O_ID,O_Card,O_Truck From %s Where O_ID In (%s)';
  nSQL := Format(nSQL, [sTable_Order, nStr]);

  with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
  begin
    if RecordCount < 1 then
    begin
      nData := Format('�ɹ�����[ %s ]�Ѷ�ʧ.', [FIn.FData]);
      Exit;
    end;

    First;
    while not Eof do
    begin
      nStr := FieldByName('O_Truck').AsString;
      if (nTruck <> '') and (nStr <> nTruck) then
      begin
        nData := '�ɹ���[ %s ]�ĳ��ƺŲ�һ��,���ܲ���.' + #13#10#13#10 +
                 '*.��������: %s' + #13#10 +
                 '*.��������: %s' + #13#10#13#10 +
                 '��ͬ�ƺŲ��ܲ���,���޸ĳ��ƺ�,���ߵ����쿨.';
        nData := Format(nData, [FieldByName('O_ID').AsString, nStr, nTruck]);
        Exit;
      end;

      if nTruck = '' then
        nTruck := nStr;
      //xxxxx

      nStr := FieldByName('O_Card').AsString;
      //����ʹ�õĴſ�

      if (nStr <> '') and (FListB.IndexOf(nStr) < 0) then
        FListB.Add(nStr);
      Next;
    end;
  end;

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    if FIn.FData <> '' then
    begin
      nSQL := 'Update %s Set O_Card=Null Where O_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nSQL := 'Update %s Set D_Card=Null Where D_Card=''%s''';
      nSQL := Format(nSQL, [sTable_OrderDtl, FIn.FExtParam]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nSQL := 'Update %s Set C_Status=''%s'', C_Used=Null Where C_Card=''%s''';
      nSQL := Format(nSQL, [sTable_Card, sFlag_CardInvalid, FIn.FExtParam]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nStr := AdjustListStrFormat(FIn.FData, '''', True, ',', False);
      //���¼����б�

      nSQL := 'Update %s Set O_Card=''%s'' Where O_ID In(%s)';
      nSQL := Format(nSQL, [sTable_Order, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);

      nSQL := 'Update %s Set D_Card=''%s'' Where D_OID In(%s) and D_OutFact Is NULL';
      nSQL := Format(nSQL, [sTable_OrderDtl, FIn.FExtParam, nStr]);
      gDBConnManager.WorkerExec(FDBConn, nSQL);
    end;

    nStr := 'Select Count(*) From %s Where C_Card=''%s''';
    nStr := Format(nStr, [sTable_Card, FIn.FExtParam]);

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if Fields[0].AsInteger < 1 then
    begin
      nStr := MakeSQLByStr([SF('C_Card', FIn.FExtParam),
              SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
              SF('C_Freeze', sFlag_No),
              SF('C_Man', FIn.FBase.FFrom.FUser),
              SF('C_Date', sField_SQLServer_Now, sfVal)
              ], sTable_Card, '', True);
      gDBConnManager.WorkerExec(FDBConn, nStr);
    end else
    begin
      nStr := Format('C_Card=''%s''', [FIn.FExtParam]);
      nStr := MakeSQLByStr([SF('C_Status', sFlag_CardUsed),
              SF('C_Used', sFlag_Provide),
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

//Date: 2015-8-5
//Desc: ����ɹ���
function TWorkerBusinessOrders.LogoffOrderCard(var nData: string): Boolean;
var nStr: string;
begin
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Card=Null Where O_Card=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);

    nStr := 'Update %s Set D_Card=Null Where D_Card=''%s''';
    nStr := Format(nStr, [sTable_OrderDtl, FIn.FData]);
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

function TWorkerBusinessOrders.ChangeOrderTruck(var nData: string): Boolean;
var nStr: string;
begin
  //Result := False;
  //Init

  //----------------------------------------------------------------------------
  FDBConn.FConn.BeginTrans;
  try
    nStr := 'Update %s Set O_Truck=''%s'' Where O_ID=''%s''';
    nStr := Format(nStr, [sTable_Order, FIn.FExtParam, FIn.FData]);
    gDBConnManager.WorkerExec(FDBConn, nStr);
    //�����޸���Ϣ

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
function TWorkerBusinessOrders.GetPostOrderItems(var nData: string): Boolean;
var nStr: string;
    nIdx: Integer;
    nIsOrder: Boolean;
    nBills: TLadingBillItems;
begin
  Result := False;
  nIsOrder := False;

  nStr := 'Select B_Prefix, B_IDLen From %s ' +
          'Where B_Group=''%s'' And B_Object=''%s''';
  nStr := Format(nStr, [sTable_SerialBase, sFlag_BusGroup, sFlag_Order]);

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  if RecordCount > 0 then
  begin
    nIsOrder := (Pos(Fields[0].AsString, FIn.FData) = 1) and
               (Length(FIn.FData) = Fields[1].AsInteger);
    //ǰ׺�ͳ��ȶ�����ɹ����������,����Ϊ�ɹ�����
  end;

  if not nIsOrder then
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

  nStr := 'Select O_ID,O_Card,O_ProID,O_ProName,O_Type,O_StockNo,' +
          'O_StockName,O_Truck,O_Value ' +
          'From $OO oo ';
  //xxxxx

  if nIsOrder then
       nStr := nStr + 'Where O_ID=''$CD'''
  else nStr := nStr + 'Where O_Card=''$CD''';

  nStr := MacroValue(nStr, [MI('$OO', sTable_Order),MI('$CD', FIn.FData)]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
    begin
      if nIsOrder then
           nData := '�ɹ���[ %s ]����Ч.'
      else nData := '�ſ���[ %s ]�޶���';

      nData := Format(nData, [FIn.FData]);
      Exit;
    end else
    with FListA do
    begin
      Clear;

      Values['O_ID']         := FieldByName('O_ID').AsString;
      Values['O_ProID']      := FieldByName('O_ProID').AsString;
      Values['O_ProName']    := FieldByName('O_ProName').AsString;
      Values['O_Truck']      := FieldByName('O_Truck').AsString;

      Values['O_Type']       := FieldByName('O_Type').AsString;
      Values['O_StockNo']    := FieldByName('O_StockNo').AsString;
      Values['O_StockName']  := FieldByName('O_StockName').AsString;

      Values['O_Card']       := FieldByName('O_Card').AsString;
      Values['O_Value']      := FloatToStr(FieldByName('O_Value').AsFloat);
    end;
  end;

  nStr := 'Select D_ID,D_OID,D_PID,D_YLine,D_Status,D_NextStatus,' +
          'D_KZValue,D_Memo,D_YSResult,' +
          'P_PStation,P_PValue,P_PDate,P_PMan,' +
          'P_MStation,P_MValue,P_MDate,P_MMan ' +
          'From $OD od Left join $PD pd on pd.P_Order=od.D_ID ' +
          'Where D_OutFact Is Null And D_OID=''$OID''';
  //xxxxx

  nStr := MacroValue(nStr, [MI('$OD', sTable_OrderDtl),
                            MI('$PD', sTable_PoundLog),
                            MI('$OID', FListA.Values['O_ID'])]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount<1 then
    begin
      SetLength(nBills, 1);

      with nBills[0], FListA do
      begin
        FZhiKa      := Values['O_ID'];
        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := sFlag_TruckNone;
        FNextStatus := sFlag_TruckNone;

        FSelected := True;
      end;  
    end else
    begin
      SetLength(nBills, RecordCount);

      nIdx := 0;

      First; 
      while not Eof do
      with nBills[nIdx], FListA do
      begin
        FID         := FieldByName('D_ID').AsString;
        FZhiKa      := FieldByName('D_OID').AsString;
        FPoundID    := FieldByName('D_PID').AsString;

        FCusID      := Values['O_ProID'];
        FCusName    := Values['O_ProName'];
        FTruck      := Values['O_Truck'];

        FType       := Values['O_Type'];
        FStockNo    := Values['O_StockNo'];
        FStockName  := Values['O_StockName'];
        FValue      := StrToFloat(Values['O_Value']);

        FCard       := Values['O_Card'];
        FStatus     := FieldByName('D_Status').AsString;
        FNextStatus := FieldByName('D_NextStatus').AsString;

        if (FStatus = '') or (FStatus = sFlag_BillNew) then
        begin
          FStatus     := sFlag_TruckNone;
          FNextStatus := sFlag_TruckNone;
        end;

        with FPData do
        begin
          FStation  := FieldByName('P_PStation').AsString;
          FValue    := FieldByName('P_PValue').AsFloat;
          FDate     := FieldByName('P_PDate').AsDateTime;
          FOperator := FieldByName('P_PMan').AsString;
        end;

        with FMData do
        begin
          FStation  := FieldByName('P_MStation').AsString;
          FValue    := FieldByName('P_MValue').AsFloat;
          FDate     := FieldByName('P_MDate').AsDateTime;
          FOperator := FieldByName('P_MMan').AsString;
        end;

        FKZValue  := FieldByName('D_KZValue').AsFloat;
        FMemo     := FieldByName('D_Memo').AsString;
        FYSValid  := FieldByName('D_YSResult').AsString;
        FSelected := True;

        Inc(nIdx);
        Next;
      end;
    end;    
  end;

  FOut.FData := CombineBillItmes(nBills);
  Result := True;
end;

//Date: 2014-09-18
//Parm: ������[FIn.FData];��λ[FIn.FExtParam]
//Desc: ����ָ����λ�ύ�Ľ������б�
function TWorkerBusinessOrders.SavePostOrderItems(var nData: string): Boolean;
var nVal: Double;
    nIdx, nInt: Integer;
    nStr,nSQL, nYS: string;
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
    nData := '��λ[ %s ]�ύ��ԭ���Ϻϵ�,��ҵ��ϵͳ��ʱ��֧��.';
    nData := Format(nData, [PostTypeToStr(FIn.FExtParam)]);
    Exit;
  end;
  //�޺ϵ�ҵ��

  FListA.Clear;
  //���ڴ洢SQL�б�

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckIn then //����
  begin
    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_OrderDtl;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
        FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([
            SF('D_ID', nOut.FData),
            SF('D_Card', FCard),
            SF('D_OID', FZhiKa),
            SF('D_Status', sFlag_TruckIn),
            SF('D_NextStatus', sFlag_TruckBFP),
            SF('D_InMan', FIn.FBase.FFrom.FUser),
            SF('D_InTime', sField_SQLServer_Now, sfVal)
            ], sTable_OrderDtl, '', True);
      FListA.Add(nSQL);
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

    nStr := 'Select D_Value From %s Where D_Name=''%s''';
    nStr := Format(nStr, [sTable_SysDict, sFlag_StockIfYS]);
    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
    if RecordCount > 0 then
         nYS := Fields[0].AsString
    else nYS := sFlag_No;

    FListC.Clear;
    FListC.Values['Group'] := sFlag_BusGroup;
    FListC.Values['Object'] := sFlag_PoundID;

    if not TWorkerBusinessCommander.CallMe(cBC_GetSerialNO,
            FListC.Text, sFlag_Yes, @nOut) then
      raise Exception.Create(nOut.FData);
    //xxxxx

    FOut.FData := nOut.FData;
    //���ذ񵥺�,�������հ�
    with nPound[0] do
    begin
      FStatus := sFlag_TruckBFP;
      FNextStatus := sFlag_TruckXH;

      if (FListB.IndexOf(FStockNo) >= 0) or (nYS <> sFlag_Yes) then
        FNextStatus := sFlag_TruckBFM;
      //�ֳ�������ֱ�ӹ���

      nSQL := MakeSQLByStr([
            SF('P_ID', nOut.FData),
            SF('P_Type', sFlag_Provide),
            SF('P_Order', FID),
            SF('P_Truck', FTruck),
            SF('P_CusID', FCusID),
            SF('P_CusName', FCusName),
            SF('P_MID', FStockNo),
            SF('P_MName', FStockName),
            SF('P_MType', FType),
            SF('P_LimValue', 0),
            SF('P_PValue', FPData.FValue, sfVal),
            SF('P_PDate', sField_SQLServer_Now, sfVal),
            SF('P_PMan', FIn.FBase.FFrom.FUser),
            SF('P_FactID', FFactory),
            SF('P_PStation', FPData.FStation),
            SF('P_Direction', '����'),
            SF('P_PModel', FPModel),
            SF('P_Status', sFlag_TruckBFP),
            SF('P_Valid', sFlag_Yes),
            SF('P_PrintNum', 1, sfVal)
            ], sTable_PoundLog, '', True);
      FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_PValue', FPData.FValue, sfVal),
              SF('D_PDate', sField_SQLServer_Now, sfVal),
              SF('D_PMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;  

  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckXH then //�����ֳ�
  begin
    with nPound[0] do
    begin
      FStatus := sFlag_TruckXH;
      FNextStatus := sFlag_TruckBFM;

      nStr := SF('P_Order', FID);
      //where
      nSQL := MakeSQLByStr([
                SF('P_KZValue', FKZValue, sfVal)
                ], sTable_PoundLog, nStr, False);
        //���տ���
       FListA.Add(nSQL);

      nSQL := MakeSQLByStr([
              SF('D_Status', FStatus),
              SF('D_NextStatus', FNextStatus),
              SF('D_YTime', sField_SQLServer_Now, sfVal),
              SF('D_YMan', FIn.FBase.FFrom.FUser),
              SF('D_KZValue', FKZValue, sfVal),
              SF('D_YSResult', FYSValid),
              SF('D_YLine', FPoundID),      //һ�߻����
              SF('D_YLineName', FHKRecord), //ж���ص�
              SF('D_Memo', FMemo)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL);
    end;
  end else

  //----------------------------------------------------------------------------
  if FIn.FExtParam = sFlag_TruckBFM then //����ë��
  begin
    with nPound[0] do
    begin
      nStr := SF('P_Order', FID);
      //where

      nVal := FMData.FValue - FPData.FValue -FKZValue;
      if FNextStatus = sFlag_TruckBFP then
      begin
        nSQL := MakeSQLByStr([
                SF('P_PValue', FPData.FValue, sfVal),
                SF('P_PDate', sField_SQLServer_Now, sfVal),
                SF('P_PMan', FIn.FBase.FFrom.FUser),
                SF('P_PStation', FPData.FStation),
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', DateTime2Str(FMData.FDate)),
                SF('P_MMan', FMData.FOperator),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //����ʱ,����Ƥ�ش�,����Ƥë������
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_PValue', FPData.FValue, sfVal),
                SF('D_PDate', sField_SQLServer_Now, sfVal),
                SF('D_PMan', FIn.FBase.FFrom.FUser),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', DateTime2Str(FMData.FDate)),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);

      end else
      begin
        nSQL := MakeSQLByStr([
                SF('P_MValue', FMData.FValue, sfVal),
                SF('P_MDate', sField_SQLServer_Now, sfVal),
                SF('P_MMan', FIn.FBase.FFrom.FUser),
                SF('P_MStation', FMData.FStation)
                ], sTable_PoundLog, nStr, False);
        //xxxxx
        FListA.Add(nSQL);

        nSQL := MakeSQLByStr([
                SF('D_Status', sFlag_TruckBFM),
                SF('D_NextStatus', sFlag_TruckOut),
                SF('D_MValue', FMData.FValue, sfVal),
                SF('D_MDate', sField_SQLServer_Now, sfVal),
                SF('D_MMan', FMData.FOperator),
                SF('D_Value', nVal, sfVal)
                ], sTable_OrderDtl, SF('D_ID', FID), False);
        FListA.Add(nSQL);
      end;

      //--------------------------------------------------------------------------
      FListC.Clear;
      FListC.Values['Field'] := 'T_PValue';
      FListC.Values['Truck'] := FTruck;
      FListC.Values['Value'] := FloatToStr(FPData.FValue);

      if not TWorkerBusinessCommander.CallMe(cBC_UpdateTruckInfo,
            FListC.Text, '', @nOut) then
        raise Exception.Create(nOut.FData);
      //���泵����ЧƤ��

      if FYSValid <> sFlag_NO then  //���ճɹ����������ջ���
      begin
        nSQL := 'Update $OrderBase Set B_SentValue=B_SentValue+$Val ' +
                'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'')';
        nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
                MI('$Order', sTable_Order),MI('$ID', FZhiKa),
                MI('$Val', FloatToStr(nVal))]);
        FListA.Add(nSQL);
        //�������ջ���
      end;

      nSQL := 'Update $OrderBase Set B_FreezeValue=B_FreezeValue-$KDVal ' +
              'Where B_ID = (select O_BID From $Order Where O_ID=''$ID'''+
              ' And O_CType= ''L'') and B_Value>0';
      nSQL := MacroValue(nSQL, [MI('$OrderBase', sTable_OrderBase),
              MI('$Order', sTable_Order),MI('$ID', FZhiKa),
              MI('$KDVal', FloatToStr(FValue))]);
      FListA.Add(nSQL);
      //����������
    end;

    nSQL := 'Select P_ID From %s Where P_Order=''%s'' And P_MValue Is Null';
    nSQL := Format(nSQL, [sTable_PoundLog, nPound[0].FID]);
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
    with nPound[0] do
    begin
      nSQL := MakeSQLByStr([SF('D_Status', sFlag_TruckOut),
              SF('D_NextStatus', ''),
              SF('D_Card', ''),
              SF('D_OutFact', sField_SQLServer_Now, sfVal),
              SF('D_OutMan', FIn.FBase.FFrom.FUser)
              ], sTable_OrderDtl, SF('D_ID', FID), False);
      FListA.Add(nSQL); //���²ɹ���
    end;

    nStr := nPound[0].FID;
    if not TWorkerBusinessCommander.CallMe(cBC_SyncStockOrder, nStr, '', @nOut) then
    begin
      nData := nOut.FData;
      Exit;
    end;

    nSQL := 'Select O_CType,O_Card From %s Where O_ID=''%s''';
    nSQL := Format(nSQL, [sTable_Order, nPound[0].FZhiKa]);

    with gDBConnManager.WorkerQuery(FDBConn, nSQL) do
    if RecordCount > 0 then
    begin
      nStr := FieldByName('O_Card').AsString;
      if FieldByName('O_CType').AsString = sFlag_OrderCardL then
      if not CallMe(cBC_LogOffOrderCard, nStr, '', @nOut) then
      begin
        nData := nOut.FData;
        Exit;
      end;
    end;
    //�������ʱ��Ƭ����ע����Ƭ
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
      gHardShareData('TruckOut:' + nPound[0].FCard);
    //���������Զ�����
  end;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TWorkerBusinessOrders.CallMe(const nCmd: Integer;
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
  gBusinessWorkerManager.RegisteWorker(TBusWorkerQueryField, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessCommander, sPlug_ModuleBus);
  gBusinessWorkerManager.RegisteWorker(TWorkerBusinessOrders, sPlug_ModuleBus);
end.
