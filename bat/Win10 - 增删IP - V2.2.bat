@echo off

goto comm
## 程序完成的功能

在 Windows 下快速添加、删除电脑 IP

【当电脑访问一类 IP 地址的时候，必须自身具备相同的类别（一类、二类、三类）的 IP 地址。】
【在 Windows 下删除和添加 IP 地址，特别麻烦】
【由此产生了制作此脚本的想法】

新需求：
	- 
目前存在的问题：
	- 明明通过 ping 和 arp -a 两个方法测试得到的 IP，添加之后，依然显示复制

-------------------------------------------------------------------------------------
日期：2021年8月6日
版本：v1.0 
修改内容：
	可以进行 IP 的添加与删除

日期：2021年12月29日
版本：v2.0
修改内容：
	通过 ping 的方式查看是否 IP 已经被占用
	新增 IP 的时候，默认不添加网关
	自动识别 A、B、C 类 IP，然后自动生成子网掩码
	删除 IP 的时候，将现有的 IP 列出来，供用户选择删除哪一个

日期：2022年1月12日
版本：v2.1
修改内容：
	在脚本内部添加版本说明

日期：2022年1月12日
版本：v2.2
修改内容：
	反向删除（删除全部的IP，除了选中的）
-------------------------------------------------------------------------------------
:comm


rem echo ------------------------------------------------------------------------------------------------------------------------
rem echo 获取管理员身份运行该脚本
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
rem echo 根据操作系统设置需要操作的网卡名称，并存储在变量中 local_lan
rem echo ------------------------------------------------------------------------------------------------------------------------
ver | findstr /r /i " [版本 5.1.*]" > NUL && set local_lan=本地连接
ver | findstr /r /i " [版本 6.1.*]" > NUL && set local_lan=本地连接
ver | find "5.2." > NUL &&  set local_lan=本地连接
ver | find "6.2." > NUL &&  set local_lan=本地连接
ver | find "6.3." > NUL &&  set local_lan=本地连接
ver | find "10" > NUL &&  set local_lan=以太网
rem echo ------------------------------------------------------------------------------------------------------------------------


set ip=
set netmask=
set gateway=


call:showGui
call:exitApp

rem ---------->显示终端图形化的界面<----------
:showGUI
	cls
	echo *************************************************************************
	echo 当前 【%local_lan%】 下的 IP 有：
	ipconfig /all | find /i "IPv4"
	echo *************************************************************************

	set /p addOrDelete="添加还是删除IP地址？（1.添加IP   2.删除IP   3.执行ipconfig命令   4.只保留一个IP[可恢复]   5.退出）"
	if "%addOrDelete%"=="1"	call:addIP
	if "%addOrDelete%"=="2"	call:deleteIP
	if "%addOrDelete%"=="3"	call:runIpconfig
	if "%addOrDelete%"=="4"	call:deleteAllexceptIP
	if "%addOrDelete%"=="5"	call:exitApp
	if "%addOrDelete%"==""	call:showGUI
goto:eof




rem ---------->添加一个新的IP<----------
:addIP
	echo *************************************************************************
	echo 【添加IP】
	set /p _ip="请输入 IP 地址："
	if "%_ip%"=="" call:showGui

	set ip=%_ip%
	call:checkIPValid %_ip% ip_is_valid

	if %ip_is_valid% == true (
		call:checkIPExist %_ip% ip_is_exist
	) else (
		echo IP格式错误
		pause
		call:showGui
	)

	if %ip_is_exist% == true (
		echo IP地址已经存在
		pause
		call:showGui
	)
	call:genearteNetmask %_ip%


	set /p _netmask="请输入网络掩码（通过IP计算得出%netmask%，回车选择该值）："
	if "%_netmask%"=="" set _netmask=%netmask%
		
	set /p _gateway="请输入网关（默认可不填写。直接敲击回车即可）："
	if "%_gateway%"=="" set _gateway=%gateway%

	netsh interface ip add address %local_lan% %_ip% %_netmask% %_gateway%
	call:showGui
goto:eof


rem ---------->删除某个IP地址<----------
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
	echo 【删除IP】
	set /a index-=1
	for /l %%n in (0, 1, %index%-1) do (
		set /a ii=%%n
		set /a ii+=1
		echo [!ii!]. !ip_list[%%n]!
	)
	echo *************************************************************************
	set /p _ip2delete="请输入需要删除的IP地址序号："
	if "%_ip2delete%" == "" call:showGui
	set /a ip2delete=_ip2delete
	set /a ip2delete-=1
	netsh interface ipv4 delete address %local_lan% !ip_list[%ip2delete%]!

	call:showGui
goto:eof


rem ---------->暂时删除所有IP（可恢复），除了选定的IP<----------
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
	echo 【只保留一个 IP】
	set /a index-=1
	for /l %%n in (0, 1, %index%-1) do (
		set /a ii=%%n
		set /a ii+=1
		echo [!ii!]. !ip_list[%%n]!
	)
	echo *************************************************************************
	set /p _ipNot2delete="请输入需要保留的IP地址序号（其他IP全部删除）："
	if "%_ipNot2delete%" == "" call:showGui
	set /a ipNot2delete=_ipNot2delete
	set /a ipNot2delete-=1
	for /l %%n in (0, 1, %index%-1) do (
		if %ipNot2delete% == %%n (echo 保留了IP：!ip_list[%%n]!) else (netsh interface ipv4 delete address %local_lan% !ip_list[%%n]!)
	)
	
	echo *************************************************************************
	echo 【执行 ipconfig 命令】
	ipconfig
	echo *************************************************************************
	
	set /p restore="按回车恢复 IP 地址："
	for /l %%n in (0, 1, %index%-1) do (
		call:genearteNetmask !ip_list[%%n]!
		set _netmask=%netmask%
		set _gateway=%gateway%
		if %ipNot2delete% == %%n (echo IP：!ip_list[%%n]!) else (netsh interface ip add address %local_lan% !ip_list[%%n]! %_netmask% %_gateway%)
		
	)

	call:showGui
goto:eof

rem ---------->检查IP格式的有效性<----------
:checkIPValid
	set "%~2=true"
goto:eof


rem ---------->检查IP是否已经存在<----------
:checkIPExist
	set ip_is_exist=true
	ping %1 -n 1 -w 200 > NUL && set "%~2=true" || set "%~2=false"
	arp -a | findstr %1 > NUL && set "%~2=true" || set "%~2=false"
goto:eof


rem ---------->依据IP生成对应的默认子网掩码<----------
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


rem ---------->执行ipconfig命令<----------
:runIpconfig
	echo *************************************************************************
	echo 【执行 ipconfig 命令】
	ipconfig
	echo *************************************************************************
	pause
	call:showGui
goto:eof

rem ---------->退出程序<----------
:exitApp
	exit 0
goto:eof
