@echo off

goto comm
程序逻辑：
    1. 获取管理员权限
    2. 使用echo方法创建一个临时的vbs脚本（此vbs脚本用于：接收参数并创建对应的快捷方式）
    3. 遍历当前目录下所有文件夹，并将  文件夹中的和文件夹同名的exe文件  创建快捷方式  到  指定目录

版本：
    v1.0 文件夹下，一级目录中与文件夹同名的exe程序，会制作成快捷方式到指定文件夹中
:comm


rem 获取管理员权限
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%~dp0"
echo ***************************************************************
echo 当前运行路径是：%CD%
echo 已获取管理员权限




echo ***************************************************************
echo 创建存储图标的文件夹
mkdir 0-绿色软件快捷方式
echo ***************************************************************

rem 使用 echo 制作 vbs 脚本程序（用于生成快捷方式）
echo Dim Shell,DesktopPath,link > makelnk.vbs
echo Set objArgs = WScript.Arguments >> makelnk.vbs
echo Set Shell = CreateObject("WScript.Shell") >> makelnk.vbs
echo DesktopPath = Shell.SpecialFolders("Desktop") >> makelnk.vbs rem 这一步可以省略的，用于创建桌边快捷方式
echo Set link = Shell.CreateShortcut("0-绿色软件快捷方式" ^& "\" ^& objArgs(0) ^& ".lnk") >> makelnk.vbs
echo link.TargetPath = shell.CurrentDirectory ^& "\" ^& objArgs(0) ^& "\" ^& objArgs(0) ^& ".exe" >> makelnk.vbs
echo link.WindowStyle = 1 >> makelnk.vbs
echo link.WorkingDirectory = shell.CurrentDirectory >> makelnk.vbs
echo link.Save >> makelnk.vbs
echo Set Shell = Nothing >> makelnk.vbs
echo Set link = Nothing >> makelnk.vbs


echo .
for /f %%i in ('dir /AD /B') do (
    echo ---------------------------创建快捷方式：%%i 
    for /f %%j in ('dir /A /B %%i\%%i.exe') do (
        echo ————1.正在创建
        makelnk.vbs %%i & echo ————2.创建成功！
    )
)


rem del /f /q makelnk.vbs


echo #############################################################################
echo 注意几点：
echo 程序工作原理
echo 	1. 遍历当前目录，找到所有文件夹，并获取文件夹名称
echo 	2. 将每一个文件夹名称作为变量，遍历该文件夹下的所有文件，找到与之同名的xxx.文件
echo 	3. 在 bat 中写好 vbs 脚本，往里面传入参数进行调用（创建快捷方式的 vbs 的脚本）
echo ...
echo 因此，如果文件夹名字中有空格的话（即传入的参数中有空格），将无法匹配到相应的exe文件
echo ...
echo 程序目前依然存在的改进点：
echo 	如果软件文件夹下，没有 exe 文件，则此脚本无法生成其快捷方式。
echo 	另外，如果软件文件夹下，只有一个与之同名的快捷方式，例如 xxx.exe快捷方式，其在程序中的表示则为 xxx.exe.lkn，目前本程序也是无法生成其快捷方式的。
echo	（后续解决方式：在bat命令程序中，添加 if 判断，如果存在 xxx.exe.lnk 文件，则将其复制到快捷方式文件夹中即可）
echo #############################################################################
pause
