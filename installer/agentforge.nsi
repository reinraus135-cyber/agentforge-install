; AgentForge Windows Installer
; Compiles to AgentForge-Setup.exe via: makensis agentforge.nsi
;
; User experience: double-click .exe -> Welcome -> License Key -> Install -> API Key -> Finish
; Handles WSL2, Ubuntu, Node.js, Claude Code, and AgentForge license activation.
;
; Gated model: the clone below is only the public bootstrap CLI. Your tier's content
; (skills/agents/rules/templates) is downloaded by `ecc activate <key>` after the
; license validates server-side. No license key -> a working CLI, no content yet.

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "LogicLib.nsh"
!include "WinMessages.nsh"
!include "FileFunc.nsh"

; ---------------------------------------------------------------
; Metadata
; ---------------------------------------------------------------
Name "AgentForge"
OutFile "AgentForge-Setup.exe"
InstallDir "$APPDATA\AgentForge"
RequestExecutionLevel admin
BrandingText "AgentForge -- Your AI team. Ready in 60 seconds."
Unicode True

VIProductVersion "2.1.0.0"
VIAddVersionKey "ProductName" "AgentForge"
VIAddVersionKey "CompanyName" "AgentForge"
VIAddVersionKey "FileDescription" "AgentForge Installer"
VIAddVersionKey "FileVersion" "2.1.0"
VIAddVersionKey "LegalCopyright" "AgentForge 2026"

; ListView messages for the install-log dump (Unicode control -> use the W variant).
; Guard against redefinition -- some NSIS headers already define these.
!ifndef LVM_GETITEMCOUNT
  !define LVM_GETITEMCOUNT 0x1004
!endif
!ifndef LVM_GETITEMTEXTW
  !define LVM_GETITEMTEXTW 0x1073
!endif

; ---------------------------------------------------------------
; Variables
; ---------------------------------------------------------------
Var ApiKeyText
Var ApiKeyHwnd
Var LicenseKey
Var LicenseHwnd
Var SkipActivate
Var NeedsReboot
Var SkipWSLSetup
Var StepNum
Var WslOutput
Var ExitCode
Var LogStamp        ; timestamp shared by the Desktop bundle + the WSL ecc log
Var LogBundle       ; full path to the Desktop log bundle
Var FailHandled     ; "1" once a failure dialog + log dump has been shown

; ---------------------------------------------------------------
; MUI Settings
; ---------------------------------------------------------------
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
!define MUI_ABORTWARNING
!define MUI_WELCOMEPAGE_TITLE "Welcome to AgentForge"
!define MUI_WELCOMEPAGE_TEXT "AgentForge sets up a complete Claude Code environment and downloads the AI team for your license tier -- skills, agents, and rules -- ready to use in minutes.$\r$\n$\r$\nThis installer will set up everything you need:$\r$\n$\r$\n  * Windows Subsystem for Linux (WSL2)$\r$\n  * Ubuntu 22.04$\r$\n  * Node.js and developer tools$\r$\n  * Claude Code (AI assistant)$\r$\n  * Your AgentForge tier (Starter, Builder, or Pro)$\r$\n$\r$\nHave your license key ready. Click Next to continue."
!define MUI_FINISHPAGE_TITLE "AgentForge is ready!"
!define MUI_FINISHPAGE_TEXT "Your AgentForge environment is installed.$\r$\n$\r$\nTo start:$\r$\n  1. Open $\"Ubuntu 22.04$\" from your Start menu$\r$\n  2. Type: claude$\r$\n$\r$\nManage your install:$\r$\n  ecc status  -- license tier + what's installed$\r$\n  ecc list    -- browse skills$\r$\n  ecc doctor  -- health check$\r$\n$\r$\nDidn't activate yet? In Ubuntu run:$\r$\n  ecc activate <your-license-key>$\r$\n$\r$\nA setup log was saved to your Desktop (AgentForge-install-log-*.txt). Send it to support if you hit any issue."
!define MUI_FINISHPAGE_NOAUTOCLOSE
; Optional: surface the log folder (off by default -- support convenience only).
!define MUI_FINISHPAGE_RUN "$WINDIR\explorer.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Open the folder containing my setup log"
!define MUI_FINISHPAGE_RUN_PARAMETERS "$DESKTOP"
!define MUI_FINISHPAGE_RUN_NOTCHECKED

