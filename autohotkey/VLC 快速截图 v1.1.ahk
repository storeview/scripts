#SingleInstance,Force

; ---> 变量 <---
k_FontSize = 16		; 字体大小
k_FontName = "宋体"	; 字体名字
k_FontStyle = Bold   	; 字体粗细
TransColor = F1ECED	; 背景颜色

; ---> 全局变量 <---
global MainProgramID := 0
global DeviceID1 := 1
global DeviceID2 := 2
global sThisProgramVersion := "v1.1"
global sThisProgramTitle := "VLC 快速截图 " sThisProgramVersion

Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%

; 第一列 UI 界面
Gui, Add, Text, , 测试场景
Gui, Add, Text, , 图片前缀
Gui, Add, Text, , VLC 截图存储地址
Gui, Add, Text, , 设备名称
Gui, Add, Button, w240 Left gBindDevice1 vDeviceInfo1, VLC-点击绑定1号设备
Gui, Add, Button, w240 Left gBindDevice2 vDeviceInfo2, VLC-点击绑定2号设备
Gui, Add, Text
Gui, Add, Button, gOpenExplore, 打开截图文件夹
Gui, Add, Button, gGenerateHtmlReport, 截图完成，生成HTML报告


; 第二列 UI 界面
Gui, Add, Edit, vTestScene ym
Gui, Add, Edit, vImagePrefix
Gui, Add, Edit, vSavePath
Gui, Add, Text
Gui, Add, Edit, vDeviceName1
Gui, Add, Edit, vDeviceName2
Gui, Add, Text
Gui, Add, Button, w240 gStartSnap, 开始截图 


Gui, Show, , %sThisProgramTitle%
WinGet, MainProgramID, ID, %sThisProgramTitle%
return


StartSnap:
	ControlGetText, TestScene, Edit1
	ControlGetText, ImagePrefix , Edit2
	ControlGetText, SavePath , Edit3
	ControlGetText, DeviceName1 , Edit4
	ControlGetText, DeviceName2 , Edit5
	if (TestScene = "") or (ImagePrefix = "") or (SavePath = "") {
		MsgBox, , 缺少必要的参数, 请检查前三个输入框中是否都有值
		Return
	} else if (DeviceID1 = 1) or (DeviceID2 = 2){
		MsgBox, , VLC 未绑定, 请至少绑定一台 VLC
		Return
	} else {
		; 新建目录
		FileCreateDir, %SavePath%\%TestScene%

		if (DeviceID1 != 1)
			do(DeviceID1, SavePath, TestScene, ImagePrefix, DeviceName1)
		if (DeviceID2 != 2)
			do(DeviceID2, SavePath, TestScene, ImagePrefix, DeviceName2)

		WinActivate, ahk_id %MainProgramID%
	}
Return

; 打开窗口，并开始截图
do(DeviceID, folder, scene, prefix, deviceName){
	;MsgBox, %folder% -- %scene% -- %prefix% -- %deviceName%
	; 激活 vlc 窗口，并截图
	WinActivate, ahk_id %DeviceID%
	Send, {S}
	Sleep, 1000
	; 获取截图文件
	filename := ""
	Loop, Files, %folder%\*.png, F
	filename .= A_LoopFileName
	; 重命名并移动截图文件
	
	RegExMatch(filename, "20[0-9][0-9]-[01][0-9]-[0-3][0-9]-[0-2][0-9]h[0-6][0-9]m[0-6][0-9]s", simpleName)
	
	src := folder "\" filename
	dst := folder "\" scene "\" scene "-" prefix "-" simpleName "-" deviceName ".png"
	;MsgBox, %src%
	;MsgBox, %dst%
	FileMove, %src%, %dst%
}


; 绑定设备1
BindDevice1:
	MsgBox, , 绑定设备, 关闭消息框后，请在 3 秒内点击需要截图的第一个 VLC 设备
	Sleep, 3000
	ActiveHWND  := WinActive("A")
	WinGetClass, CurrentClass, ahk_id %ActiveHWND%
	WinGetTitle, ActiveTitle , ahk_id %ActiveHWND%
	FoundPos := InStr(ActiveTitle, "VLC")
	if (FoundPos != 0) and (CurrentClass = "Qt5QWindowIcon") {
		MsgBox, , 成功, 获取到了 VLC 窗口：%ActiveTitle%
		WinActivate, ahk_id %MainProgramID%
		RegExMatch(ActiveTitle, "[0-9]+(\.[0-9]+){3}", DeviceIP)
		DeviceID1 := ActiveHWND
		GuiControl, , DeviceInfo1, VLC-%DeviceIP%
	} else {
		MsgBox, , 失败, 没有获取到 VLC 窗口
	}
Return


; 绑定设备2
BindDevice2:
	MsgBox, , 绑定设备, 关闭消息框后，请在 3 秒内点击需要截图的第二个 VLC 设备
	Sleep, 3000
	ActiveHWND  := WinActive("A")
	WinGetClass, CurrentClass, ahk_id %ActiveHWND%
	WinGetTitle, ActiveTitle , ahk_id %ActiveHWND%
	FoundPos := InStr(ActiveTitle, "VLC")
	if (FoundPos != 0) and (CurrentClass = "Qt5QWindowIcon") {
		MsgBox, , 成功, 获取到了 VLC 窗口：%ActiveTitle%
		WinActivate, ahk_id %MainProgramID%
		RegExMatch(ActiveTitle, "[0-9]+(\.[0-9]+){3}", DeviceIP)
		DeviceID2 := ActiveHWND
		GuiControl, , DeviceInfo2, VLC-%DeviceIP%
	} else {
		MsgBox, , 失败, 没有获取到 VLC 窗口
	}
Return


; 打开【截图】文件夹（使用文件浏览器）
OpenExplore:
	ControlGetText, OpenPath , Edit3
	if (OpenPath = "") {
		MsgBox, , 错误, 请正确填写【VLC 截图存储地址】信息
		Return
	}	
	Run, explore %OpenPath%
Return


; 生成 HTML 报表
GenerateHtmlReport:
	ControlGetText, OpenPath , Edit3
	if (OpenPath = "") {
		MsgBox, , 错误, 请正确填写【VLC 截图存储地址】信息
		Return
	}	


	; 调用本地python文件命令（待补充）
	BatPath := "./vlc_quick_snap_requirements/GenerateSnapPictureHTML.bat"
	Run %ComSpec% /c ""%BatPath%" "%OpenPath%""
return


; 退出程序
GuiClose:
	ExitApp
Return



