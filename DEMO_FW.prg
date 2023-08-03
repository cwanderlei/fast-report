//////////////////////////////////////////////////////////////////////////////
//
//  Demo.PRG
//
//  Copyright:
//       Spirin Sergey, Paritet Soft, (c) 1992-2008. All rights reserved.
//       Adaptação para FiveWin por Evandro G. de Paula - Curvelo - MG         
//  
//  Contents:
//       Simple demo-application for "FastReport for [x]Harbour"
//      
//   
//////////////////////////////////////////////////////////////////////////////
#include 'fivewin.ch'
#include 'FastRepH.CH'
#include 'lang_en.ch'

function Main()

local aTmp, x, oDlg

MEMVAR RepDir, DataDir, ResDir
MEMVAR FrPrn, lShowCustName
FIELD CustNo, Company, OrderNo, ItemNo, PartNo
PRIVATE FrPrn, lShowCustName := .f., nAction:=1

REQUEST DBFCDX

RepDir := CurDrive() +":\"+ CurDir() + '\REPS\'
DataDir := CurDrive() +":\"+ CurDir() + '\DATA\'
ResDir := CurDrive() +":\"+ CurDir() + '\LANGRES\'

SET DEFAULT TO "data\"

IF ! AllFilesExist( { "CUSTA.NTX", "CUSTB.NTX" } )
        USE Customer EXCLUSIVE
        INDEX ON CustNo  TO CustA
        INDEX ON Company TO CustB
        CLOSE
ENDIF

IF ! AllFilesExist( { "ORDERSA.NTX", "ORDERSB.NTX" } )
        USE Orders EXCLUSIVE
        INDEX ON OrderNo   TO ORDERSA
        INDEX ON CustNo    TO ORDERSB
        CLOSE
ENDIF

IF ! AllFilesExist( { "itemsa.NTX", "itemsb.NTX", "itemsc.NTX" } )
        USE Items EXCLUSIVE
        INDEX ON str(OrderNo, 15)+str(ItemNo, 15)  TO itemsa
        INDEX ON OrderNo                           TO itemsb
        INDEX ON PartNo                            TO itemsc
        CLOSE
ENDIF

IF ! AllFilesExist( { "parts.NTX", } )
        USE Parts EXCLUSIVE
        INDEX ON PartNo TO parts
        CLOSE
ENDIF


SET DELETED ON

USE Customer NEW
SET INDEX TO CustA, CustB
SET ORDER TO 2
GO TOP

USE Orders NEW
SET INDEX TO ORDERSA, ORDERSB
SET ORDER TO 2
GO TOP

USE Items NEW
SET INDEX TO itemsa, itemsb, itemsc
SET ORDER TO 2
GO TOP

USE Parts NEW
SET INDEX TO Parts
SET ORDER TO 1
GO TOP

DEFINE DIALOG oDlg RESOURCE 'DEMO' ICON 'DEMO'
oDlg:lHelpIcon := .f.

REDEFINE RADIO oGet1 VAR nAction id 101, 102, 103, 104 of oDlg UPDATE
REDEFINE BUTTON ID 501 of oDlg ACTION DoSimpleList()  UPDATE
REDEFINE BUTTON ID 502 of oDlg ACTION DoSimpleGroup() UPDATE
REDEFINE BUTTON ID 503 of oDlg ACTION DoMoreComplex() UPDATE
REDEFINE BUTTON ID 504 of oDlg ACTION DoUserDS()      UPDATE
REDEFINE BUTTON ID 505 of oDlg ACTION DoWAUserDS()    UPDATE
REDEFINE BUTTON ID 506 of oDlg ACTION DoADO()         UPDATE
REDEFINE BUTTON ID 507 of oDlg ACTION DoSomeCalls()   UPDATE
REDEFINE BUTTON ID 508 of oDlg ACTION DoInFR_MoreComplex()  UPDATE
REDEFINE BUTTON ID 509 of oDlg ACTION DoMemPict()           UPDATE
REDEFINE BUTTON ID 510 of oDlg ACTION DoManualReport()      UPDATE
REDEFINE BUTTON ID 550 of oDlg ACTION ( oDlg:End() )        UPDATE

//----------- Now load and init FastReport --------------------------------------

FrPrn := frReportManager():new()

//---------- Set the same icon for FastReport windows----------
   
FrPrn:SetIcon(1)

