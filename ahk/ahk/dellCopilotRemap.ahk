#UseHook

global copilotHeld := false

; Block Copilot itself so Windows doesn't launch Copilot.
F23::return
F23 up::return

; Track physical hold state (hook hotkeys still fire)
*F23::
{
    global copilotHeld
    copilotHeld := true
}

*F23 up::
{
    global copilotHeld
    copilotHeld := false
}

; While Copilot is held: swallow the firmware chord completely
#HotIf copilotHeld
*LWin::return
*RWin::return
*LShift::return
*RShift::return

; And re-emit what you actually want
*1::SendEvent "#1"
*2::SendEvent "#2"
*3::SendEvent "#3"
*4::SendEvent "#4"
*5::SendEvent "#5"
*6::SendEvent "#6"
*7::SendEvent "#7"
*8::SendEvent "#8"
*9::SendEvent "#9"
*0::SendEvent "#0"
#HotIf

; --- Safety: auto-unstick if we miss the key-up (sleep/lock/focus glitches) ---
SetTimer CopilotWatchdog, 100

CopilotWatchdog() {
    global copilotHeld
    if (copilotHeld && !GetKeyState("F23", "P")) {
        copilotHeld := false
        SendEvent "{LWin up}{RWin up}{LShift up}{RShift up}"
    }
}

; Panic reset
^!#Backspace::
{
    global copilotHeld
    copilotHeld := false
    SendEvent "{LWin up}{RWin up}{LShift up}{RShift up}"
}
