REM Kills app if it running
@set process="HxOutlook.exe"
echo "Listning for Mail application..."
@:loop

@timeout /t 1 > NUL
@tasklist | find /i %process% && taskkill /im %process% /F

@goto loop