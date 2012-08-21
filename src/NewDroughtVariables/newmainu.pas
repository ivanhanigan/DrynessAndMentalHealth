unit newmainu;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, stdCtrls, StStrS, Contnrs,ExtCtrls, Buttons, ComCtrls;

type
  TfrmMain = class(TForm)
    odDroughtData: TOpenDialog;
    sdDroughtData: TSaveDialog;
    btnMonths: TButton;
    btnSave: TButton;
    btnHelp: TButton;
    btnOpen: TButton;
    btnClose: TBitBtn;
    sbDrought: TStatusBar;
    btnCleardata: TButton;
    btnLog: TButton;
    Label1: TLabel;
    edtNoOfYears: TEdit;
    procedure btnLogClick(Sender: TObject);
    procedure btnCleardataClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnMonthsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    procedure WriteTestDataFile;
    procedure OpenDroughtData;
    procedure LoadPrecipitationObject;
    procedure CalcMonthsInDrought;
    procedure WriteDataFile;
    procedure SavedataFile;
    { Private declarations }
  public
    { Public declarations }
  end;
 TPrecipitationData = class(TObject)
  public
    AreaId : Integer;
    Year : integer;
    Month : integer;
    avcount : real;
    avsum : real;
 end;
 TDroughtData = class(TObject)
  public
    AreaId : Integer;
    Year : integer;
    Month : integer;
    InDroughtNSW : integer;
    InDroughtVIC : integer;
    InDroughtStartNSW : integer;
    InDroughtStartVIC : integer;
    MonthsInDroughtNSW : Integer;
    MonthsInDroughtVic : Integer;
    MonthsinDroughtEither : Integer;
    MonthsInDroughtBoth : Integer;
    Maxavcount : real;
    MaxMonth : integer;
    MaxYear : Integer;
    Minavsum : real;
    MinMonth : integer;
    MinYear : integer;
    DroughtCyclesNSW : Integer;
    DroughtCyclesVIC : Integer;
    DroughtCyclesEither : Integer;
    DroughtCyclesBoth : Integer;
    meanavsum : real;
  end;

var
  frmMain: TfrmMain;
  slDroughtdata: TStringlist;
  slDroughtvariables : TStringList;
  olPrecipitationVariables : TObjectList;
  olDroughtVariables : TObjectList;
  dataopened : boolean;
implementation

{$R *.dfm}
uses stUtils,filedatetime, helpu, logformu;

function compareareaid(item1,item2:pointer):integer;
var
 I1,I2:integer;
 J1,J2:integer;
 K1,K2:integer;
begin
  Result:=-1;
  I1:= TPrecipitationData(item1).areaid;
  I2:=TPrecipitationData(item2).areaid;
  J1:=TPrecipitationData(item1).year;
  J2:=TPrecipitationData(item2).year;
  K1:=TPrecipitationData(item1).month;
  K2:=TPrecipitationData(item2).month;
  if I1>I2 then
    Result :=1 else
  if (I1=I2) then begin
    if (J1<J2) then
      Result := 1 else
    Result := 0;
  end;
end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
  sldroughtVariables := TStringList.create;
  olDroughtVariables := TObjectList.create;
  slDroughtdata:= TStringlist.create;
  olPrecipitationVariables := TObjectList.create;
  dataopened := false;
end;

procedure TfrmMain.LoadPrecipitationObject;
var
  I :integer;
  slDroughtDataExpanded :TStringList;
  Save_Cursor : TCursor;
  avsum : real;
  avcount : real;
  month : integer;
  year : integer;
  areaid : integer;
  precipitationdata : TPrecipitationData;
