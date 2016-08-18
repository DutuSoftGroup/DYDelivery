{*******************************************************************************
  ����: dmzn@163.com 2011-10-22
  ����: ��������
*******************************************************************************}
unit UWeiXinConst;

{$I Link.Inc}
interface

uses
  Windows, SysUtils, Classes, ComCtrls, Forms, IniFiles, USysMAC, UMgrDBConn,
  UMgrDB, ULibFun, UBase64, USysDB;

const
  {*Flag*}
  sFlag_FactoryItem   = 'FactoryItem';               //������Ϣ��
  {*Frame ID*}

  {*Form ID*}
  cFI_FormDB          = $0051;                       //���ݿ�

  {*Command*}
  cCmd_AdminChanged   = $0001;                       //�����л�
  cCmd_RefreshData    = $0002;                       //ˢ������
  cCmd_ViewSysLog     = $0003;                       //ϵͳ��־

  cCmd_ModalResult    = $1001;                       //Modal����
  cCmd_FormClose      = $1002;                       //�رմ���
  cCmd_AddData        = $1003;                       //�������
  cCmd_EditData       = $1005;                       //�޸�����
  cCmd_ViewData       = $1006;                       //�鿴����  
  
  {*business command*}
  cBC_GetSQLQueryWeixin       = $0081;   //��ȡ΢����Ϣ��ѯ���
  cBC_SaveWeixinAccount       = $0082;   //����΢���˻�
  cBC_DelWeixinAccount        = $0083;   //ɾ��΢���˻�
  cBC_GetWeiXinReport         = $0084;   //��ȡ΢�ű���
  cBC_GetWeiXinQueue          = $0085;   //��ȡ΢�ű���
  cBC_GetQueueList            = $0059;   //��ȡ��������

  {*���ò���*}
  cParamIDCharacters = ['a'..'z','A'..'Z','0'..'9','_',Char(VK_BACK)];
  //ID��ʶ�����ַ�

  cFlag_DBS           = 'D';                         //���ݿ�����������ݿ�
  cFlag_FileS         = 'F';                         //���ݿ������������
  //

  sTable_FactServer   = 'Sys_FactServer';
type
  TWXDBParam = record
    FRID     : Integer;                              //��¼���
    FFactID  : string;                               //�������
    FFactName: string;                               //��������

    FSource  : string;                               //������Դ
    FDBParam : TDBParam;                             //���ݿ����
  end;
  TWXDBParams = array of TWXDBParam;
  
  TDBParams = array of TDBParam;

var
  gWeiXinPath: string;                                     //��������·��

procedure InitSystemEnvironment;
//��ʼ��ϵͳ���л����ı���
procedure LoadDBParamFromDB(var nDBParams: TDBParams);
procedure LoadDBParamFromFile(nConf: String; var nDBParams: TDBParams);
//���ز���

//------------------------------------------------------------------------------
ResourceString
  sProgID             = 'WeiXin';                   //Ĭ�ϱ�ʶ
  sAppTitle           = 'WeiXin';                   //�������
  sMainCaption        = '΢���м��';                //�����ڱ���
  sHintText           = '΢���м������';            //��ʾ����

  sHint               = '��ʾ';                      //�Ի������
  sWarn               = '����';                      //==
  sAsk                = 'ѯ��';                      //ѯ�ʶԻ���
  sError              = '����';                      //����Ի���

  sDate               = '����:��%s��';               //����������
  sTime               = 'ʱ��:��%s��';               //������ʱ��
  sUser               = '�û�:��%s��';               //�������û�

  sConfigFile         = 'Config.Ini';                //�������ļ�
  sConfigSec          = 'Config';                    //������С��

  sDBConfigFile       = 'DBConn.Ini';                //���ݿ�����
  
  sFormConfig         = 'FormInfo.ini';              //��������
  sLogDir             = 'Logs\';                     //��־Ŀ¼
  sLogSyncLock        = 'SyncLock_Weixin_CommonMIT';    //��־ͬ����

  sInvalidConfig      = '�����ļ���Ч���Ѿ���';    //�����ļ���Ч
  sCloseQuery         = 'ȷ��Ҫ�˳�������?';         //�������˳�
  