; ---------------------------------------------------------------
; Pages
;   Welcome -> License Key (activation needs it) -> Install -> API Key -> Finish
; ---------------------------------------------------------------
!insertmacro MUI_PAGE_WELCOME
Page custom LicensePageCreate LicensePageLeave
!insertmacro MUI_PAGE_INSTFILES
Page custom ApiKeyPageCreate ApiKeyPageLeave
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

; ---------------------------------------------------------------
; Macros
; ---------------------------------------------------------------
!macro StepMsg msg
    IntOp $StepNum $StepNum + 1
    DetailPrint "[$StepNum/12] ${msg}"
!macroend

!macro WslExec user cmd
    ${If} "${user}" == "root"
        nsExec::ExecToLog 'wsl.exe -d Ubuntu-22.04 -u root -- bash -c "${cmd}"'
    ${Else}
        nsExec::ExecToLog 'wsl.exe -d Ubuntu-22.04 -u agentforge -- bash -c "${cmd}"'
    ${EndIf}
    Pop $ExitCode
!macroend

!macro WslCheck cmd
    nsExec::ExecToStack 'wsl.exe -d Ubuntu-22.04 -u agentforge -- bash -c "${cmd}"'
    Pop $ExitCode
    Pop $WslOutput
!macroend

; Build the Desktop log bundle, show a friendly dialog pointing at it, then abort.
; Used for every hard failure so a test machine can hand back ONE file.
!macro FailWithLog failmsg
    Call BuildLogBundle
    StrCpy $FailHandled "1"
    MessageBox MB_OK|MB_ICONSTOP "${failmsg}$\r$\n$\r$\nA setup log was saved to:$\r$\n$LogBundle$\r$\n$\r$\nSend us that file and we'll help. You can also retry by running this installer again."
    Abort
!macroend

!macro WslMustPass user cmd failmsg
    !insertmacro WslExec "${user}" "${cmd}"
    ${If} $ExitCode != 0
        !insertmacro FailWithLog "${failmsg}"
    ${EndIf}
!macroend

; ---------------------------------------------------------------
; Init
; ---------------------------------------------------------------
Function .onInit
    StrCpy $NeedsReboot "false"
    StrCpy $SkipWSLSetup "false"
    StrCpy $SkipActivate "false"
    StrCpy $FailHandled "0"
    StrCpy $StepNum 0

    ; Timestamp used for both the Desktop bundle and the WSL-side ecc log.
    ${GetTime} "" "L" $1 $2 $3 $4 $5 $6 $7
    StrCpy $LogStamp "$3$2$1-$5$6$7"
    StrCpy $LogBundle "$DESKTOP\AgentForge-install-log-$LogStamp.txt"

    IfFileExists "$APPDATA\AgentForge\agentforge-resume.flag" 0 no_resume
        StrCpy $SkipWSLSetup "true"
        Delete "$APPDATA\AgentForge\agentforge-resume.flag"
        DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "AgentForgeResume"
    no_resume:

    ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentBuild"
    ${If} $0 < 19041
        MessageBox MB_OK|MB_ICONSTOP "AgentForge requires Windows 10 version 2004+ (build 19041+).$\r$\n$\r$\nYour build: $0$\r$\nPlease update Windows first."
        Abort
    ${EndIf}
FunctionEnd

; Fired when the install section aborts. Safety net: if a specific failure path
; already built the log + dialog (FailWithLog) or this was an intentional reboot
; exit, stay quiet; otherwise dump the log and point the user at it.
Function .onInstFailed
    ${If} $FailHandled != "1"
        Call BuildLogBundle
        MessageBox MB_OK|MB_ICONSTOP "Setup did not complete.$\r$\n$\r$\nA log was saved to:$\r$\n$LogBundle$\r$\n$\r$\nSend us that file and we'll help."
    ${EndIf}
FunctionEnd

; ---------------------------------------------------------------
; Logging: dump the install Details view to one Desktop file
; ---------------------------------------------------------------

