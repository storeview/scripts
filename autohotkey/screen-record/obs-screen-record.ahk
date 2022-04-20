#SingleInstance,Force 

class AllKeyBinder{
    __New(callback, pfx := "~*"){
        static mouseButtons := ["LButton", "RButton", "MButton", "XButton1", "XButton2"]
        keys := {}
        this.Callback := callback
        Loop 512 {
            i := A_Index
            code := Format("{:x}", i)
            n := GetKeyName("sc" code)
            if (!n || keys.HasKey(n))
                continue
            keys[n] := code
            
            fn := this.KeyEvent.Bind(this, "Key", i, n, 1)
            hotkey, % pfx "SC" code, % fn, On
            
            fn := this.KeyEvent.Bind(this, "Key", i, n, 0)
            hotkey, % pfx "SC" code " up", % fn, On             
        }
        
        for i, k in mouseButtons {
            fn := this.KeyEvent.Bind(this, "Mouse", i, n, 1)
            hotkey, % pfx k, % fn, On
            
            fn := this.KeyEvent.Bind(this, "Mouse", i, n, 0)
            hotkey, % pfx k " up", % fn, On             
        }
    }
    
    ;bind key event
    KeyEvent(type, code, name, state){
        this.Callback.Call(type, code, name, state)
    }
}


MyFunc(code, name, state){
	;Tooltip % "Key Code: " code ", Name: " name ", State: " state
	global pc_active
    global pc_active
	
    ; 如果正在录屏的话，有按键操作，就直接把 pc_active 变成 1
	if (obs_is_recording = 1){
        pc_active := 1
	} else {
        ; 如果没有在录屏的话，则将 pc_active 置为 1，并启动录屏
        if(pc_active = 0){
            pc_active := 1
            startRecording()
        }
    }
}





;--------------------> basic setting  <--------------------
k_FontSize = 20		
k_FontName = Verdana  	
k_FontStyle = Bold   	
TransColor = F1ECED	
i = 1			
x = 1744		
y = 800			
Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%
Gui, -Caption +ToolWindow
Gui, Color, %TransColor%
Gui Add, Button, Default w60 vtime, Opp
Gui, Show
WinGet, k_ID, ID, A
WinMove, A,, x, y
WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %TransColor% 220, ahk_id %k_ID%
;--------------------





;--------------------> start programe  <--------------------
kb := new AllKeyBinder(Func("MyFunc"))
OnExit("exitProgram")
;--------------------





;--------------------> global variable  <--------------------
pc_active := 0
online_count := 0
offline_count := 0
obs_is_recording := 0
_obsProgramPid := 0
obsProgrameHwnd := 0
;--------------------





;--------------------> timer  <--------------------
SetTimer, SET_pc_active_AS_0, 300000   
SetTimer, CHECK_obs_online, 30000

;设置pc不活动的线程5分钟设置一次，间隔3分钟后，设置检查pc活动与否的线程
; 这样两个线程Timer之间，就有固定的间隔时间，让用户操作，使 pc_active 变为 1
Sleep, 180000

SetTimer, CHECK_pc_active, % (on:=!on) ? (300000) : ("off")

;SetTimer, SET_pc_active_AS_0, 8000   
;SetTimer, CHECK_obs_online, 1000
;SetTimer, CHECK_pc_active, % (on:=!on) ? (3000) : ("off")

SET_pc_active_AS_0:
    pc_active := 0    ;it means the pc is not active
Return

CHECK_pc_active:
    if (obs_is_recording = 0) {
    } else {
        ; 不管当前电脑是否有人在用，都需要对录像进行计时
        online_count++
        if (pc_active = 1){
            GuiControl, , time, O%online_count%
           ; 如果 24 次都是在线，说明程序已经运行了两个小时，是时候结束了
            if (online_count >= 24){
                stopRecording()
                Sleep, 1000
                startRecording()
                online_count := 0
            }
            ; 重新计时
            offline_count := 0
        } else {
            offline_count++
            GuiControl, , time, F%offline_count%
            if (offline_count >= 6){
                stopRecording()
                offline_count := 0
                online_count := 0
            }
        }
    }

Return

CHECK_obs_online:
;    Tooltip, %obs_is_recording%
    if(obs_is_recording = 0){
            GuiControl, , time, Opp
    } else {
;        if (obsProgrameHwnd != 0){
;            f_id := WinExist(ahk_id  obsProgrameHwnd)
;            Tooltip, %f_id%
;            if (f_id = "0x0") {
;        }
;        }
    }
Return
;--------------------





;--------------------> functions  <--------------------
startRecording(){
    global obs_is_recording
    global _obsProgramPid
    global obsProgrameHwnd
    global time
    
    if (obs_is_recording = 0){


        ; 如果当前没有启动录像程序，则启动录像程序
        if (_obsProgramPid = 0){
            Run obs64.exe,%A_ScriptDir%\obs\bin\64bit\, ,_obsProgramPid
            WinWait, ahk_pid %_obsProgramPid%,,5
            WinGet, obsProgrameHwnd, ID, ahk_pid %_obsProgramPid%
        } else {
            toShow()
        }
        
        Sleep, 1000
        SetKeyDelay, -1, 50
        ControlSend,, ^!y, ahk_pid %_obsProgramPid%
        
        
        Sleep, 1000
        
        toHide()

        GuiControl, , time, On


        obs_is_recording := 1
    }

}


stopRecording(){
    global obs_is_recording
    global _obsProgramPid
    global time
    
    toShow()

    SetKeyDelay, -1, 50
    ControlSend,, ^!u, ahk_pid %_obsProgramPid%
    
    toHide()



    obs_is_recording := 0
}


shutdownObsEXE(){
    global _obsProgramPid
    Process, close, %_obsProgramPid%
    Process, WaitClose, %_obsProgramPid%
}




;隐藏录屏软件的窗口
toHide(){
    global obsProgrameHwnd
    Result := DllCall("ShowWindow", "UInt", obsProgrameHwnd, "Int", "0")
}


;显示录屏软件的窗口
toShow(){
    global obsProgrameHwnd
    Result := DllCall("ShowWindow", "UInt", obsProgrameHwnd, "Int", "1")
    WinWait, ahk_id %obsProgrameHwnd%,,5
}


;退出程序
exitProgram(){
    Sleep, 50
    stopRecording()
    Sleep, 1000
    shutdownObsEXE()
}





