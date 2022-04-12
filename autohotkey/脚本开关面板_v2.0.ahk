; 切换开关的按键，默认为数字小键盘 '+' 键

;--------基本设置-----------------
k_FontSize = 20		; 字体大小
k_FontName = Verdana  	; 字体名字
k_FontStyle = Bold   	; 字体粗细
TransColor = F1ECED	; 背景颜色
i = 1			; 变色标志
x = 1744		;控件x坐标
y = 800			;控件y坐标



Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%
Gui, -Caption +ToolWindow
Gui, Color, %TransColor%
Gui Add, Button, Default w60 vtime
Gui, Show
WinGet, k_ID, ID, A
; 设置图形化界面的坐标，图像显示在桌面的位置
WinMove, A,, x, y
WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %TransColor% 220, ahk_id %k_ID%
;--------循环绘制按钮-------------
Loop
{
Sleep, 200
if i = 1
{
GuiControl, , time, On
i -= 1
}else{
GuiControl, , time, Off
i+=1
}

;--------小键盘 '+' ，暂停脚本--------
KeyWait,NumpadAdd,D
Suspend Toggle 
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

!l::
Send, {Right}      ; Alt + l 快捷键，拥有方向键，右箭头的作用
Return 

!h::
Send, {Left}     ; Alt + h 快捷键，拥有方向键，左箭头的作用
Return 

; 使用 Shift + Insert 按键，可以快速粘贴（Xshell和Powershell中）
; 但是，这样的按键过于麻烦了（Insert键位太远了）
+!i::
Send, +{Insert}  ; Shift + Alt + i 快捷键，进行 shift + Insert 的插入效果
Return
; 同理
^!i::
Send, ^{Insert} ; Ctrl + Alt + i 快捷键，运行 ctrl + Insert 的插入效果
Return

;----- Alt + 鼠标滚轮切换桌面 ------
!WheelUp::Send ^#{Left}
Return
!WheelDown::Send ^#{Right}
Return




; 桌面元素隐藏开关
!q::
HideOrShowDesktopIcons()
Hide2()
return

;隐藏或显示桌面图标
HideOrShowDesktopIcons()
{
    ;使用 Windows Spy 可以监测到桌面上的所有图标都是位于一个 Class 名字为 SycListView321 焦点控件（Focus Control）上，父级是 Progman
	ControlGet, class, Hwnd,, SysListView321, ahk_class Progman
	If class =
		ControlGet, class, Hwnd,, SysListView321, ahk_class WorkerW     ;父级 class 也可能是 WorkerW（Win10系统的缘故吗？）
 
    ; 看起来像是在调用 DLL 命令（暂时没有接触过这部分的脚本内容）
	If DllCall("IsWindowVisible", UInt,class)
		WinHide, ahk_id %class%
	Else
		WinShow, ahk_id %class%
}

;下面的代码用于隐藏最下方的任务栏，看不懂这部分的代码 T.T
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
;NumpadSub:: run	https://withpinbox.com/items ; 减号代表打开 网络收藏夹 网站
;NumpadDot:: run http://flatland.ys168.com/ ; 小数点，打开自己的 flatland 收藏网站
