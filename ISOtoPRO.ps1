#ISOtoPro by zoic
#this script will remove all versions except for pro from a windows 10/11 iso file

If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
  Start-Process PowerShell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
  Exit	
}

function install-adk {

  $testP = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\x86\Oscdimg\oscdimg.exe'  

  if (!(Test-Path -path $testP)) {
    Write-Host 'Installing Windows ADK'
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri 'https://go.microsoft.com/fwlink/?linkid=2196127' -UseBasicParsing -OutFile "$PSScriptRoot\adksetup.exe"
    &"$PSScriptRoot\adksetup.exe" /quiet /features OptionId.DeploymentTools | Wait-Process 
    Remove-Item -Path "$PSScriptRoot\adksetup.exe" -Force

  }

  #check if adk installed
  if (Test-Path -path $testP) {
    Write-Host 'ADK Installed'
    return $true
  }
  else {
    return $false
  }

}
if (!(install-adk)) {
  Write-Host 'ADK Not Found'
  $null = Read-Host 'Press Enter to EXIT...'
  exit
}
else {
  $oscdimg = 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\x86\Oscdimg\oscdimg.exe'

}

function remove-Editions([String]$folderPath) {
  $tempDir = $folderPath

  $version = dism /Get-WimInfo /WimFile:"${tempDir}\sources\install.wim"

  if ($version -match 'Windows 10') {

    $editionsToRemove = @('Windows 10 Home',
      'Windows 10 Home N',
      'Windows 10 Home Single Language',
      'Windows 10 Education',
      'Windows 10 Education N',
      'Windows 10 Pro N',
      'Windows 10 Pro Education',
      'Windows 10 Pro Education N',
      'Windows 10 Pro for Workstations',
      'Windows 10 Pro N for Workstations')

  }
  elseif ($version -match 'Windows 11') {

    $editionsToRemove = @('Windows 11 Home',
      'Windows 11 Home N',
      'Windows 11 Home Single Language',
      'Windows 11 Education',
      'Windows 11 Education N',
      'Windows 11 Pro N',
      'Windows 11 Pro Education',
      'Windows 11 Pro Education N',
      'Windows 11 Pro for Workstations',
      'Windows 11 Pro N for Workstations')

  }
  else {
    Write-Host 'Version not Supported!'
    pause
    return
  }

  foreach ($edition in $editionsToRemove) {
    Write-Host "Removing $edition..."
    Remove-WindowsImage -ImagePath "$tempDir\sources\install.wim" -Name $edition -CheckIntegrity -ErrorAction SilentlyContinue | Out-Null

  }



}


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Windows 10 & 11 Edition Remover'
$form.Size = New-Object System.Drawing.Size(500, 200)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$form.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

# Create controls for choosing ISO file
$isoLabel = New-Object System.Windows.Forms.Label
$isoLabel.Location = New-Object System.Drawing.Point(10, 20)
$isoLabel.Size = New-Object System.Drawing.Size(120, 20)
$isoLabel.Text = 'Choose ISO File:'
$isoLabel.ForeColor = 'White'
$form.Controls.Add($isoLabel)

$isoTextBox = New-Object System.Windows.Forms.TextBox
$isoTextBox.Location = New-Object System.Drawing.Point(130, 20)
$isoTextBox.Size = New-Object System.Drawing.Size(200, 20)
$isoTextBox.Text = $null
$form.Controls.Add($isoTextBox)

$isoBrowseButton = New-Object System.Windows.Forms.Button
$isoBrowseButton.Location = New-Object System.Drawing.Point(340, 20)
$isoBrowseButton.Size = New-Object System.Drawing.Size(40, 20)
$isoBrowseButton.Text = '...'
$isoBrowseButton.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$isoBrowseButton.ForeColor = [System.Drawing.Color]::White
$isoBrowseButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$isoBrowseButton.FlatAppearance.BorderSize = 0
$isoBrowseButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(62, 62, 64)
$isoBrowseButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(27, 27, 28)
$isoBrowseButton.Add_Click({
    $fileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $fileDialog.Filter = 'ISO Files (*.iso)|*.iso|All Files (*.*)|*.*'
    
    if ($fileDialog.ShowDialog() -eq 'OK') {
      $selectedFile = $fileDialog.FileName
      $isoTextBox.Text = $selectedFile
    }
  })
$form.Controls.Add($isoBrowseButton)

# Create controls for choosing destination directory
$destLabel = New-Object System.Windows.Forms.Label
$destLabel.Location = New-Object System.Drawing.Point(10, 60)
$destLabel.Size = New-Object System.Drawing.Size(120, 25)
$destLabel.Text = 'Choose Destination Directory:'
$destLabel.ForeColor = 'White'
$form.Controls.Add($destLabel)

