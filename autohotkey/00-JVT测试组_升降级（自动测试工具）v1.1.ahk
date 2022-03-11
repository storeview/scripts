; 自动升级工具 -- by lilinfang
; https://www.autohotkey.com
; 本脚本用于【深圳市巨龙创视科技有限公司】的系统工具的
; 重复升降级（自动化测试），并进行一定的日志记录
;
;*****************************************************************
;
; 脚本功能特点：
;	- 通过窗口标题识别到窗口（BatchConfig、BConfig），进而可以操作该窗口
;	- 点击【...】按钮坐标，将选择需要升级的文件
;	- 点击【升级】按钮所处的坐标，进行升级
;	- 定时器机制，设定一次升级的固定时间，升级过程中时刻显示倒计时
;	- 每次升级均会记录到日志中
;
;*****************************************************************
;
; 使用方法：
; 	1. 打开一个 BatchConfig 或 BConfig 窗口
;	3. 在窗口中，勾选好需要升级的设备
;	4. 将窗口拖动到屏幕边缘，不影响电脑正常使用的位置
;	5. 打开脚本 exe 文件，选择需要交叉升级的两个一键升级xml文件，选择每一个文件大概所需的升级时间
;	6. 脚本会持续运行
;
;*****************************************************************
;
;
;
;
;*****************************************************************
;
; 修改说明：
; 
; * v1.0
; * 初始版本
; * v1.1
; * 1. 修复问题：倒计时过程中，界面不断刷新，影响正常使用
; * 2. 同时兼容 BatchConfig 2.0版本和 BConfig 2.0版本的升级
; * 3. 添加功能：
; * 	- 用户预先选择好需要循环升级的两个版本文件，后续可自动升级该两个版本
; * 4. 调整 UI 界面布局
; * 
;
;*****************************************************************
;
;




;*****************************************************************
;
; ---> 全局变量 <---
global version = "v1.0.2 debug"	; 当前版本号
global UpdateProgramType	; 一次升级所需要的时间
global CountDownTime = 0	; 每次倒计时的时长
global message			; Gui文本显示的信息
;
; ---> 变量 <---
k_FontSize = 16		; 字体大小
k_FontName = "宋体"	; 字体名字
k_FontStyle = Bold   	; 字体粗细
TransColor = F1ECED	; 背景颜色


;
;*****************************************************************
;
; 巨龙升级程序对象类
;
Class UpdateProgramJVT{
	__New(sTitle, sUpdateBtnXY, sFileSelectorBtnXY){
		; 程序标题
		this.title := sTitle
		; 升级按钮坐标
		this.updateXY := sUpdateBtnXY
		; 升级文件选择坐标
		this.fileSelectorXY := sFileSelectorBtnXY
	}
}
;
;*****************************************************************
;
; 新建巨龙升级程序对象方法
; 对象名称 := New UpdateProgramJVT(标题名称, 升级按钮坐标, 文件选择按钮坐标)
;



; 绘制用户信息输入UI界面，由于一些限制，导致此窗口不能放入一个函数中
Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%

Gui, Add, Text,h30 , 选择升级程序:
Gui, Add, Text,h30 , 当前选择升级的版本
Gui, Add, Button,h30 vFileSelector1 gSelectUpdateFile1, 选择升级文件1
Gui, Add, Button,h30 vFileSelector2 gSelectUpdateFile2, 选择升级文件2


; 不支持 pConfig
;Gui, Add, DropDownList, vUpdateProgramType Choose1 ym, BatchConfig|pConfig|BConfig
Gui, Add, DropDownList, vUpdateProgramType Choose1 ym, BatchConfig|BConfig
Gui, Add, Text, h30, 选中的升级文件
; 显示选择的文件
Gui, Add, Edit, h30 vSelectedFile1
Gui, Add, Edit, h30 vSelectedFile2 

Gui, Add, Text, h30  ym,  
Gui, Add, Text,h30 , 升级时间
Gui, Add, Edit , h30 w95
Gui, Add, UpDown , h30 vUpdateTime1 Range1-20, 6  
Gui, Add, Edit , h30 w95
Gui, Add, UpDown , h30 vUpdateTime2 Range1-20, 6  
Gui, Add, Text, h30 ,  
Gui, Add, Button, h30 gStartUpdate, 开始升级

