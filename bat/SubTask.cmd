@echo off
for /l %%n in (%2, 1, %3) do (
	echo %1.%%n
	for /f "tokens=1" %%i in ('tcping %1.%%n -p 8022 -t %6 -c %7 ^| find /i "1 successed"') do (
		echo True 
		copy %4 %4.bak > nul
		echo %1.%%n %5 > %4.tmp
		for /f "tokens=1,* delims=:" %%A in (%4) do ( 
			echo %%A  | findstr /i /v %5 > nul && echo %%A >> %4.tmp
		) 
		rem del %4
		copy %4.tmp %4 > nul
		ipconfig /flushdns
		pause
	)
)

exit