//---------- Set the same title for FastReport taskBar-window
   
FrPrn:SetTitle(_cTitle)

 //-----------Set to disable main window when FastReport executes----------------------

//   FrPrn:SetVisualActions(FR_ACT_NONE)
//FrPrn:SetVisualActions(FR_ACT_USER, .F., {|| DoMethod('Form_1', 'Hide')}, {|| DoMethod('Form_1', 'Show')})

//-----------Set progress event handlers-----------------------------------------------
   
//FrPrn:SetEventHandler("Report", "OnProgressStart", {|x,y|ShowProgress(x, y, 1)})
//FrPrn:SetEventHandler("Report", "OnProgressStop", {|x,y|ShowProgress(x, y, 2)})
//FrPrn:SetEventHandler("Report", "OnProgress", {|x,y|ShowProgress(x, y, 3)})
//FrPrn:SetEventHandler("Report", "OnBeforePrint", {|ObjName|ShowProcess(ObjName)})
 
   
//-------- add function to FastReport (see calls example)----------------------
FrPrn:SetEventHandler("Report", "OnUserFunction", {|FName, FParams| CallUserFunction(FName, FParams)})   
FrPrn:AddFunction("function XBaseStr(nValue: Double, nLength: Variant = EmptyVar, nDecimals: Variant = EmptyVar): Variant",;
             "My Lovely Functions!", "It's a XBase Str() function!")
 
FrPrn:LoadLangRes(ResDir + "Brazil.xml") 
     
ACTIVATE DIALOG oDlg CENTERED  

return nil


///////////////////////////////////////////////////////////////////////
// Unload FastReport                                                 //
///////////////////////////////////////////////////////////////////////
function UnloadFr()

FrPrn:DestroyFR()

return nil

///////////////////////////////////////////////////////////////////////
function DoFrAction( cFileName, lPrepared )     

local lNotOpened := .f.

private cExpObj, cExpFile, lExpOpt, lExpOpen, cExtention

lPrepared := IF(lPrepared <> NIL, lPrepared, .f.)
if !lPrepared .and. (cFileName <> NIL)
        FrPrn:LoadFromFile(RepDir + cFileName)
endif
      
DO CASE
CASE nAction == 1
        FrPrn:ShowReport()
CASE nAction == 2
        FrPrn:DesignReport()
CASE nAction == 3
        FrPrn:SetProperty("Report", "ShowProgress", .f.)
        if !lPrepared 
                FrPrn:PrepareReport()
        endif
        FrPrn:Print(.t.)
        FrPrn:SetProperty("Report", "ShowProgress", .t.)
CASE nAction == 4
        if GetExportObject()
                FrPrn:SetProperty("Report", "ShowProgress", .f.)
                if !lPrepared 
                        FrPrn:PrepareReport()
                endif
                FrPrn:SetProperty(cExpObj, "ShowDialog", lExpOpt)
                if (cExpObj = "MailExport").and.!lExpOpt 
                        FrPrn:SetProperty(cExpObj, "ShowDialog", .t.)
                endif
                if AScan({"XLSExport","XMLExport"},  cExpObj) > 0                   
                        FrPrn:SetProperty(cExpObj, "OpenExcelAfterExport", lExpOpen)
                else
                        if AScan({"BMPExport", "TIFFExport", "JPEGExport", "GIFExport",;
                                 "DotMatrixExport", "TXTExport"},  cExpObj) > 0
                                lNotOpened := .t.
                        else
                                FrPrn:SetProperty(cExpObj, "OpenAfterExport", lExpOpen)
                        endif
                endif          
                if lExpOpen .and. !lNotOpened
                        if cExpObj <> "SimpleTextExport"
                                cExtention := "." + Left(cExpObj, 3)
                        else
                                cExtention := ".TXT"
                        endif
                        if right(cExpFile, 4) <> cExtention
                                cExpFile := cExpFile + cExtention
                        endif                      
                endif
                FrPrn:SetProperty(cExpObj, "FileName", cExpFile)          
                FrPrn:DoExport(cExpObj)
                if lExpOpen .and. lNotOpened 
                        Msgalert(_cNoOpen, "Atenção")
                endif
                FrPrn:SetProperty("Report", "ShowProgress", .t.)
        endif
ENDCASE

return nil

///////////////////////////////////////////////////////////////////////
function DoSimpleList()

