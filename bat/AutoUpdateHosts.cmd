@echo off

set hostsFile=C:\Windows\System32\drivers\etc\hosts
set domainToRemove=my.site


rem echo ------------------------------------------------------------------------------------------------------------------------
rem echo ��ȡ����Ա������иýű�
rem echo ------------------------------------------------------------------------------------------------------------------------
if exist "%SystemRoot%\SysWOW64" path %path%;%windir%\SysNative;%SystemRoot%\SysWOW64;%~dp0
bcdedit >nul
if '%errorlevel%' NEQ '0' (goto UACPrompt) else (goto UACAdmin)
:UACPrompt
%1 start "" mshta vbscript:createobject("shell.application").shellexecute("""%~0""","::",,"runas",1)(window.close)&exit
exit /B
:UACAdmin
cd /d "%~dp0"
rem echo ------------------------------------------------------------------------------------------------------------------------


rem ---------->��ǰ�Ѵ��ڵ�IP��ַ<----------
for /f "tokens=16" %%i in ('ipconfig /all ^| find /i "IPv4"') do (
	for /f "delims=(" %%a in ("%%i") do (
		rem ---------->��ǰ�Ѵ��ڵ�IP��ַ<----------
		rem echo %%a
		call:genearteNetmask %%a
	)
)

rem ---------->����IP���ɶ�Ӧ��Ĭ����������<----------
rem A(1.0.0.0-126.0.0.0)    B(128.0.0.0-191.255.0.0)    C(192.0.0.0-223.255.255.0)
:genearteNetmask
	set str=%1
	set /a A=126
	set /a C=192
	for /f "tokens=1* delims=." %%a in ("%str%") do (
	    set /a first_str=%%a
	)
	for /f "tokens=1-3 delims=." %%a in ("%str%") do (
	    set "beauty=%%a.%%b.%%c"
	)
	if %first_str% leq %A% ( 
		echo %str%��A���ַ���������� 
		set netmask=255.0.0.0
	) else if %first_str% geq %C% ( 
		echo %str%��C���ַ
		setlocal enabledelayedexpansion
		set /a step=4
		set /a end=0
		for /l %%n in (1, !step!, 254) do (
			set /a "end=step+%%n"  
			start SubTask.cmd %beauty% %%n !end! %hostsFile% %domainToRemove% 1 1
		)
	) else (
		echo %str%��B���ַ����������
	)
goto:eof