; Append the entire install-log ListView to the file whose path is on the stack.
; Standard NSIS technique; Unicode-correct (LVM_GETITEMTEXTW + wide string read).
Function DumpLog
    Exch $5
    Push $0
    Push $1
    Push $2
    Push $3
    Push $4
    Push $6

    FindWindow $0 "#32770" "" $HWNDPARENT
    GetDlgItem $0 $0 1016
    StrCmp $0 0 dl_exit
    FileOpen $5 $5 "a"
    StrCmp $5 "" dl_exit
    SendMessage $0 ${LVM_GETITEMCOUNT} 0 0 $6
    System::StrAlloc ${NSIS_MAX_STRLEN}
    Pop $3
    StrCpy $2 0
    System::Call "*(i, i, i, i, i, i, i, i, i) i (0, 0, 0, 0, 0, r3, ${NSIS_MAX_STRLEN}, 0, 0) .r1"
    dl_loop:
        StrCmp $2 $6 dl_done
        System::Call "User32::SendMessageW(i $0, i ${LVM_GETITEMTEXTW}, i $2, i r1)"
        System::Call "*$3(&t${NSIS_MAX_STRLEN} .r4)"
        FileWrite $5 "$4$\r$\n"
        IntOp $2 $2 + 1
        Goto dl_loop
    dl_done:
        FileClose $5
        System::Free $1
        System::Free $3
    dl_exit:
        Pop $6
        Pop $4
        Pop $3
        Pop $2
        Pop $1
        Pop $0
        Pop $5 ; restore $5 and discard the filename/handle the caller pushed (no stack leak)
FunctionEnd

; Write a system header then the full Details dump to $LogBundle on the Desktop.
; Probes (node/distro/kernel) go through ExecToStack so they never pollute the
; Details view we are about to capture. Safe to call on success or failure.
Function BuildLogBundle
    ClearErrors
    ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" "CurrentBuild"

    nsExec::ExecToStack 'wsl.exe -d Ubuntu-22.04 -u agentforge -- bash -c "uname -r 2>/dev/null || echo unknown"'
    Pop $R1
    Pop $R1
    nsExec::ExecToStack 'wsl.exe -d Ubuntu-22.04 -u agentforge -- bash -c "lsb_release -ds 2>/dev/null || (. /etc/os-release 2>/dev/null && echo $$PRETTY_NAME) || echo unknown"'
    Pop $R2
    Pop $R2
    nsExec::ExecToStack 'wsl.exe -d Ubuntu-22.04 -u agentforge -- bash -c "export NVM_DIR=$$HOME/.nvm; [ -s $$NVM_DIR/nvm.sh ] && . $$NVM_DIR/nvm.sh >/dev/null 2>&1; node -v 2>/dev/null || echo n/a"'
    Pop $R3
    Pop $R3

    FileOpen $9 "$LogBundle" "w"
    StrCmp $9 "" blb_done
    FileWrite $9 "===== AgentForge Setup Log =====$\r$\n"
    FileWrite $9 "Generated:     $LogStamp$\r$\n"
    FileWrite $9 "Installer:     AgentForge 2.1.0$\r$\n"
    FileWrite $9 "Windows build: $R0$\r$\n"
    FileWrite $9 "WSL kernel:    $R1$\r$\n"
    FileWrite $9 "Distro:        $R2$\r$\n"
    FileWrite $9 "Node:          $R3$\r$\n"
    FileWrite $9 "ecc log:       inside Ubuntu at ~/.ecc/logs/install-$LogStamp.log$\r$\n"
    FileWrite $9 "(License keys, API keys, and other secrets are intentionally excluded from this log.)$\r$\n"
    FileWrite $9 "================================$\r$\n$\r$\n"
    FileClose $9

    Push "$LogBundle"
    Call DumpLog
    blb_done:
FunctionEnd

; ---------------------------------------------------------------
; License Key page (NEW) -- activation needs the key before install
; ---------------------------------------------------------------
Function LicensePageCreate
    !insertmacro MUI_HEADER_TEXT "Activate AgentForge" "Enter the license key from your purchase."

    nsDialogs::Create 1018
    Pop $0

    ${NSD_CreateLabel} 0 0 100% 32u "Paste the license key from your AgentForge purchase email. Your tier (Starter, Builder, or Pro) is detected automatically and its content is downloaded during install."
    Pop $0

    ${NSD_CreateLabel} 0 40u 100% 12u "License key:"
    Pop $0

    ${NSD_CreateText} 0 54u 100% 14u "$LicenseKey"
    Pop $LicenseHwnd

    ${NSD_CreateLabel} 0 76u 100% 32u "No key yet? Get one at https://agentforge.army/pricing -- or continue now and activate later in Ubuntu with:  ecc activate <your-license-key>"
    Pop $0

    nsDialogs::Show
