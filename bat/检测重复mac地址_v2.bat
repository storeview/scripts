goto comments
	检测重复 MAC 地址


	版本：v2.0
	时间：2022-4-04
	修改说明：
		1. 优化脚本的执行逻辑，可以将整个问题看成一个算法问题：在数组中找重复的元素
	-------------------->
	版本：v1.0
	时间：2022-4-02
	修改说明：
		1.循环两次，将 mac 地址相同，但是 ip 地址不同的『重复 mac』挑选出来。
		2.找到该 mac 地址之后，不急着将该『重复 mac』放置在 duplicate_mac_list 中，而是在 duplicate_mac_list 中查看是否已存在
		3. 如果 duplicate_mac_list 中不存在当前重复的 mac，则将该 mac 存储到列表中
	算法复杂度：
		时间复杂度：O(N*N)
		空间复杂度：O(1)
comments:


@echo off
setlocal enabledelayedexpansion
set /a duplicate_mac_index=0
set /a new_mac_index=0


echo ; > D://IP_MAC.txt
echo 『重复的 MAC 地址』：> D://IP_MAC.txt
echo 『重复的 MAC 地址』：


rem 遍历 arp -a 输出的每一行
for /f "tokens=1,2 delims= " %%a in ('arp -a') do (
	
	set already_exist_mac=false
	rem 检测当前 MAC 地址，是否存在于 duplicated_mac_list 列表中
	for /l %%n in (0, 1, !duplicate_mac_index!-1) do (
		if "!duplicate_mac_list[%%n]!"=="%%b" set already_exist_mac=true
	)
	
	rem 如果当前 mac 不存在于当前『重复 mac 列表』中
	if !already_exist_mac!==false (
		set already_exist_in_new_mac_list=false
		set already_exist_in_duplicate_mac_list=false
		rem 遍历一遍『新 mac 列表』
		for /l %%n in (0, 1, !new_mac_index!-1) do (
			if "!new_mac_list[%%n]!"=="%%b" set already_exist_in_new_mac_list=true
		)
		rem 如果已存在则记录到 duplicate_mac_list 列表中
		if !already_exist_in_new_mac_list!==true (
			rem 遍历一遍 duplicate_mac_list 查看是否已经存在于该列表中
			for /l %%n in (0, 1, !duplicate_mac_list!-1) do (
				if "!duplicate_mac_list[%%n]!"=="%%b" set already_exist_in_duplicate_mac_list=true
			)
			rem 新添加一个 duplicate_mac
			if !already_exist_in_duplicate_mac_list!==false (
				set duplicate_mac_list[!duplicate_mac_index!]=%%b
				set /a duplicate_mac_index+=1

				arp -a | findstr %%b 
				arp -a | findstr %%b >> D://IP_MAC.txt
				echo;>>D://IP_MAC.txt
				echo;
			)
		)
		rem 如果不存在，则添加到 new_mac_list 列表中
		if !already_exist_in_new_mac_list!==false (
			set new_mac_list[!new_mac_index!]=%%b
			set /a new_mac_index+=1
		)
	)
)


notepad  D://IP_MAC.txt
