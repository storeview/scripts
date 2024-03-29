goto comments
	检测重复 MAC 地址
	版本：v1.0
	编码说明：
		1.循环两次，将 mac 地址相同，但是 ip 地址不同的『重复 mac』挑选出来。
		2.找到该 mac 地址之后，不急着将该『重复 mac』放置在 duplicate_mac_list 中，而是在 duplicate_mac_list 中查看是否已存在
		3. 如果 duplicate_mac_list 中不存在当前重复的 mac，则将该 mac 存储到列表中

	复杂度：
		时间复杂度：O(N*N)
		空间复杂度：O(1)
comments:


@echo off
setlocal enabledelayedexpansion
set /a index=0
echo ; > D://IP_MAC.txt
echo 『重复的 MAC 地址』：> D://IP_MAC.txt
echo 『重复的 MAC 地址』：
for /f "tokens=1,2 delims= " %%a in ('arp -a') do (
	for /f "tokens=1,2 delims= " %%i in ('arp -a') do (
		if /i not "%%a"=="%%i" (
			if %%b==%%j (
				rem 记录当前重复的 MAC 地址
				set already_exist_mac=false
				for /l %%n in (0, 1, !index!-1) do (
					set /a ii=%%n
					set /a ii+=1
					if "!duplicate_mac_list[%%n]!"=="%%b" set already_exist_mac=true
				)
				rem echo !already_exist_mac!
				rem 如果当前 MAC 地址不存在与列表中，则添加到列表中
				if !already_exist_mac!==false (
					set duplicate_mac_list[!index!]=%%j
					set /a index+=1
					arp -a | findstr %%j 
					arp -a | findstr %%j >> D://IP_MAC.txt
					echo;>>D://IP_MAC.txt
					echo;
				)
			)
		)
	)
)

notepad  D://IP_MAC.txt