FunctionEnd

Function LicensePageLeave
    ${NSD_GetText} $LicenseHwnd $LicenseKey

    ${If} $LicenseKey == ""
        MessageBox MB_YESNO|MB_ICONQUESTION "No license key entered.$\r$\n$\r$\nAgentForge needs a license to download your tier's skills and agents. You can continue now and activate later in Ubuntu by running:$\r$\n$\r$\n  ecc activate <your-license-key>$\r$\n$\r$\nContinue without activating?" IDYES lic_skip
        Abort ; stay on the page
        lic_skip:
        StrCpy $SkipActivate "true"
    ${Else}
        StrLen $0 $LicenseKey
        ${If} $0 < 10
            MessageBox MB_OK|MB_ICONEXCLAMATION "That license key looks too short.$\r$\n$\r$\nPlease paste the full key from your purchase email."
            Abort ; stay on the page
        ${EndIf}
        StrCpy $SkipActivate "false"
    ${EndIf}
FunctionEnd

; ---------------------------------------------------------------
; API Key page (after install -- claude needs it, activation does not)
; ---------------------------------------------------------------
Function ApiKeyPageCreate
    !insertmacro WslCheck "test -f ~/.secrets/anthropic_api_key -a -s ~/.secrets/anthropic_api_key && echo yes || echo no"
    StrCmp $WslOutput "yes$\r$\n" 0 +2
        Abort ; key exists, skip page

    !insertmacro MUI_HEADER_TEXT "Anthropic API Key" "Claude Code needs an API key to work."

    nsDialogs::Create 1018
    Pop $0

    ${NSD_CreateLabel} 0 0 100% 24u "Get your key at: https://console.anthropic.com/settings/keys$\r$\n(Using a Claude subscription instead? Leave this blank -- the first 'claude' run will sign you in.)"
    Pop $0

    ${NSD_CreateLabel} 0 32u 100% 12u "Paste your API key below (or leave blank to set up later):"
    Pop $0

    ${NSD_CreateText} 0 50u 100% 14u ""
    Pop $ApiKeyHwnd
    SendMessage $ApiKeyHwnd ${EM_SETPASSWORDCHAR} 42 0

    nsDialogs::Show
FunctionEnd

Function ApiKeyPageLeave
    ${NSD_GetText} $ApiKeyHwnd $ApiKeyText

    ${If} $ApiKeyText != ""
        StrCpy $0 $ApiKeyText 7
        ${If} $0 != "sk-ant-"
            MessageBox MB_YESNO|MB_ICONQUESTION "This doesn't look like an Anthropic API key (expected sk-ant-...). Save anyway?" IDYES save_it
            Abort
            save_it:
        ${EndIf}

        ; SECURITY: pass the key via the Windows env + WSLENV so the LOGGED command
        ; shows only "$AF_APIKEY" (the variable name), never the key value. printf
        ; emits nothing to stdout, so the secret never reaches the Details view.
        System::Call 'kernel32::SetEnvironmentVariable(t "AF_APIKEY", t "$ApiKeyText")i.r0'
        System::Call 'kernel32::SetEnvironmentVariable(t "WSLENV", t "AF_APIKEY")i.r0'
        !insertmacro WslExec "" "mkdir -p ~/.secrets && chmod 700 ~/.secrets && printf '%s\n' $$AF_APIKEY > ~/.secrets/anthropic_api_key && chmod 600 ~/.secrets/anthropic_api_key"
        ; The .bashrc export references the file, not the key -- safe to log.
        !insertmacro WslExec "" "grep -qF ANTHROPIC_API_KEY ~/.bashrc 2>/dev/null || printf '\n# AgentForge -- Anthropic API key\nexport ANTHROPIC_API_KEY=$$(cat ~/.secrets/anthropic_api_key 2>/dev/null)\n' >> ~/.bashrc"
        System::Call 'kernel32::SetEnvironmentVariable(t "AF_APIKEY", i 0)i.r0'
    ${EndIf}
