; 切换开关的按键，默认为数字小键盘 '+' 键

;--------基本设置-----------------
k_FontSize = 20		; 字体大小
k_FontName = Verdana  	; 字体名字
k_FontStyle = Bold   	; 字体粗细
TransColor = F1ECED	; 背景颜色
i = 1			; 变色标志
x = 1744		;控件x坐标
y = 652			;控件y坐标


;--------循环绘制按钮-------------
Loop
{
Sleep, 50
Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%
Gui, -Caption +ToolWindow
Gui, Color, %TransColor%
if i = 1
{
;Gui, Add, Button,Default w60, On
i -= 1
}else{
;Gui, Add, Button,Default w60, Off
i+=1
}
Gui, Show
WinGet, k_ID, ID, A
; 设置图形化界面的坐标，图像显示在桌面的位置
WinMove, A,, x, y
WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %TransColor% 220, ahk_id %k_ID%
;--------小键盘 '+' ，暂停脚本--------
KeyWait,NumpadAdd,D
Suspend Toggle 
Gui,Destroy
}


;--------映射鼠标按键（改键）--------
;a::a	;将键盘上的a键改成了b键

; 将键盘上的大写键盘，同时映射成『Esc』键和『Ctrl』键
SetCapsLockState, alwaysoff
Capslock::
Send {LControl Down}
KeyWait, CapsLock
Send {LControl Up}
if ( A_PriorKey = "CapsLock" )
{
    Send {Esc}
}
return 

;--------组合键--------
^;::
Send, !{f4}       ; Ctrl + ; 快捷键，拥有 Alt+F4 的功能。原版的 Alt+F4 太难用了
Return

^l::
Send, {Right}      ; Ctrl + l 快捷键，拥有方向键，右箭头的作用
Return 

^h::
Send, {Left}     ; Ctrl + h 快捷键，拥有方向键，左箭头的作用
Return 


;!RButton::
;Send, !{Space}{n} ; Alt+RButton 快捷键，拥有 Alt+Space+n的缩小当前行功能
;Return

;!RButton::
;Send fail
;Send {f}{a}{i}{l}
;Return
;!LButton::
;Send pass
;Return

;----- Alt + 鼠标滚轮切换桌面 ------
!WheelUp::Send ^#{Left}
Return
!WheelDown::Send ^#{Right}
Return
;------------
;PgDn::Send ^#{Left}
;Return
;PgUp::Send ^#{Right}
;Return




!q::
HideOrShowDesktopIcons()
Hide2()
return
 
HideOrShowDesktopIcons()
{
	ControlGet, class, Hwnd,, SysListView321, ahk_class Progman
	If class =
		ControlGet, class, Hwnd,, SysListView321, ahk_class WorkerW
 
	If DllCall("IsWindowVisible", UInt,class)
		WinHide, ahk_id %class%
	Else
		WinShow, ahk_id %class%
}

Hide2()
{
	VarSetCapacity( APPBARDATA, 36, 0 )
	IfWinNotExist, ahk_class Shell_TrayWnd
	{
		NumPut( (ABS_AlwaysOnTOP := 0x2), APPBARDATA, 32, "UInt" )           ;Enable "Always on top" (& disable auto-hide)
		DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
		WinShow ahk_class Shell_TrayWnd
	}
	else
	{
		NumPut( ( ABS_AUTOHIDE := 0x1 ), APPBARDATA, 32, "UInt" )            ;Disable "Always on top" (& enable auto-hide to hide Start button)
		DllCall( "Shell32.dll\SHAppBarMessage", "UInt", ( ABM_SETSTATE := 0xA ), "UInt", &APPBARDATA )
		WinHide ahk_class Shell_TrayWnd
	}
}

;--------映射数字小键盘--------
;Numpad0:: run	D:\WorkSpace\myGitFile\gitee\funny_ideas\ahk\AutoHotkey\Compiler\定时护眼.exe ;定时护眼
;Numpad1:: run	http://localhost:8888/
;Numpad2:: run	http://202.200.48.24/
;Numpad3:: run	https://music.163.com/
;Numpad4:: run	https://mp.csdn.net/console/article ;CSDN博客+
;Numpad5:: run	https://www.notion.so/
;Numpad6:: run	https://aur.one/ ;打开一个开始
;Numpad7:: run	shutdown -a ;取消关机
;Numpad8:: run	E:\Software2\VKeeper\VKeeper.exe
;Numpad9:: run	shutdown -s -t 60 ;60秒后自动关机 
;NumpadSub:: run	https://withpinbox.com/items ; 减号代表打开 网络收藏夹 网站
;NumpadDot:: run http://flatland.ys168.com/ ; 小数点，打开自己的 flatland 收藏网站