begin
  slDroughtDataExpanded := TStringList.create;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  try
    avsum := 0;
    avcount:= 0;
    Month := 0;
    Year := 0;
    areaid := 0;
    for I := 1 to slDroughtData.Count - 1 do begin
      ExtractTokensS(slDroughtData[I],',','"',True,slDroughtDataExpanded);
      if slDroughtDataExpanded[1] <> 'cd_code' then begin
        precipitationdata := TPrecipitationData.Create;
        precipitationdata.AreaId := StrToInt(slDroughtDataExpanded[1]);
        precipitationdata.Year :=StrToInt(slDroughtDataExpanded[2]);
        precipitationdata.Month := StrToInt(slDroughtDataExpanded[3]);
        if ((slDroughtDataExpanded[4] <>'') or (slDroughtDataExpanded[4] <>' ')) then
          try
            precipitationdata.avsum := StrToFloat(slDroughtDataExpanded[4]);
          except

          end;
        if ((slDroughtDataExpanded[5] <>'') or (slDroughtDataExpanded[5] <>' ')) then
          try
            precipitationdata.avcount := StrToFloat(slDroughtDataExpanded[5]);
          except

          end;
        olPrecipitationVariables.Add(precipitationdata);
      end;
    end;
//      olPrecipitationVariables.Sort(@compareareaid);
//test sort
//    WriteTestDataFile;
//    sldroughtvariables.savetofile('temp.csv');
  finally
   slDroughtDataExpanded.free;
   Screen.cursor := save_cursor;
  end;
end;

procedure TfrmMain.btnCleardataClick(Sender: TObject);
begin
//  slDroughtData.Clear;
  slDroughtVariables.clear;
  olDroughtVariables.clear;
  sbDrought.Panels[1].text := 'Data is cleared';
  LogDisplayForm.LogEntry(lshigh,sdDroughtData.filename +' is cleared');
end;

procedure TfrmMain.btnHelpClick(Sender: TObject);
var
  Save_Cursor : TCursor;
begin
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  try
    frmHelp := TfrmHelp.create(nil);
  finally
    Screen.Cursor := Save_Cursor;  { Always restore to normal }
  end;
  try
    frmHelp.showmodal;
  finally
    frmHelp.free;
    frmHelp := nil;
  end;
end;

procedure TfrmMain.btnLogClick(Sender: TObject);
begin
  LogDisplayForm.Show;
end;

procedure TfrmMain.btnMonthsClick(Sender: TObject);
begin
  if dataopened then
    CalcMonthsInDrought
  else
    ShowMessage('You do not have a data file opened');
end;

procedure TfrmMain.btnOpenClick(Sender: TObject);
begin
  OpenDroughtData;
  LoadPrecipitationObject;
end;

procedure TfrmMain.OpenDroughtData;
begin
  if MessageDlg('Open Drought data file',mtconfirmation,mbOKCancel,0)=mrOK then begin
    odDroughtData.execute;
    LogDisplayForm.LogEntry(lshigh,odDroughtdata.filename +' is opened');
  end else begin
    ShowMessage('You must open Drought data file to commence');
    Close;
  end;
  slDroughtData.loadfromfile(odDroughtData.FileName);
  dataopened :=true;
  sbDrought.Panels[0].Text := odDroughtData.FileName + ' is open';
  sbDrought.Panels[1].Text := 'data opened';
end;

procedure TfrmMain.btnSaveClick(Sender: TObject);
begin
  WriteDataFile;
  SaveDataFile;
end;


