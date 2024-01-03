#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


; 当前功能
; 1 将键盘上的大写键盘，同时映射成『Esc』键和『Ctrl』键
; 2 Shift + Alt + i 快捷键，进行 shift + Insert 的插入效果，Ctrl + Alt + i 快捷键，运行 ctrl + Insert 的插入效果
; 3 Alt + 鼠标滚轮切换桌面
; 4 Alt + q 桌面元素隐藏与显示开关


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

Up:: Send, /  



; 使用 Shift + Insert 按键，可以快速粘贴（Xshell和Powershell中）。但是，这样的按键过于麻烦了（Insert键位太远了）
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
HideOrShowTaskBar()
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
HideOrShowTaskBar()
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