$destTextBox = New-Object System.Windows.Forms.TextBox
$destTextBox.Location = New-Object System.Drawing.Point(130, 60)
$destTextBox.Size = New-Object System.Drawing.Size(200, 20)
$destTextBox.Text = $null
$form.Controls.Add($destTextBox)

$destBrowseButton = New-Object System.Windows.Forms.Button
$destBrowseButton.Location = New-Object System.Drawing.Point(340, 60)
$destBrowseButton.Size = New-Object System.Drawing.Size(40, 20)
$destBrowseButton.Text = '...'
$destBrowseButton.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$destBrowseButton.ForeColor = [System.Drawing.Color]::White
$destBrowseButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$destBrowseButton.FlatAppearance.BorderSize = 0
$destBrowseButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(62, 62, 64)
$destBrowseButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(27, 27, 28)
$destBrowseButton.Add_Click({
    $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    
    if ($folderDialog.ShowDialog() -eq 'OK') {
      $selectedFolder = $folderDialog.SelectedPath
      $destTextBox.Text = $selectedFolder
    }
  })
$form.Controls.Add($destBrowseButton)


# Create "Remove Editions" button
$removeButton = New-Object System.Windows.Forms.Button
$removeButton.Location = New-Object System.Drawing.Point(130, 100)
$removeButton.Size = New-Object System.Drawing.Size(120, 30)
$removeButton.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$removeButton.ForeColor = [System.Drawing.Color]::White
$removeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$removeButton.FlatAppearance.BorderSize = 0
$removeButton.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(62, 62, 64)
$removeButton.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(27, 27, 28)
$removeButton.Text = 'Remove Editions'
$removeButton.Add_Click({
 
 

    if ($isoTextBox.Text -eq '' -or $destTextBox.Text -eq '') {
      Write-Host 'Please Select an ISO file and Destination folder'

    }
    else {
      $selectedFile = $isoTextBox.Text
      $selectedFolder = $destTextBox.Text 
      # clear any mount points
      [Void](Clear-WindowsCorruptMountPoint)
      Write-Host 'Mounting ISO...'
      # Mount the ISO
      try {
        $mountResult = (Mount-DiskImage -ImagePath $selectedFile -StorageType ISO -PassThru -ErrorAction Stop | Get-Volume).DriveLetter + ':\'

      }
      catch {
        Write-Host 'Unable to Mount ISO...'
        Write-Error $Error[0]
        $form.Dispose()
        $null = Read-Host 'Press Enter to EXIT...'
        exit
      }

      # Create a temporary directory to copy the ISO contents
      $tempDir = "$selectedFolder\TEMP"
      New-Item -ItemType Directory -Force -Path $tempDir 

      Write-Host 'Moving files to TEMP directory...'
      # Copy the ISO contents to the temporary directory
      Copy-Item -Path "$mountResult*" -Destination $tempDir -Recurse -Force

      # Dismount the ISO
      Dismount-DiskImage -ImagePath $selectedFile


      # Get all files in the folder and its subfolders
      $files = Get-ChildItem -Path $tempDir -Recurse -File -Force

      # Loop through each file
      foreach ($file in $files) {
        # Remove the read-only attribute
        $file.Attributes = 'Normal'
      }

      # Get all directories in the folder and its subfolders
      $directories = Get-ChildItem -Path $tempDir -Recurse -Directory -Force

      # Loop through each directory
      foreach ($directory in $directories) {
        # Remove the read-only attribute
        $directory.Attributes = 'Directory'
      }


      remove-Editions -folderPath $tempDir

      Write-Host 'Compressing ISO File'
      Export-WindowsImage -SourceImagePath "$tempDir\sources\install.wim" -SourceIndex 1 -DestinationImagePath "$tempDir\sources\install2.wim" -CompressionType 'max'
      #dism /Export-Image /SourceImageFile:"$tempDir\sources\install.wim" /SourceIndex:$index /DestinationImageFile:"$mountDir\sources\install2.wim" /compress:max
      Remove-Item "$tempDir\sources\install.wim"
      Rename-Item "$tempDir\sources\install2.wim" -NewName 'install.wim' -Force

      Write-Host 'Creating ISO File in Destination Directory'
      $title = [System.IO.Path]::GetFileNameWithoutExtension($selectedFile) 
      $path = "$selectedFolder\$title(PRO).iso"
      Start-Process -FilePath $oscdimg -ArgumentList "-m -o -u2 -udfver102 -bootdata:2#p0,e,b$tempDir\boot\etfsboot.com#pEF,e,b$tempDir\efi\microsoft\boot\efisys.bin $tempDir `"$path`"" -NoNewWindow -Wait  


      # Delete the temporary directory
      Get-ChildItem -Path $tempDir -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
      Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

      Write-Host 'DONE!'
    }

  })
$form.Controls.Add($removeButton)

# Show the form
$form.ShowDialog()



    