implementation

procedure InitSystemEnvironment;
begin
  Randomize;
  ShortDateFormat := 'YYYY-MM-DD';
  gWeiXinPath := ExtractFilePath(Application.ExeName);
end;

procedure LoadDBParamFromFile(nConf: String; var nDBParams: TDBParams);
var nIdx: Integer;
    nIni: TIniFile;
    nList: TStrings;
    nDBItem: TDBParam;
    nDBList, nDBName, nStr: string;
begin
  SetLength(nDBParams, 0);
  if not FileExists(nConf) then Exit;

  nList := TStringList.Create;
  nIni  := TIniFile.Create(nConf);
  try
     nStr := nIni.ReadString('DBConn', 'Splitter', '');
     if nStr='' then nStr := ' ';

     nDBList := nIni.ReadString('DBConn', 'DBList', '');
     if not SplitStr(nDBList, nList, 0, nStr, False) then Exit;

     SetLength(nDBParams, nList.Count);

     for nIdx:=0 to nList.Count-1 do
     begin
       nDBName := nList[nIdx];

       FillChar(nDBItem, SizeOf(TDBParam), 0);
       with nDBItem do
       begin
         FName := nDBName;
         FID   := nIni.ReadString(nDBName, 'DBID', '');
         //���ݿ��ʶ����,������ʶ

         FHost := nIni.ReadString(nDBName, 'DBHost', '');
         FPort := nIni.ReadInteger(nDBName, 'DBPort', 0);
         //��������ַ���˿�

         FDB   := nIni.ReadString(nDBName, 'DBCatalog', '');
         FUser := nIni.ReadString(nDBName, 'DBUser', '');
         FPwd  := Trim(DecodeBase64(nIni.ReadString(nDBName, 'DBPwd', '')));
         //���ݿ�����,�û���,����

         FConn := nIni.ReadString(nDBName, 'DBConnStr', '');
         //���ݿ������ַ���

         FNumWorker:= nIni.ReadInteger(nDBName, 'DBWorker', 3);
         //������

         FEnable := nIni.ReadBool(nDBName, 'Active', False);
       end;

       nDBParams[nIdx] := nDBItem;
     end;
  finally
    nList.Free;
    nIni.Free;
  end;
end;

procedure LoadDBParamFromDB(var nDBParams: TDBParams);
var nStr: string;
    nInt: Integer;
    nDBItem: TDBParam;
    nDBWorker: PDBWorker;
begin
  SetLength(nDBParams, 0);

  //{$IFDEF SQLPARAM}
  nStr := 'Select * from %s where F_Valid<>''%s''';
  nStr := Format(nStr, [sTable_FactServer, sFlag_No]);
  try
    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount<1 then Exit;

      SetLength(nDBParams, RecordCount);
      nInt := Low(nDBParams);
      //xxxxxx

      First;
      while not Eof do
      begin
        FillChar(nDBItem, SizeOf(TDBParam), 0);

        with nDBItem do
        begin
          FName := FieldByName('F_ServName').AsString;
          FID   := FieldByName('F_ServID').AsString;
          //���ݿ��ʶ����,������ʶ

          FHost := FieldByName('F_ServIP').AsString;
          FPort := FieldByName('F_ServPort').AsInteger;
          //��������ַ���˿�

          FDB   := FieldByName('F_ServDataSource').AsString;
          FUser := Trim(DecodeBase64(FieldByName('F_ServUser').AsString));
          FPwd  := Trim(DecodeBase64(FieldByName('F_ServPsw').AsString));
          //���ݿ�����,�û���,����

          FConn := Trim(DecodeBase64(FieldByName('F_ServConn').AsString));
          //���ݿ������ַ���

          FNumWorker:= FieldByName('F_ServPort').AsInteger;
          //������

          FEnable := FieldByName('F_Valid').AsString = sFlag_No;
        end;

        nDBParams[nInt] := nDBItem;
        Inc(nInt);
        Next;
      end;  
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
  //{$ENDIF}
end;  

end.