procedure TfrmMain.CalcMonthsInDrought;
var
  Save_Cursor : TCursor;
  MonthsinDroughtNSW : integer;
  MonthsinDroughtVIC : integer;
  MonthsinDroughtEither : integer;
  MonthsinDroughtBoth : integer;
  InDroughtNSW : integer;
  InDroughtVIC : integer;
  InDroughtBoth : integer;
  avsum : real;
  Minavsum : real;
  avcount : real;
  maxavcount : real;
  areaid : integer;
  oldareaid : integer;
  slDroughtDataExpanded : TStringList;
  I,J,K :integer;
  DroughtData : TDroughtData;
  DataYear : Integer;
  DataMonth : Integer;
  minMonth : Integer;
  minYear : Integer;
  maxMonth : integer;
  maxYear : integer;
  enterDroughtNSW : integer;
  enterDroughtVIC : integer;
  enterDroughtBoth : integer;
  inDroughtStartNSW : integer;
  inDroughtStartVIC : integer;
  inDroughtStartBoth : integer;
  changeDroughtN : boolean;
  changeDroughtV : boolean;
  changeDroughtBoth : boolean;
  DroughtCyclesNSW : integer;
  DroughtCyclesVIC : integer;
  DroughtCyclesEither : integer;
  DroughtCyclesBoth : integer;
  cumavsum : real;
  meanavsum : real;
  noOfYears : integer;
begin
  slDroughtDataExpanded := TStringList.create;
  Save_Cursor := Screen.Cursor;
  Screen.Cursor := crHourglass;    { Show hourglass cursor }
  try
    try
      noOfYears := StrToInt(edtNoOfYears.text)
    except
      ShowMessage('Must have an integer value for number of years');
    end;
    K:=noOfYears*12;
    MonthsInDroughtNSW:=0;
    MonthsInDroughtVic:=0;
    MonthsinDroughtEither:=0;
    MonthsInDroughtBoth:=0;
    InDroughtNSW := 0;
    InDroughtVIC := 0;
    InDroughtBoth :=0;
    InDroughtStartNSW := 0;
    InDroughtStartVIC := 0;
    InDroughtStartBoth := 0;
    oldareaid := 0;
    avsum := 0;
    minavsum :=0;
    avcount:= 0;
    maxavcount := 0;
    minMonth := 0;
    minYear := 0;
    maxMonth := 0;
    maxYear := 0;
    DroughtCyclesNSW :=0;
    DroughtCyclesVic :=0;
    DroughtCyclesEither :=0;
    DroughtCyclesBoth :=0;
    meanavsum := 0;
    cumavsum:=0;
    I:= 0;
    while I < olPrecipitationVariables.Count - 1 do begin      //begin while
      areaid := TPrecipitationData(olPrecipitationVariables[I]).AreaId;
      if areaid <> oldareaid then begin       //begin check new cd
        oldareaid := areaid;
//Need to jump 12 months ahead to get the initial state
        I:= I+K;
      end else // end check new cd
      begin   // begin same cd
//Check drought status 12 months before
        for J := K-1 downto 0 do begin     //begin looking back 12 months
          areaid := TPrecipitationData(olPrecipitationVariables[I-J]).AreaId;
          if areaid <> oldareaid then
            ShowMessage('This does not work Clare')
          else begin    // begin same cd within 12 months after error checking
             avsum := TPrecipitationData(olPrecipitationVariables[I-j]).Avsum;
             avcount := TPrecipitationData(olPrecipitationVariables[I-j]).Avcount;
            DataYear := TPrecipitationData(olPrecipitationVariables[I-j]).year;
            DataMonth := TPrecipitationData(olPrecipitationVariables[I-j]).month;
//Start both calculations
            if ((avcount >= 5) and (avsum <-17.5)) then begin
                 inc(MonthsinDroughtBoth,1);
              if (inDroughtBoth=0) then begin
                inc(Droughtcyclesboth,1);
                inDroughtBoth :=1;
              end;
            end;
//Start either calcuations
            if ((avcount >= 5) or (avsum <-17.5)) then begin
              inc(MonthsinDroughtEither,1);
              if ((inDroughtVIC=0) and (inDroughtNSW=0)) then
                inc(Droughtcycleseither,1);
            end;
//Start VIC methods
            if avsum <=-17.5 then begin    //begin in drought in VIC
              inc(MonthsinDroughtVic,1);
              cumavsum := cumavsum+avsum;
              if inDroughtVIC = 0 then begin
                inDroughtVIC := 1;
                inc(droughtcyclesVIC,1);
              end;
              if avsum < minavsum then begin
                minavsum := avsum;
                minMonth := DataMonth;
                minYear := DataYear;
              end;
            end else begin       //end VIC in drought
              if inDroughtVIC =1 then begin
                inDroughtVIC :=0;
              end;
            end;
