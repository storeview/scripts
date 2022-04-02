@echo off


setlocal enabledelayedexpansion
set /a index=0


echo 『重复的 MAC 地址』：
	for /f "tokens=1,2 delims= " %%a in ('arp -a') do (

		
		set already_exist="false"
		for /l %%n in (0, 1, !index!-1) do (
			set /a ii=%%n
			set /a ii+=1
			if "!ip_list[%%n]!"=="%%a" set already_exist="true"
		)
		
		if !already_exist!=="false" (
			
			rem 添加当前 IP 地址到 IP 列表中
			set ip_list[!index!]=%%a
			set /a index+=1
			
			for /f "tokens=1,2 delims= " %%i in ('arp -a') do (
				if /i not "%%a"=="%%i" (
					if %%b==%%j (
						
						arp -a | findstr %%j
						echo;
						
						set ip_list[!index!]=%%i
						set /a index+=1
					)
				
					rem 添加重复 MAC 的 IP 地址到 IP 列表中，后续就不遍历了		
				)
			)
		)	
	)
pause