FrPrn:SetWorkArea("Customers", 1)
FrPrn:SetFieldAliases("Customers", "CUSTNO=Cust No;Company;ADDR1=Address;Phone;Fax;Contact")
lShowCustName := .t.
DoFrAction("1.fr3")
FrPrn:ClearDataSets()
lShowCustName := .f.

return

///////////////////////////////////////////////////////////////////////
function DoSimpleGroup()

FrPrn:SetWorkArea("Customers", 1)
FrPrn:SetFieldAliases("Customers", "CUSTNO=Cust No;Company;ADDR1=Address;Phone;Fax;Contact")
lShowCustName := .t.
DoFrAction("2gr.fr3")
FrPrn:ClearDataSets()
lShowCustName := .f.

return

///////////////////////////////////////////////////////////////////////
function DoMoreComplex()

Select Items
SET ORDER TO 2
lShowCustName := .t.   
FrPrn:SetWorkArea("Customers", 1)
FrPrn:SetFieldAliases("Customers", "CUSTNO=Cust No;Company;ADDR1=Address;Phone;Fax;Contact")  
FrPrn:SetWorkArea("Orders", 2)
FrPrn:SetWorkArea("Items", 3)
FrPrn:SetWorkArea("Parts", 4)           
FrPrn:SetMasterDetail("Customers", "Orders", {||Customer->CustNo})      
FrPrn:SetMasterDetail("Orders", "Items", {||Orders->OrderNo})         
DbSetRelation(4,  {||PartNo})
FrPrn:SetResyncPair("Items", "Parts")
DoFrAction("4.fr3")
FrPrn:ClearDataSets()       
Select Items
DbClearRelation()
lShowCustName := .f.

return

///////////////////////////////////////////////////////////////////////
function DoInFR_MoreComplex()

DoFrAction("md.fr3")

return

///////////////////////////////////////////////////////////////////////
// Esta é para o pessoal que gosta de fazer tudo na unha             //
///////////////////////////////////////////////////////////////////////
function MyManualReport()

FrPrn:SetDefaultFontProperty("Name", "Times New Roman")
FrPrn:SetDefaultFontProperty("Size", 16)
  
tmp_Name := FrPrn:MemoAt("Algum texto com linha abaixo ...", 30, 30, 300, 50)  
FrPrn:SetManualObjProperty(tmp_Name + ".Frame", "Typ", "[ftBottom]")

FrPrn:LineAt(30, 200, 100, 100)
FrPrn:MemoAt("<-- Linha ...", 200, 250, 350, 50)

FrPrn:PictureAt(DataDir + "logo.bmp" , 30, 400, 300, 300)
FrPrn:MemoAt("<-- Figura ...", 350, 420, 320, 50)

FrPrn:NewPage()

FrPrn:MemoAt("Esta é a segunda página..................", 30, 30, 100, 1000)

return

///////////////////////////////////////////////////////////////////////
function DoManualReport()

FrPrn:StartManualBuild({||MyManualReport()}, FR_LANDSCAPE, , FR_PIXELS)
DoFrAction()

return

///////////////////////////////////////////////////////////////////////
function DoMemPict()
    
USE ( DataDir + "Biolife.dbf" ) VIA "DBFCDX" NEW
GO TOP
    
FrPrn:SetWorkArea("Biolife", 5)
DoFrAction("9new.fr3")
    
CLOSE BioLife

return

///////////////////////////////////////////////////////////////////////
function DoUserDS()

PRIVATE aDir, I := 1, DirName := "C:\*.*"

aDir := Directory(DirName)  
FrPrn:SetUserDataSet("Dir", "F_NAME;F_SIZE;F_CREATION_DATE",;
                        {||I := 1}, {||I := I + 1}, ;
                        {||I := I - 1}, {||I > Len(aDir)},;
                        {|aField|xx := IF(aField="F_NAME",1, IF(aField="F_SIZE", 2, 3)) , aDir[I, xx]})

DoFrAction("6.fr3")
FrPrn:ClearDataSets()

return

///////////////////////////////////////////////////////////////////////
function GetDSValue(cField)

local RES 

DO CASE 
CASE cField == "PartNo"
        RETURN Parts->PartNo
CASE cField == "Part"
        RETURN Parts->Descriptio
