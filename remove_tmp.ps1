<#
	Removes files inside folder and show fine Win notification
#>

$tmpFilePath = "d:\tmp\to_delete\*"

function ShowNotification {	
	Add-Type -AssemblyName System.Windows.Forms
	$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
	$path = (Get-Process -id $pid).Path
	$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
	$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Info
	$balmsg.BalloonTipText = ‘Temporary folder is cleared'
	$balmsg.BalloonTipTitle = "Sheduled task completed"
	$balmsg.Visible = $true
	$balmsg.ShowBalloonTip(20000)
}

function DoAction {	
	rm $tmpFilePath -r -fo
}

$error.clear()

try { DoAction }
catch { "Error occured" }
if (!$error) { ShowNotification }

