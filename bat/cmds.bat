@echo off

goto comm
程序逻辑：
1. 获取管理员权限（这一部分代码，从网上复制的）
2. 使用管理员权限【运行程序】或【进行操作】
:comm

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

start