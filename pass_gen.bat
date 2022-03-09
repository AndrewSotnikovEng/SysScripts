@echo off & setlocal EnableDelayedExpansion
chcp 1257

set passAmount=10
set passLength=14

set "alpha=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-+1234567890&"
set alphaCnt=67

For /L %%j in (1,1,%passAmount%) DO CALL :GEN %%j

pause
Goto :Eof
:GEN
Set "Password="
For /L %%j in (1,1,%passLength%) DO (
    Set /a i=!random! %% alphaCnt
    Call Set PASSWORD=!PASSWORD!%%alpha:~!i!,1%%
)
echo  [%1] :  %PASSWORD%