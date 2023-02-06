@echo off

goto comm
## ������ɵĹ���

�� Windows �¿�����ӡ�ɾ������ IP

�������Է���һ�� IP ��ַ��ʱ�򣬱�������߱���ͬ�����һ�ࡢ���ࡢ���ࣩ�� IP ��ַ����
���� Windows ��ɾ������� IP ��ַ���ر��鷳��
���ɴ˲����������˽ű����뷨��

������
	- 
Ŀǰ���ڵ����⣺
	- ����ͨ�� ping �� arp -a �����������Եõ��� IP�����֮����Ȼ��ʾ����
	- ����ɾ����ɾ��ȫ����IP������ѡ�еģ���һ���ǿ����Զ��ָ��ģ���������ű��쳣�˳�����ָ����ˡ�


ע�⣺
	- ����ɾ����ȫ���� IP �ᱣ�������� IP ��Ӧ���������룬������б�����

-------------------------------------------------------------------------------------
���ڣ�2021��8��6��
�汾��v1.0 
�޸����ݣ�
	���Խ��� IP �������ɾ��

���ڣ�2021��12��29��
�汾��v2.0
�޸����ݣ�
	ͨ�� ping �ķ�ʽ�鿴�Ƿ� IP �Ѿ���ռ��
	���� IP ��ʱ��Ĭ�ϲ��������
	�Զ�ʶ�� A��B��C �� IP��Ȼ���Զ�������������
	ɾ�� IP ��ʱ�򣬽����е� IP �г��������û�ѡ��ɾ����һ��

���ڣ�2022��1��12��
�汾��v2.1
�޸����ݣ�
	�ڽű��ڲ���Ӱ汾˵��

���ڣ�2022��1��12��
�汾��v2.2
�޸����ݣ�
	����ɾ����ɾ��ȫ����IP������ѡ�еģ�

-------------------------------------------------------------------------------------
:comm


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


rem echo ------------------------------------------------------------------------------------------------------------------------
rem echo ���ݲ���ϵͳ������Ҫ�������������ƣ����洢�ڱ����� local_lan
rem echo ------------------------------------------------------------------------------------------------------------------------
ver | findstr /r /i " [�汾 5.1.*]" > NUL && set local_lan=��������
ver | findstr /r /i " [�汾 6.1.*]" > NUL && set local_lan=��������
ver | find "5.2." > NUL &&  set local_lan=��������
ver | find "6.2." > NUL &&  set local_lan=��������
ver | find "6.3." > NUL &&  set local_lan=��������
ver | find "10" > NUL &&  set local_lan=��̫��
rem echo ------------------------------------------------------------------------------------------------------------------------


set ip=
set netmask=
set gateway=


call:showGui
call:exitApp

rem ---------->��ʾ�ն�ͼ�λ��Ľ���<----------
:showGUI
	cls
	echo *************************************************************************
	echo ��ǰ ��%local_lan%�� �µ� IP �У�
	ipconfig /all | findstr "IPv4"
	echo *************************************************************************

	set /p addOrDelete="��ӻ���ɾ��IP��ַ����1.���IP   2.ɾ��IP   3.ִ��ipconfig����   4.ֻ����һ��IP[�ɻָ�]   5.�˳���"
	if "%addOrDelete%"=="1"	call:addIP
	if "%addOrDelete%"=="2"	call:deleteIP
	if "%addOrDelete%"=="3"	call:runIpconfig
	if "%addOrDelete%"=="4"	call:deleteAllexceptIP
	if "%addOrDelete%"=="5"	call:exitApp
	if "%addOrDelete%"==""	call:showGUI
goto:eof




rem ---------->���һ���µ�IP<----------
:addIP
	echo *************************************************************************
	echo �����IP��
	set /p _ip="������ IP ��ַ��"
	if "%_ip%"=="" call:showGui

	set ip=%_ip%
	call:checkIPValid %_ip% ip_is_valid

	if %ip_is_valid% == true (
		call:checkIPExist %_ip% ip_is_exist
	) else (
		echo IP��ʽ����
		pause
		call:showGui
	)

	if %ip_is_exist% == true (
		echo IP��ַ�Ѿ�����
		pause
		call:showGui
	)
	call:genearteNetmask %_ip%


	set /p _netmask="�������������루ͨ��IP����ó�%netmask%���س�ѡ���ֵ����"
	if "%_netmask%"=="" set _netmask=%netmask%
		
	set /p _gateway="���������أ�Ĭ�Ͽɲ���д��ֱ���û��س����ɣ���"
	if "%_gateway%"=="" set _gateway=%gateway%

	netsh interface ip add address %local_lan% %_ip% %_netmask% %_gateway%
	call:showGui
