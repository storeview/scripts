#SingleInstance,Force       ;ensure only 1 version running
SetTitleMatchMode, 2        ;to make sure Get the ffmpeg window
DetectHiddenWindows,On      ;Added becauase minimizing the window

;Detected all mouse button and keyboard [Activities]
class AllKeyBinder{
    __New(callback, pfx := "~*"){
        static mouseButtons := ["LButton", "RButton", "MButton", "XButton1", "XButton2"]
        keys := {}
        ;callback is a function which will execute when a key/mouse activity detected
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

;when key/mouse active, the function will execute
MyFunc(code, name, state){
	;Tooltip % "Key Code: " code ", Name: " name ", State: " state
	global pc_active
	
	if (pc_active = 0){
        pc_active := 1
        startRecording()
	}
}

;--------Basic Setting-----------------
k_FontSize = 20		; Font size
k_FontName = Verdana  	; Font name
k_FontStyle = Bold   	; Font syle
TransColor = F1ECED	; Background color
i = 1			; change color flag
x = 1744		; gui x offset
y = 800			; gui y offset


;crete GUI
Gui, Font, s%k_FontSize% %k_FontStyle%, %k_FontName%
Gui, -Caption +ToolWindow
Gui, Color, %TransColor%
Gui Add, Button, Default w60 vtime, Op
Gui, Show
WinGet, k_ID, ID, A
; move GUI
WinMove, A,, x, y
WinSet, AlwaysOnTop, On, ahk_id %k_ID%
WinSet, TransColor, %TransColor% 220, ahk_id %k_ID%



;START Key Mouse Listening...
kb := new AllKeyBinder(Func("MyFunc"))
OnExit("exitProgram")


;----------> Global Variable <----------
pc_active := 0
online_count := 0
offline_count := 0
ffmpeg_is_recording := 0
ffmpegPid := 0
File_Name := filename
Tooltip 1

;--------------------> Set Timer  <--------------------
;SetTimer, SET_pc_active_AS_0, 30000                             ;[Important]set a timmer, auto set the variable pc_active as 0,  Two Times Per Minute
;SetTimer, CHECK_pc_active, % (on:=!on) ? (300000) : ("off")     ;check pc is online

SetTimer, SET_pc_active_AS_0, 8000             ;[Important]set a timmer, auto set the variable pc_active as 0,  Two Times Per Minute
SetTimer, CHECK_ffmpeg_online, 1000
SetTimer, CHECK_pc_active, % (on:=!on) ? (3000) : ("off")



;Main Progress END.
Return



;----------> Labels <----------
SET_pc_active_AS_0:
    pc_active := 0    ;it means the pc is not active
Return

CHECK_pc_active:
    if (pc_active = 1){
        online_count++
        offline_count := 0
;        Tooltip Online! %online_count% 
        if (online_count = 12){
            stopRecording()
            Sleep, 3000
            startRecording()
        }
        if (ffmpeg_is_recording = 1) {
            GuiControl, , time, On
        }
    } 
    if (pc_active = 0){
        offline_count++
        online_count := 0
;        Tooltip Offline!!! %offline_count%
        if (offline_count = 6){
            stopRecording()
        }
        if (ffmpeg_is_recording = 1) {
            GuiControl, , time, Off
        }
    }
Return

CHECK_ffmpeg_online:
                Tooltip, %ffmpegPid%
    if (ffmpegPid = 0){
        if(ffmpeg_is_recording = 0){
            GuiControl, , time, Op
        }
    } else {
        f_pid := WinExist(ahk_id  ffmpegPid)
        if (f_pid = "0x0") {
            GuiControl, , time, Op
        }
    }
Return





;FileDelete, %A_ScriptDir%\output.mkv
;sleep, 50
;ff_params = -f gdigrab -i desktop -r 30 -b:v 700k output.mkv
;run ffmpeg %ff_params%,,Hide, ffmpegPid ;run ffmpeg with command parameters
 
;Return


;^+s::
;ControlSend, , ^c, ahk_pid  %ffmpegPid% 
;Return



startRecording(){
    global ffmpeg_is_recording
    global ffmpegPid
    global File_Name
    Sleep, 1000
    if (ffmpeg_is_recording = 0){
        FormatTime, File_Name, , yyyy-MM-dd-HH-mm-ss
        ff_params = -rtbufsize 100M -f gdigrab -i desktop -r 30 -b:v 700k %File_Name%.mkv
        run ffmpeg %ff_params%,,hide, _ffmpegPid
        
        ffmpegPid := _ffmpegPid
        Tooltip 2
        
;        Tooltip %ffmpegPid% - %_ffmpegPid%
        ffmpeg_is_recording := 1
    }

}


stopRecording(){
    global ffmpeg_is_recording
    global ffmpegPid
;    MsgBox, %File_Name%
;    Tooltip %ffmpegPid% 2222
    ControlSend,, ^c, ahk_pid %ffmpegPid%
    
    Sleep, 2000
    FileMove, %A_ScriptDir%\*.mkv, %A_ScriptDir%\Records\
    
    ffmpegPid := 0
    Tooltip 3
    ffmpeg_is_recording := 0
}


exitProgram(){
    Sleep, 50
    stopRecording()
}













