@echo off
rem FOR /F "usebackq delims==" %i IN (`dir /b /s "*.ahk"`) DO  Ahk2Exe.exe /in %~nxi
rem 上面那个命令，是在命令行下用的

rem bat文件中，这样用
FOR /F "usebackq delims==" %%i IN (`dir /b /s "*.ahk"`) DO (
echo 正在编译脚本 %%~nxi
Ahk2Exe.exe /in %%~nxi
echo ok!
) 

echo 所有脚本编译完成
rem @pause


rem 参考文章 https://zhidao.baidu.com/question/118069820.html
rem 参考文章 http://www.bathome.net/thread-830-1-1.html