CASE cField == "Total qty"
        SELECT Items
        OrdScope(0, Parts->PartNo)
        OrdScope(1, Parts->PartNo)
        SUM QTY TO RES
        RETURN RES
CASE cField == "Price"
        RETURN Parts->ListPrice
ENDCASE

return nil

///////////////////////////////////////////////////////////////////////
function DoWAUserDS()

SELECT Items
SET ORDER TO 3      
FrPrn:SetUserDataSet("Parts in oders", "PartNo;Part;Total qty;Price",;
             {|| Parts->( DbGoTop() )} ,;
             {|| Parts->( DbSkip(1) )},;
             {|| Parts->( DbSkip(-1) )},;
             {|| Parts->( Eof() )},;                 
             {|cField| GetDSValue(cField)})

DoFrAction("9.fr3")
SELECT Items
OrdScope(0, nil)
OrdScope(1, nil)
FrPrn:ClearDataSets()

return

///////////////////////////////////////////////////////////////////////
function DoADO()

FrPrn:LoadFromFile(RepDir + "24.fr3")
FrPrn:SetADOConnectPartStr("ADODatabase1", "Data Source", DataDir + "demo.mdb")
DoFrAction()

return

///////////////////////////////////////////////////////////////////////
function DoSomeCalls()

FrPrn:LoadFromFile(RepDir + "7.fr3")
FrPrn:AddVariable("My Lovely Vars", "My and only my var", 10)
FrPrn:AddVariable("My Lovely Vars", "test", 100.25)
FrPrn:AddVariable("My Lovely Vars", "test1", "'Test'")
FrPrn:AddVariable("My Lovely Vars", "test2", ctod("01/01/2007"))
DoFrAction()

return

///////////////////////////////////////////////////////////////////////
function GetExportObject()

local aExpList := {"PDFExport", "HTMLExport", "RTFExport", "CSVExport",;
                   "XLSExport", "DotMatrixExport", "BMPExport", "JPEGExport",;
                   "TXTExport", "TIFFExport", "GIFExport",;
                   "SimpleTextExport", "MailExport", "XMLExport"}
local aDados:={}, aoGets:={}, aTiposExp:={}, lExport := .f.
local oLbx, oDlg

for x=1 to len( aExpList )
        aadd( aTiposExp, { aExpList[x] } )
next        
aadd( aDados, RepDir + 'export'  )
aadd( aDados, .t. )
aadd( aDados, .t. )
aoGets:=array( len( aDados ) )

DEFINE DIALOG oDlg RESOURCE 'EXPORTA' ICON 'DEMO'
oDlg:lHelpIcon := .f.

REDEFINE LISTBOX oLbx FIELDS aTiposExp[oLbx:nat,1];
        HEADERS 'Tipos para exportação';
        COLORS CLR_BLUE,CLR_WHITE;
        FIELDSIZES 250;
        ID 1101 OF oDlg
oLbx:SetArray(aTiposExp)

REDEFINE GET aoGets[1] VAR aDados[1] ID 101 OF oDlg UPDATE 
REDEFINE CHECKBOX aoGets[2] VAR aDados[2] ID 102 OF oDlg
REDEFINE CHECKBOX aoGets[3] VAR aDados[3] ID 103 OF oDlg

REDEFINE BUTTON ID 501 of oDlg ACTION ( lExport:=.t., OnExpRelease(aTiposExp, oLbx, aDados), oDlg:End() )
REDEFINE BUTTON ID 510 of oDlg ACTION oDlg:End()

ACTIVATE DIALOG oDlg CENTERED  

return lExport

///////////////////////////////////////////////////////////////////////
function OnExpRelease(aExpList, oLbx, aDados)

cExpObj  := aExpList[oLbx:nat,1]
cExpFile := aDados[1]
lExpOpt  := aDados[2]
lExpOpen := aDados[3]

return .t.

///////////////////////////////////////////////////////////////////////
function CallUserFunction(FName, FParams)

local RES

if (FName == "XBASESTR")
        RES := Str(FParams[1], FParams[2], FParams[3])    
endif

return RES


///////////////////////////////////////////////////////////////////////
// Verifica se todos os arquivos do vetor de 'aFiles' existem        //
///////////////////////////////////////////////////////////////////////
function AllFilesExist( aFiles )

local lExist := .T., i:=0, imax := len(aFiles)

do while ++i <= imax .and. lExist
        lExist := File( aFiles[i] )
enddo

return lExist