//Start NSW method
            if avcount >= 5  then begin //begin drought in NSW
              inc(MonthsinDroughtNSW,1);
              if inDroughtNSW = 0 then begin
                inDroughtNSW := 1;
                inc(DroughtcyclesNSW,1);
              end;
              if avcount > maxavcount then begin
                maxavcount := avcount;
                maxMonth := DataMonth;
                maxYear := DataYear;
              end;                            //end drought in NSW
            end else begin
              if inDroughtNSW =1 then
                inDroughtNSW :=0;
          end;
         end;// end within same cd for 12 months
         if J=11 then begin
           inDroughtStartNSW := indroughtNSW;
           inDroughtStartVIC := indroughtVIC;
           inDroughtStartBoth := indroughtBoth;
         end;
       end; // end looking back 12 months
       if MonthsInDroughtVIC<>0 then
         meanavsum := cumavsum/MonthsInDroughtVIC;
       Droughtdata := TDroughtData.create;
       DroughtData.areaid :=areaid;
       droughtData.Year := DataYear;
       Droughtdata.Month := DataMonth;
       DroughtData.InDroughtNSW := InDroughtNSW;
       DroughtData.InDroughtVIC := InDroughtVIC;
       Droughtdata.MonthsInDroughtNSW := MonthsInDroughtNSW;
       Droughtdata.MonthsInDroughtVic := MonthsInDroughtVIc;
       Droughtdata.MonthsinDroughtEither := MonthsinDroughtEither;
       Droughtdata.MonthsinDroughtBoth := MonthsinDroughtBoth;
       Droughtdata.maxavcount := maxavcount;
       DroughtData.MaxMonth := maxmonth;
       DroughtData.MaxYear := maxyear;
       Droughtdata.Minavsum := minavsum;
       DroughtData.MinMonth := minmonth;
       DroughtData.MinYear := minyear;
       DroughtData.DroughtCyclesNSW := DroughtcyclesNSW;
       DroughtData.DroughtCyclesVIC := DroughtcyclesVIC;
       DroughtData.DroughtCyclesEither := DroughtcyclesEither;
       DroughtData.DroughtCyclesBoth := DroughtcyclesBoth;
       DroughtData.meanavsum := meanavsum;
       DroughtData.InDroughtStartVIC := IndroughtStartVIC;
       DroughtData.InDroughtStartNSW := IndroughtStartNSW;
       MonthsInDroughtNSW:=0;
       MonthsInDroughtVic:=0;
       MonthsinDroughtEither:=0;
       MonthsinDroughtBoth:=0;
       InDroughtNSW :=0;
       InDroughtVIC :=0;
       InDroughtBoth := 0;
       maxavcount := 0;
       minavsum := 0;
       cumavsum:=0;
       minMonth := 0;
       minYear := 0;
       maxMonth := 0;
       maxYear := 0;
       DroughtCyclesNSW := 0;
       DroughtCyclesVIC := 0;
       DroughtCyclesEither := 0;
       DroughtCyclesBoth := 0;
       meanavsum:=0;
       olDroughtVariables.Add(DroughtData);
       inc(I,1);
     end;  // end same cd
    end; //end while
  finally
    slDroughtdataexpanded.free;
    Screen.Cursor := Save_Cursor;  { Always restore to normal }
    sbDrought.Panels[1].text := 'months calculated';
  end;
end;

procedure TfrmMain.WriteTestDataFile;
var
  I : integer;
  titleString : string;
  datastring : string;
