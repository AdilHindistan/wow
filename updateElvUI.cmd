REM ******************************************
REM Author: Adil Hindistan | @AdilHindistan
REM Import WoW functions and Update ELVUI
REM This file should be in the same folder as Wow.ps1 and can be used to update-elvui
REM ******************************************

REM Following will update ElvUI but will not backup addons
powershell -command "& {. .\Wow.ps1 ; Update-ElvUI }"

REM Remove the following 'REM ' to both backup current addons and then update ElvUI
REM powershell -command "& {. .\Wow.ps1 ; Backup-WowAddons ; Update-ElvUI }"

REM Pausing so that output can be examined
pause