goto:eof


rem ---------->ɾ��ĳ��IP��ַ<----------
:deleteIP
	setlocal enabledelayedexpansion
	set /a index=0
	for /f "tokens=16" %%i in ('ipconfig /all ^| find /i "IPv4"') do (
		for /f "delims=(" %%a in ("%%i") do (
			set ip_list[!index!]=%%a
			set /a index+=1
		)
	)

	echo *************************************************************************
	echo ��ɾ��IP��
	set /a index-=1
	for /l %%n in (0, 1, %index%-1) do (
		set /a ii=%%n
		set /a ii+=1
		echo [!ii!]. !ip_list[%%n]!
	)
	echo *************************************************************************
	set /p _ip2delete="��������Ҫɾ����IP��ַ��ţ�"
	if "%_ip2delete%" == "" call:showGui
	set /a ip2delete=_ip2delete
	set /a ip2delete-=1
	netsh interface ipv4 delete address %local_lan% !ip_list[%ip2delete%]!

	call:showGui
goto:eof


rem ---------->��ʱɾ������IP���ɻָ���������ѡ����IP<----------
:deleteAllexceptIP
	setlocal enabledelayedexpansion
	set /a index=0
	for /f "tokens=16" %%i in ('ipconfig /all ^| find /i "IPv4"') do (
		for /f "delims=(" %%a in ("%%i") do (
			set ip_list[!index!]=%%a
			set /a index+=1
		)
	)

	echo *************************************************************************
	echo ��ֻ����һ�� IP��
	set /a index-=1
	for /l %%n in (0, 1, %index%-1) do (
		set /a ii=%%n
		set /a ii+=1
		echo [!ii!]. !ip_list[%%n]!
	)
	echo *************************************************************************
	set /p _ipNot2delete="��������Ҫ������IP��ַ��ţ�����IPȫ��ɾ������"
	if "%_ipNot2delete%" == "" call:showGui
	set /a ipNot2delete=_ipNot2delete
	set /a ipNot2delete-=1
	for /l %%n in (0, 1, %index%-1) do (
		if %ipNot2delete% == %%n (echo ������IP��!ip_list[%%n]!) else (netsh interface ipv4 delete address %local_lan% !ip_list[%%n]!)
	)
	
	echo *************************************************************************
	echo ��ִ�� ipconfig ���
	ipconfig
	echo *************************************************************************
	
	set /p restore="���س��ָ� IP ��ַ��"
	for /l %%n in (0, 1, %index%-1) do (
		call:genearteNetmask !ip_list[%%n]!
		set _netmask=%netmask%
		set _gateway=%gateway%
		if %ipNot2delete% == %%n (echo IP��!ip_list[%%n]!) else (netsh interface ip add address %local_lan% !ip_list[%%n]! %_netmask% %_gateway%)
		
	)

	call:showGui
goto:eof

rem ---------->���IP��ʽ����Ч��<----------
:checkIPValid
	set "%~2=true"
goto:eof


rem ---------->���IP�Ƿ��Ѿ�����<----------
:checkIPExist
	set ip_is_exist=true
	ping %1 -n 1 -w 200 > NUL && set "%~2=true" || set "%~2=false"
	arp -a | findstr %1 > NUL && set "%~2=true" || set "%~2=false"
goto:eof


rem ---------->����IP���ɶ�Ӧ��Ĭ����������<----------
rem A(1.0.0.0-126.0.0.0)    B(128.0.0.0-191.255.0.0)    C(192.0.0.0-223.255.255.0)
:genearteNetmask
	set str=%1
	set /a A=126
	set /a C=192
	for /f "tokens=1* delims=." %%a in ("%str%") do (
	    set /a first_str=%%a
	)
	if %first_str% leq %A% ( 
		set netmask=255.0.0.0
	) else if %first_str% geq %C% ( 
		set netmask=255.255.255.0
	) else (
		set netmask=255.255.0.0
	)
goto:eof


rem ---------->ִ��ipconfig����<----------
:runIpconfig
	echo *************************************************************************
	echo ��ִ�� ipconfig ���
	ipconfig
	echo *************************************************************************
	pause
	call:showGui
goto:eof

rem ---------->�˳�����<----------
:exitApp
	exit 0
goto:eof