; 获得升级时间，由于一些限制，导致此窗口不能放入一个函数中
getUpdateTimeFromGUI:
	Gui, Show,, 前置条件
	return  ; 自动运行段结束. 在用户进行操作前脚本会一直保持空闲状态.

	; 如果点击的是 OK 按钮，则提交数据
	StartUpdate:
		Gui, Submit  ; 保存用户的输入到每个控件的关联变量中.
		; 变量：%UpdateProgramType%、%SelectedFile1%、%SelectedFile2%、%UpdateTime1%、%UpdateTime2%
		SplitPath, SelectedFile1 , filename1, dir1 
		SplitPath, SelectedFile2 , filename2, dir2 
		RegExMatch(SelectedFile1, "[0-9]+(\.[0-9]+){3}", sVersion1)
		RegExMatch(SelectedFile2, "[0-9]+(\.[0-9]+){3}", sVersion2)
		MsgBox, 4, 确认升级, 你选择了 %sVersion1% 版本和 %sVersion2% 版本，使用 %UpdateProgramType% 进行升级，是否确认？
		; 选择继续升级或者重选
		IfMsgBox Yes 
			; 分割文件地址为filename和directory
			goto nextStep
		IfMsgBox No
			goto getUpdateTimeFromGUI
	GuiClose:
		ExitApp


; 获取到了 UpdateTime 值以后，进行下一步
nextStep:
	; 依据选择的升级程序类型，初始化相应对象
	if (UpdateProgramType = "BatchConfig"){
		oUpdateProgram := New UpdateProgramJVT("BatchConfig", "x130 y690", "x425 y660")
	} else if (UpdateProgramType = "pConfig") {
		oUpdateProgram := New UpdateProgramJVT("pConfig", "x825 y522", "x777 y522")
	} else if (UpdateProgramType = "BConfig") {
		oUpdateProgram := New UpdateProgramJVT("BConfig", "x130 y790", "x450 y760")
	}
	
	sleep, 2000

	; 循环，直到有两个 BatchConfig 客户端才出循环
	count = 0	; 记录升级过的次数
	log("********** 开始自动升级 **********")
	Loop{
		; 得到标题含有 BatchConfig 的窗口 ID 列表
		WinGet, BatchConfigID, ID, % oUpdateProgram.title

		; 当值不为空的时候
		if (BatchConfigID != ""){
			; 先升级（第一个）一键升级包
			; 打开升级文件
			log("打开 " sVersion1 " 升级文件")
			ControlClick, % oUpdateProgram.fileSelectorXY, ahk_id %BatchConfigID%,,,1
			WinGetTitle, targetTitle , ahk_id %BatchConfigID%
			openUpdateFile( targetTitle, dir1,filename1)

			log("点击 " sVersion1 " 升级按钮")
			ControlClick, % oUpdateProgram.updateXY, ahk_id %BatchConfigID%

			log("正在升级 " sVersion1 " 中，预计等待时间 " UpdateTime1 " 分钟")
			setCountDown(UpdateTime1) 
			Sleep, UpdateTime1*60*1000
			log("升级完成")

			log("打开 " sVersion2 " 升级文件")
			ControlClick, % oUpdateProgram.fileSelectorXY, ahk_id %BatchConfigID%,,,1
			WinGetTitle, targetTitle , ahk_id %BatchConfigID%
			openUpdateFile(targetTitle, dir2,filename2)

			log("点击 " sVersion2 " 升级按钮")
			ControlClick, % oUpdateProgram.updateXY, ahk_id %BatchConfigID%

			log("正在升级 " sVersion2 " 中，预计等待时间 " UpdateTime2 " 分钟")
			setCountDown(UpdateTime2)
			Sleep, UpdateTime2*60*1000
			log("升级完成")


			count++
			log("### 升级次数：" count " ###")

		} else {
			; 进行提示
			sProgramTitle := % oUpdateProgram.title
			MsgBox, 4,警告, 当前不存在 %sProgramTitle% 程序，是否重试？
			IfMsgBox Yes
				continue
			else
				log("**********     退出     **********")
				Gui,Destroy
				ExitApp
		}

	}


; ---> 函数 <---
; 识别到一个活动的文件选择窗口，自动选择目录及文件
openUpdateFile(targetTitle,  directory, filename){
	; 点击文件选择框
	;ControlClick, % oUpdateProgram.fileSelectorXY, ahk_id %iUpdateProgramHWND%
	; 等待窗口打开
	Sleep, 500
	; 获得当前激活状态的窗口
	ActiveHWND  := WinActive("A")
	WinGetClass, CurrentClass, ahk_id %ActiveHWND%
	If (CurrentClass="#32770"){
		OwnerHWND   := DllCall("GetWindow","UInt",ActiveHWND,"UInt",4)
		; 获得父级标题
		WinGetTitle, parentTitle, ahk_id %OwnerHWND%
		if (InStr(parentTitle, targetTitle) != 0){
			sleep, 500
			ControlSend , Edit2, {Ctrl Down}a{Ctrl Up}, ahk_id %ActiveHWND%
			sleep, 500
			ControlSend , Edit2, {DEL}, ahk_id %ActiveHWND%
			Clipboard = %directory%
			sleep, 500	
			ControlSend , Edit2, {Ctrl Down}v{Ctrl Up}, ahk_id %ActiveHWND%
			sleep, 500
			ControlSend , Edit2, {ENTER}, ahk_id %ActiveHWND%
			sleep, 500

			Clipboard = %filename%
			sleep, 500
			ControlSend , Edit1, {Ctrl Down}v{Ctrl Up}, ahk_id %ActiveHWND%
			sleep, 500

			; 点击确定
			ControlClick, Button1, ahk_id %ActiveHWND%, , , 2
		}
	}
}