begin
  titlestring := 'CD_Code,Year,Month,avsum,avcount';
  slDroughtVariables.add(titlestring);
  datastring := '';
  for I := 0 to olPrecipitationVariables.Count - 1 do begin
     datastring :=  Inttostr(TPrecipitationData(olPrecipitationVariables[I]).AreaId) +','+
     Inttostr(TPrecipitationData(olPrecipitationVariables[I]).Year) +','+
     Inttostr(TPrecipitationData(olPrecipitationVariables[I]).Month) +','+
     FloattoStr(TPrecipitationData(olPrecipitationVariables[I]).avsum)+','+
     FloattoStr(TPrecipitationData(olPrecipitationVariables[I]).avcount);
     slDroughtvariables.Add(datastring);
  end;
end;


procedure TfrmMain.WriteDataFile;
var
  I : integer;
  titleString : string;
  datastring : string;
begin
  titlestring := 'CD_Code,Year,Month,InDroughtNSW,InDroughtVIC,InDroughtStartNSW'
    +edtNoOfYears.Text+',' + 'InDroughtStartVIC'+edtNoOfYears.Text+',MonthInDroughtNSW'+edtNoOfYears.Text+','
    +'MonthsInDroughtVIC'+edtNoOfYears.Text+',MonthsinDroughtEither'+edtNoOfYears.Text
    +',MonthsinDroughtBoth'+edtNoOfYears.Text+',MaxAvcount'+edtNoOfYears.Text+
    ',MaxMonth'+edtNoOfYears.Text+',Maxyear'+edtNoOfYears.Text+',MinAvSum'+edtNoOfYears.Text+','
    +'MinMonth'+edtNoOfYears.Text+',MinYear'+edtNoOfYears.Text+',DroughtCyclesNSW'
    +edtNoOfYears.Text+',DroughtCyclesVIC'+edtNoOfYears.Text+',DroughtCyclesEither'
    +edtNoOfYears.Text+',DroughtCyclesBoth'+edtNoOfYears.Text+',meanavsum'+edtNoOfYears.Text;
  slDroughtVariables.add(titlestring);
  datastring := '';
  for I := 0 to olDroughtvariables.Count - 1 do begin
     datastring :=  Inttostr(Tdroughtdata(olDroughtvariables[I]).AreaId) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).Year) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).Month) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).InDroughtNSW) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).InDroughtVIC) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).InDroughtStartNSW) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).InDroughtStartVIC) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MonthsInDroughtNSW) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MonthsInDroughtVIC) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MonthsinDroughtEither) +','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MonthsinDroughtBoth) +','+
     FloattoStr(Tdroughtdata(olDroughtvariables[I]).maxavcount)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MaxMonth)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MaxYear)+','+
     FloattoStr(Tdroughtdata(olDroughtvariables[I]).minavsum)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MinMonth)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).MinYear)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).DroughtCyclesNSW)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).DroughtCyclesVIC)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).DroughtCyclesEither)+','+
     Inttostr(Tdroughtdata(olDroughtvariables[I]).DroughtCyclesBoth)+','+
     Floattostr(Tdroughtdata(olDroughtvariables[I]).meanavsum);
     slDroughtvariables.Add(datastring);
  end;
end;

procedure TfrmMain.SavedataFile;
var
 sfilename : string;
begin
  sfilename := 'C:\temp\DroughtData'+GetDateTime+'.csv';
   try
     if SdDroughtData.execute then begin
       if FileExists(SdDroughtData.Filename)= False then begin
         slDroughtVariables.SaveToFile(SdDroughtData.FileName);
       end else begin
         slDroughtVariables.SaveToFile(sfilename);
         ShowMessage('File saved to '+sfilename);
       end;
         sbDrought.Panels[1].Text := 'Data saved';
     end;
   except
      slDroughtVariables.SaveToFile(sfilename);
   end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
//  slDroughtData.free;
  slDroughtVariables.free;
  olDroughtVariables.free;
  olPrecipitationVariables.Free;
end;

end.
