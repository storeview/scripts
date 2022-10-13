@echo off


echo -----------
echo;
echo;
echo 文件：
echo %1
echo;
echo 32 位 MD5 值：
for /f "usebackq" %%s in (`certutil -hashfile %1 MD5 ^| findstr "^[0-9a-z]*$"`) do (set value=%%s)
echo %value%
echo ---
echo;
echo;
echo -----------
echo|set /p=%value%|clip
echo 已经拷贝了到系统剪贴板，直接粘贴使用即可
echo -----------
echo;
echo;


echo 2秒后自动关闭
timeout /t 2
goto comm
常见问题：
	拖入文件到其中后，没有任何输出
		- 该文件可能正在被占用中
		- 文件内容为空
		- 文件格式不支持
改进方向：
	如果给定的是文件夹，希望能够输出文件夹中的所有文件的 Hash 值
		- 需要使用到循环遍历
:comm