FunctionEnd

; ---------------------------------------------------------------
; Main install
; ---------------------------------------------------------------
Section "Install" SecInstall
    SetOutPath $INSTDIR
    SetAutoClose false

    ; ===========================================================
    ; PHASE 1: Windows (WSL2 + Ubuntu)
    ; ===========================================================
    ${If} $SkipWSLSetup == "false"

        ; 1. WSL feature
        !insertmacro StepMsg "Enabling Windows Subsystem for Linux..."
        nsExec::ExecToLog 'dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart'
        Pop $ExitCode
        ${If} $ExitCode == 3010
            StrCpy $NeedsReboot "true"
        ${ElseIf} $ExitCode != 0
            !insertmacro FailWithLog "Could not enable WSL. Your IT policy may be blocking this."
        ${EndIf}

        ; 2. Virtual Machine Platform
        !insertmacro StepMsg "Enabling Virtual Machine Platform..."
        nsExec::ExecToLog 'dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart'
        Pop $ExitCode
        ${If} $ExitCode == 3010
            StrCpy $NeedsReboot "true"
        ${ElseIf} $ExitCode != 0
            !insertmacro FailWithLog "Could not enable Virtual Machine Platform. Your IT policy may be blocking this."
        ${EndIf}

        ; Reboot if needed
        ${If} $NeedsReboot == "true"
            DetailPrint "WSL2 features enabled. Reboot required."
            CreateDirectory "$APPDATA\AgentForge"
            FileOpen $0 "$APPDATA\AgentForge\agentforge-resume.flag" w
            FileWrite $0 "post-reboot"
            FileClose $0
            WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "AgentForgeResume" '"$EXEPATH"'
            MessageBox MB_YESNO|MB_ICONQUESTION "Windows needs to restart to finish enabling WSL2.$\r$\n$\r$\nSetup will resume automatically after reboot.$\r$\n$\r$\nRestart now?" IDYES do_reboot
            ; User declined the required reboot -- intentional exit, not a failure.
            StrCpy $FailHandled "1"
            Abort
            do_reboot:
            Reboot
        ${EndIf}

        ; 3. WSL2 default
        !insertmacro StepMsg "Setting WSL2 as default..."
        nsExec::ExecToLog 'wsl.exe --set-default-version 2'
        Pop $ExitCode

        ; 4. Ubuntu 22.04
        !insertmacro StepMsg "Installing Ubuntu 22.04 (this may take a few minutes)..."
        ; Use raw nsExec here -- agentforge user doesn't exist yet
        nsExec::ExecToStack 'wsl.exe -d Ubuntu-22.04 -- bash -c "echo ok"'
        Pop $ExitCode
        Pop $WslOutput
        ${If} $ExitCode != 0
            nsExec::ExecToLog 'wsl.exe --install -d Ubuntu-22.04 --no-launch'
            Pop $ExitCode
            ${If} $ExitCode != 0
                nsExec::ExecToLog 'wsl.exe --install -d Ubuntu-22.04'
                Pop $ExitCode
            ${EndIf}
        ${EndIf}
        DetailPrint "Ubuntu 22.04 ready"

        ; 5. User
        !insertmacro StepMsg "Creating user account..."
        !insertmacro WslExec "root" "id -u agentforge 2>/dev/null || (useradd -m -s /bin/bash -G sudo agentforge && passwd -l agentforge)"
        ; Passwordless sudo for agentforge
        !insertmacro WslExec "root" "echo 'agentforge ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/agentforge && chmod 440 /etc/sudoers.d/agentforge"
        ; Set agentforge as default WSL user so steps 7+ run under correct account
        !insertmacro WslExec "root" "printf '[user]\ndefault=agentforge\n' > /etc/wsl.conf"
        nsExec::ExecToLog 'wsl.exe --shutdown'
        Pop $ExitCode
        Sleep 3000
        DetailPrint "User 'agentforge' ready (set as default)"

    ${Else}
        StrCpy $StepNum 5
        DetailPrint "Resuming after reboot..."
    ${EndIf}

    ; ===========================================================
    ; PHASE 2: Linux setup (all from this Windows GUI)
    ; ===========================================================

    ; 6. System packages
    !insertmacro StepMsg "Installing Linux packages..."
    !insertmacro WslMustPass "root" "export DEBIAN_FRONTEND=noninteractive && apt-get update -qq && apt-get install -y -qq git curl jq build-essential" "Could not install system packages."

    ; 7. nvm
    !insertmacro StepMsg "Installing Node Version Manager..."
    !insertmacro WslCheck "test -d ~/.nvm && echo yes || echo no"
    StrCmp $WslOutput "yes$\r$\n" nvm_done 0
        !insertmacro WslMustPass "" "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | PROFILE=/dev/null bash" "Could not install nvm."
    nvm_done:
    ; Ensure nvm is sourced in interactive shells
    !insertmacro WslExec "" "grep -qF NVM_DIR $$HOME/.bashrc 2>/dev/null || printf '%s\n' '' '# nvm' 'export NVM_DIR=\$$HOME/.nvm' '[ -s \$$NVM_DIR/nvm.sh ] && . \$$NVM_DIR/nvm.sh' >> $$HOME/.bashrc"
    DetailPrint "nvm ready"

    ; 8. Node.js
    !insertmacro StepMsg "Installing Node.js 22 LTS..."
    ; Skip if node 22+ already available (via nvm or system)
    !insertmacro WslCheck "export NVM_DIR=$$HOME/.nvm; [ -s $$NVM_DIR/nvm.sh ] && . $$NVM_DIR/nvm.sh >/dev/null 2>&1; node --version 2>/dev/null | grep -qE 'v2[2-9]' && echo yes || echo no"
    StrCmp $WslOutput "yes$\r$\n" node_done 0
        ; Primary: nvm
        DetailPrint "Trying nvm..."
        !insertmacro WslExec "" "export NVM_DIR=$$HOME/.nvm && [ -s $$NVM_DIR/nvm.sh ] && . $$NVM_DIR/nvm.sh && nvm install 22 && nvm alias default 22"
        ${If} $ExitCode != 0
            ; Fallback: NodeSource apt repository
            DetailPrint "nvm failed (exit $ExitCode), trying NodeSource..."
            !insertmacro WslMustPass "root" "curl -fsSL https://deb.nodesource.com/setup_22.x -o /tmp/nodesource.sh && bash /tmp/nodesource.sh && apt-get install -y -qq nodejs && rm -f /tmp/nodesource.sh" "Could not install Node.js. Check your internet connection and re-run."
        ${EndIf}
    node_done:
    DetailPrint "Node.js ready"

    ; 9. Claude Code
    !insertmacro StepMsg "Installing Claude Code..."
    !insertmacro WslCheck "export NVM_DIR=$$HOME/.nvm; [ -s $$NVM_DIR/nvm.sh ] && . $$NVM_DIR/nvm.sh >/dev/null 2>&1; command -v claude >/dev/null 2>&1 && echo yes || echo no"
    StrCmp $WslOutput "yes$\r$\n" claude_done 0
        DetailPrint "Installing Claude Code via npm..."
        ; Try user-level install (works with nvm)
        !insertmacro WslExec "" "export NVM_DIR=$$HOME/.nvm; [ -s $$NVM_DIR/nvm.sh ] && . $$NVM_DIR/nvm.sh >/dev/null 2>&1; npm install -g @anthropic-ai/claude-code"
        ${If} $ExitCode != 0
            ; Fallback: install as root (needed for system node from NodeSource)
            DetailPrint "Retrying as root..."
            !insertmacro WslMustPass "root" "npm install -g @anthropic-ai/claude-code" "Could not install Claude Code."
        ${EndIf}
    claude_done:
    DetailPrint "Claude Code ready"

    ; 10. AgentForge (gated model: clone the PUBLIC bootstrap CLI, not the private content repo)
    !insertmacro StepMsg "Downloading AgentForge..."
    !insertmacro WslCheck "test -d ~/AgentForge/.git && echo yes || echo no"
    StrCmp $WslOutput "yes$\r$\n" repo_done 0
        !insertmacro WslMustPass "" "GIT_TERMINAL_PROMPT=0 timeout 120 git clone --depth 1 https://github.com/reinraus135-cyber/agentforge-install.git ~/AgentForge" "Could not download AgentForge. Check your internet."
    repo_done:
    DetailPrint "AgentForge ready"

    ; 11. Activate license -> downloads + installs the entitled tier's content
    !insertmacro StepMsg "Activating your license and installing your tier..."
    !insertmacro WslExec "" "chmod +x ~/AgentForge/ecc"
    !insertmacro WslCheck "test -f ~/.ecc/.install-complete && echo yes || echo no"
    StrCmp $WslOutput "yes$\r$\n" ecc_done 0
        ${If} $SkipActivate == "true"
            DetailPrint "No license key entered -- skipping activation."
            DetailPrint "Activate later in Ubuntu: ~/AgentForge/ecc activate <your-license-key>"
            Goto ecc_done
        ${EndIf}
        DetailPrint "Validating license and downloading your tier (this may take a minute)..."
        ; SECURITY: pass the key via the Windows env + WSLENV so it reaches bash
        ; from the environment. The LOGGED command shows only "$AF_LICENSE" (the
        ; variable name), never the key value. ecc never echoes the key itself.
        System::Call 'kernel32::SetEnvironmentVariable(t "AF_LICENSE", t "$LicenseKey")i.r0'
        System::Call 'kernel32::SetEnvironmentVariable(t "WSLENV", t "AF_LICENSE")i.r0'
        nsExec::ExecToLog 'wsl.exe -d Ubuntu-22.04 -u agentforge -- bash -c "mkdir -p $$HOME/.ecc/logs; export NVM_DIR=$$HOME/.nvm; [ -s $$NVM_DIR/nvm.sh ] && . $$NVM_DIR/nvm.sh >/dev/null 2>&1; ECC_LOG=$$HOME/.ecc/logs/install-$LogStamp.log bash ~/AgentForge/ecc activate $$AF_LICENSE"'
        Pop $ExitCode
        System::Call 'kernel32::SetEnvironmentVariable(t "AF_LICENSE", i 0)i.r0'
        ${If} $ExitCode == 0
            !insertmacro WslExec "" "mkdir -p ~/.ecc && date -Iseconds > ~/.ecc/.install-complete"
            DetailPrint "License activated -- your tier is installed."
        ${Else}
            DetailPrint "Activation did not complete (exit $ExitCode)."
            MessageBox MB_OK|MB_ICONEXCLAMATION "Your environment is installed, but license activation did not complete.$\r$\n$\r$\nCommon causes:$\r$\n  - the key was mistyped$\r$\n  - the key is already active on the maximum number of devices$\r$\n  - no internet connection$\r$\n$\r$\nActivate anytime in Ubuntu with:$\r$\n  ecc activate <your-license-key>$\r$\n$\r$\nDetails are in the setup log on your Desktop."
        ${EndIf}
    ecc_done:
    DetailPrint "AgentForge environment ready"

    ; 12. PATH + doctor
    !insertmacro StepMsg "Running final checks..."
    !insertmacro WslExec "" "grep -qF AgentForge ~/.bashrc 2>/dev/null || printf '\n# AgentForge\nexport PATH=$$HOME/AgentForge:$$PATH\n' >> ~/.bashrc"
    !insertmacro WslExec "" "export NVM_DIR=$$HOME/.nvm; [ -s $$NVM_DIR/nvm.sh ] && . $$NVM_DIR/nvm.sh >/dev/null 2>&1; ECC_LOG=$$HOME/.ecc/logs/install-$LogStamp.log bash ~/AgentForge/ecc doctor"

    DetailPrint ""
    DetailPrint "========================================="
    DetailPrint "  Installation complete!"
    DetailPrint "========================================="

    ; Capture the full run to one Desktop file (everything above streamed to Details).
    Call BuildLogBundle

    ; Add/Remove Programs entry
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AgentForge" "DisplayName" "AgentForge"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AgentForge" "Publisher" "AgentForge"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AgentForge" "DisplayVersion" "2.1.0"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AgentForge" "UninstallString" '"$INSTDIR\uninstall.exe"'
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AgentForge" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AgentForge" "NoRepair" 1
    WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

Section "Uninstall"
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "AgentForgeResume"
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\AgentForge"
    Delete "$APPDATA\AgentForge\agentforge-resume.flag"
    Delete "$INSTDIR\uninstall.exe"
    RMDir "$INSTDIR"
SectionEnd
