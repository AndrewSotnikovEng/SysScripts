$global:folderPath

Function Get-Folder($initialDirectory="")

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return $folder
}




Function Resize-Image {
    <#
    .SYNOPSIS
        Resize-Image resizes an image file.
 
    .DESCRIPTION
        This function uses the native .NET API to resize an image file and save it to a file.
        It supports the following image formats: BMP, GIF, JPEG, PNG, TIFF
 
    .PARAMETER InputFile
        Type [string]
        The parameter InputFile is used to define the value of image name or path to resize.
 
    .PARAMETER OutputFile
        Type [string]
        The parameter OutputFile is used to define the value of output image resize.
 
    .PARAMETER Width
        Type [int32]
        The parameter Width is used to define the value of new width to image.
 
    .PARAMETER Height
        Type [int32]
        The parameter Height is used to define the value of new height to image.
 
    .PARAMETER ProportionalResize
        Type [bool]
        The optional parameter ProportionalResize is used to define if execute proportional resize.
 
    .EXAMPLE
        Resize-Image -InputFile "C:/image.png" -OutputFile "C:/image2.png" -Width 300 -Height 300
 
    .NOTES
        Author: Ronildo Souza
        Last Edit: 2018-10-09
        Version 1.0.0 - initial release
        Version 1.0.1 - add proportional resize
    #>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$InputFile,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFile,
        [Parameter(Mandatory = $true)]
        [int32]$Width,
        [Parameter(Mandatory = $true)]
        [int32]$Height,
        [Parameter(Mandatory = $false)]
        [bool]$ProportionalResize = $true)

    # Add assemblies
    Add-Type -AssemblyName System
    Add-Type -AssemblyName System.Drawing

    $image = [System.Drawing.Image]::FromFile((Get-Item $InputFile))

    $ratioX = $Width / $image.Width;
    $ratioY = $Height / $image.Height;
    $ratio = [System.Math]::Min($ratioX, $ratioY);

    [int32]$newWidth = If ($ProportionalResize) { $image.Width * $ratio } Else { $Width }
    [int32]$newHeight = If ($ProportionalResize) { $image.Height * $ratio } Else { $Height }

    $destImage = New-Object System.Drawing.Bitmap($newWidth, $newHeight)

    # Draw new image on the empty canvas
    $graphics = [System.Drawing.Graphics]::FromImage($destImage)
    $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
    $graphics.Dispose()

    # Save the image
    $destImage.Save($OutputFile)
}

Function Show-ContentList() 
{
    $items = Get-ChildItem $global:folderPath
    foreach ($i in $items)
    {
       $widthValue = [int] $widthTextBox.Text
       $heightValue = [int] $heightTextBox.Text
       $prefixValue = $prefixTextBox."Text"
       $outputFileValue = "${global:folderPath}\${prefixValue}${i}"
       #correctly works through IDE, only for debug porposes
       #[System.Windows.MessageBox]::Show("$outputFileValue")
       Resize-Image -InputFile "$global:folderPath\$i" -OutputFile $outputFileValue -Width $widthValue -Height $heightValue
    }
}





Add-Type -assembly System.Windows.Forms

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Rename pictures'

$main_form.Width = 560

$main_form.Height = 300
$main_form.StartPosition = "CenterScreen"


#broswe button
$browseButton = New-Object System.Windows.Forms.Button
$browseButton.Location = New-Object System.Drawing.Point (20,20)
$browseButton.Text = "Select"
$browseButton.Size = New-Object System.Drawing.Size(120,25)
$browseButton.Add_Click(
{ $global:folderPath =  Get-Folder }
)
$main_form.Controls.Add($browseButton);



#show buttons
$showButton = New-Object System.Windows.Forms.Button
$showButton.Location = New-Object System.Drawing.Point (400,20)
$showButton.Text = "Transform"
$showButton.Size = New-Object System.Drawing.Size(120,25)
$showButton.Add_Click(
    { Show-ContentList }
)
$main_form.Controls.Add($showButton);



#width label
$widthLabel = New-Object System.Windows.Forms.Label
$widthLabel.Location = New-Object System.Drawing.Point (20,60)
$widthLabel.Text = "Ширина"
$widthLabel.Size = New-Object System.Drawing.Size(60,25)
$main_form.Controls.Add($widthLabel);

#height label
$heightLabel = New-Object System.Windows.Forms.Label
$heightLabel.Location = New-Object System.Drawing.Point (100,60)
$heightLabel.Text = "Высота"
$heightLabel.Size = New-Object System.Drawing.Size(60,25)
$main_form.Controls.Add($heightLabel);





#width textBox
$widthTextBox = New-Object System.Windows.Forms.TextBox
$widthTextBox.Location = New-Object System.Drawing.Point (20,85)
$widthTextBox.Text = "640"
$widthTextBox.Size = New-Object System.Drawing.Size(60,25)
$main_form.Controls.Add($widthTextBox);

#height textBox
$heightTextBox = New-Object System.Windows.Forms.TextBox
$heightTextBox.Location = New-Object System.Drawing.Point (100,85)
$heightTextBox.Text = "480"
$heightTextBox.Size = New-Object System.Drawing.Size(60,25)
$main_form.Controls.Add($heightTextBox);


#prefix label
$prefixLabel = New-Object System.Windows.Forms.Label
$prefixLabel.Location = New-Object System.Drawing.Point (20,120)
$prefixLabel.Text = "Префикс"
$prefixLabel.Size = New-Object System.Drawing.Size(140,25)
$main_form.Controls.Add($prefixLabel);


#prefix textBox
$prefixTextBox = New-Object System.Windows.Forms.TextBox
$prefixTextBox.Location = New-Object System.Drawing.Point (20,145)
$prefixTextBox.Text = "modified_"
$prefixTextBox.Size = New-Object System.Drawing.Size(140,25)
$main_form.Controls.Add($prefixTextBox);


$main_form.ShowDialog()





