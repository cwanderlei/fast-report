@ECHO OFF
REM Gerado pela xDev Studio v0.72 as 06/12/2009 @ 13:45:09
REM Compilador .: xHB build 0.99.50 (SimpLex) & BCC 5.6
REM Destino ....: C:\LIXO_FW\FASTREPORT\DEMO_FWH.EXE
REM Perfil .....: Batch file (Relative Paths)

REM **************************************************************************
REM * Setamos abaixo os PATHs necessarios para o correto funcionamento deste *
REM * script. Se voce for executa-lo em  outra CPU, analise as proximas tres *
REM * linhas abaixo para refletirem as corretas configuracoes de sua maquina *
REM **************************************************************************
 SET PATH=C:\XHB\bin;C:\BCC55\Bin;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem
 SET INCLUDE=C:\XHB\include;C:\BCC55\include;C:\fwh\INCLUDE;C:\Users\Kleyber\Downloads\FRH;
 SET LIB=C:\fwh\LIB;C:\XHB\lib;C:\BCC55\lib;C:\BCC55\lib\psdk;;
 SET OBJ=C:\BCC55\Lib;;

REM - FiveWin.xCompiler.prg(78) @ 13:45:09:968
ECHO .ÿ
ECHO * (1/4) Compilando demo_fwh.prg
 harbour.exe ".\demo_fwh.prg" /q /o".\demo_fwh.c"   /M  /N 
 IF ERRORLEVEL 1 GOTO FIM

REM - FiveWin.xCompiler.prg(113) @ 13:45:10:656
 echo -I"C:\XHB\include;C:\BCC55\include;C:\fwh\INCLUDE;C:\Users\Kleyber\Downloads\FRH;" > "b32.bc"
 echo -L"C:\fwh\LIB;C:\XHB\lib;C:\BCC55\lib;C:\BCC55\lib\psdk;;;C:\BCC55\Lib;;" >> "b32.bc"
 echo -o".\demo_fwh.obj" >> "b32.bc"
 echo ".\demo_fwh.c" >> "b32.bc"

REM - FiveWin.xCompiler.prg(114) @ 13:45:10:656
ECHO .ÿ
ECHO * (2/4) Compilando demo_fwh.c
 BCC32 -M -c @B32.BC
 IF ERRORLEVEL 1 GOTO FIM

REM - FiveWin.xCompiler.prg(78) @ 13:45:10:921
ECHO .ÿ
ECHO * (3/4) Compilando FastRepH.prg
 harbour.exe ".\FastRepH.prg" /q /o".\FastRepH.c"   /M  /N 
 IF ERRORLEVEL 1 GOTO FIM

REM - FiveWin.xCompiler.prg(113) @ 13:45:11:375
 echo -I"C:\XHB\include;C:\BCC55\include;C:\fwh\INCLUDE;C:\Users\Kleyber\Downloads\FRH;" > "b32.bc"
 echo -L"C:\fwh\LIB;C:\XHB\lib;C:\BCC55\lib;C:\BCC55\lib\psdk;;;C:\BCC55\Lib;;" >> "b32.bc"
 echo -o".\FastRepH.obj" >> "b32.bc"
 echo ".\FastRepH.c" >> "b32.bc"

REM - FiveWin.xCompiler.prg(114) @ 13:45:11:375
ECHO .ÿ
ECHO * (4/4) Compilando FastRepH.c
 BCC32 -M -c @B32.BC
 IF ERRORLEVEL 1 GOTO FIM

:FIM
 ECHO Fim do script de compilacao!