; 设置 UI，该UI界面会经常刷新，该函数也将经常调用
; msg -- 界面上显示的消息
; create_gui_flag -- 决定是否创建新的GUI，如果是1则创建，是0则只更新GUI界面
setGUI(msg, create_gui_flag:=1){
	; 创建一个 gui 界面
	if (create_gui_flag = 1){
		Gui, Destroy
		Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%
		Gui, -Caption +ToolWindow
		Gui, Color, %TransColor%

		Gui, Add, Text,vmessage, %msg% 

		Gui, Show, NoActivate,UpdateProgramStatus
		WinGet, k_ID, ID,  UpdateProgramStatus
		WinSet, AlwaysOnTop, On, ahk_id %k_ID%
		WinMove, UpdateProgramStatus,, A_ScreenWidth/2-k_FontSize*strlen(msg)/10, 0
	} 
	; 更新该 gui 界面
	else {
		WinGet, k_ID, ID,  UpdateProgramStatus
		WinSet, AlwaysOnTop, Off, ahk_id %k_ID%
		GuiControl, , message, %msg%
	}
}


; 写入日志到文件
; msg -- 日志信息
writeLog2File(msg){
	FormatTime, currentTime ,%A_NOW%,  yyyy-MM-dd HH:mm:ss
	temp = [%currentTime%]  %msg% 
	writeStr .=  temp . "`r`n"
	FormatTime, currentDate ,%A_NOW%,  yyyy-MM-dd
	fileappend, %writeStr% ,AutoUpdate-log-%currentDate%.txt,UTF-8

}


; 分别将日志输出到 UI 界面和文件中
; msg -- 日志信息
log(msg){
	Sleep, 1000

	setGUI(msg)
	writeLog2File(msg)

	Sleep, 2000
}


; 格式化数字，无论是个位数还是十位数，都显示为十位数
; _val -- 需要格式化的数字
; return 返回格式化后的数字
Format2Digits(_val)
{
   _val += 100
   StringRight _val, _val, 2
   Return _val
}
Return


; 设置倒计时
; time -- 倒计时时间
setCountDown(time){
	; 设置倒计时时间
	UpdateTime := time
	CountDownTime := 60 * UpdateTime
	SetTimer TicTac, 1000
	Sleep, 2000 
	return
}


; 选择文件
; 按钮绑定事件
SelectUpdateFile1:
{
	FileSelectFile, SelectedFile1, 3, , 打开升级文件, Text Documents (*.xml; *.uot)
	if (SelectedFile1 = ""){
	    ;MsgBox, 用户没有选择任何文件！
	} else {
		SplitPath, SelectedFile1 , filename1, dir1 
		RegExMatch(SelectedFile1, "[0-9]+(\.[0-9]+){3}", sVersion1)

		WinGet, k_ID, ID, 前置条件 
		WinSet, AlwaysOnTop, Off, ahk_id %k_ID%
		GuiControl, , SelectedFile1, %SelectedFile1%
		GuiControl, , FileSelector1, %sVersion1%
	}
}
Return


; 选择文件
; 按钮绑定事件
SelectUpdateFile2:
{
	FileSelectFile, SelectedFile2, 3, , 打开升级文件, Text Documents (*.xml; *.uot)
	if (SelectedFile2 = ""){
	    ;MsgBox, 用户没有选择任何文件！
	} else {
		SplitPath, SelectedFile2 , filename2, dir2 
		RegExMatch(SelectedFile2, "[0-9]+(\.[0-9]+){3}", sVersion2)

		WinGet, k_ID, ID, 前置条件 
		WinSet, AlwaysOnTop, Off, ahk_id %k_ID%
		GuiControl, , SelectedFile2, %SelectedFile2%
		GuiControl, , FileSelector2, %sVersion2%
	}
}
Return

; 倒计时组件，使用 setTimer 启动
TicTac:
	m := CountDownTime // 60
	s := Mod(CountDownTime, 60)

	displayedTime := "正在升级中，剩余时间 " Format2Digits(m) ":" Format2Digits(s) " "

	setGUI(displayedTime, 0)

	if (CountDownTime = 0)
	{
	goto stopTicTac_Timer
	}

	; 倒计时减一
	CountDownTime := CountDownTime - 1
Return


; 关闭倒计时组件
stopTicTac_Timer:
	SetTimer, TicTac, Off
Return
