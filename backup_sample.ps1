######################################################
###   THIS SCRIPT READ INI FILE AND MAKING BACKUP  ###
###   MODIFY INPUT FILE IF NEEDED                  ###
###                                                ###
###   THE CRUCIAL VALUES IS:                       ###
###     -NAME                                      ###
###     -SOURCE                                    ###
###     -DESTINATION                               ###
###                                                ###
###   SECTION NAME NO MATTERS                      ###
###                                                ###
######################################################

######################################################
################   INTPUT DATA   #####################
######################################################
$iniConfigPath = "input.ini"
######################################################
function Get-IniFile 
{  
    param(  
        [parameter(Mandatory = $true)] [string] $filePath  
    )  
    
    $anonymous = "NoSection"
  
    $ini = @{}  
    switch -regex -file $filePath  
    {  
        "^\[(.+)\]$" # Section  
        {  
            $section = $matches[1]  
            $ini[$section] = @{}  
            $CommentCount = 0  
        }  

        "^(;.*)$" # Comment  
        {  
            if (!($section))  
            {  
                $section = $anonymous  
                $ini[$section] = @{}  
            }  
            $value = $matches[1]  
            $CommentCount = $CommentCount + 1  
            $name = "Comment" + $CommentCount  
            $ini[$section][$name] = $value  
        }   

        "(.+?)\s*=\s*(.*)" # Key  
        {  
            if (!($section))  
            {  
                $section = $anonymous  
                $ini[$section] = @{}  
            }  
            $name,$value = $matches[1..2]  
            $ini[$section][$name] = $value  
        }  
    }  

    return $ini  
}  

$ini = Get-IniFile $iniConfigPath

$curDateTime = Get-Date -Format "ddMMyyyy_HHmm"
foreach ($i in $ini.Keys) {
    If (![string]::IsNullOrEmpty($ini.$i.Name)) {
        $name = $ini.$i.Name
        $src = $ini.$i.Source
        $dest = $ini.$i.Destination
		
		Compress-Archive -Path $src -CompressionLevel Fastest -DestinationPath "$($dest)\$($name)_$($curDateTime).zip"
    }
}
