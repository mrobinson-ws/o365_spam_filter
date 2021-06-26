#Include GUI Elements in Script
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()

    # Create Main Form
    #Set Properties Of Main Form
    $MainForm = New-Object System.Windows.Forms.Form
    $MainForm.MaximizeBox = $false
    $MainForm.MinimizeBox = $false
    $MainForm.TopMost = $true
    $MainForm.Autosize = $true
    $MainForm.StartPosition = 'CenterScreen'
    $MainForm.Text = "Please select options"
    $MainForm.Controls.AddRange(@($AddRemoveGroupBox,$BlackWhiteGroupBox))
    
    # Create Group 2 For Radio Buttons
    $BlackWhiteGroupBox = New-Object System.Windows.Forms.GroupBox
    $BlackWhiteGroupBox.Dock = [System.Windows.Forms.DockStyle]::Top
    $BlackWhiteGroupBox.Text = "Select Whitelist/Blacklist"
    $BlackWhiteGroupBox.Controls.AddRange(@($WhiteRadioButton,$BlackRadioButton))

    # Create The Radio Buttons
    $BlackRadioButton = New-Object System.Windows.Forms.RadioButton
    $BlackRadioButton.Autosize = $true
    $BlackRadioButton.Dock = [System.Windows.Forms.DockStyle]::Left
    $BlackRadioButton.Checked = $true
    $BlackRadioButton.Text = "Blacklist"
    
    $WhiteRadioButton = New-Object System.Windows.Forms.RadioButton
    $WhiteRadioButton.Autosize = $true
    $WhiteRadioButton.Dock = [System.Windows.Forms.DockStyle]::Right
    $WhiteRadioButton.Checked = $false
    $WhiteRadioButton.Text = "Whitelist"

    # Create Group 1 For Radio Buttons
    $AddRemoveGroupBox = New-Object System.Windows.Forms.GroupBox
    $AddRemoveGroupBox.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $AddRemoveGroupBox.Text = "Select Add/Remove"
    $AddRemoveGroupBox.Controls.AddRange(@($AddRadioButton,$RemoveRadioButton))
    
    # Create The Radio Buttons
    $AddRadioButton = New-Object System.Windows.Forms.RadioButton
    $AddRadioButton.Autosize = $true
    $AddRadioButton.Dock = [System.Windows.Forms.DockStyle]::Left
    $AddRadioButton.Checked = $true
    $AddRadioButton.Text = "Add"
    
    $RemoveRadioButton = New-Object System.Windows.Forms.RadioButton
    $RemoveRadioButton.Autosize = $true
    $RemoveRadioButton.Dock = [System.Windows.Forms.DockStyle]::Right
    $RemoveRadioButton.Checked = $false
    $RemoveRadioButton.Text = "Remove"
    
    #Add An OK Button
    $OKButton = new-object System.Windows.Forms.Button
    $OKButton.AutoSize = $true
    $OKButton.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $OKButton.Text = "OK"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $OKButton.Enabled = $true
    $MainForm.Controls.Add($OKButton)

    $MainFormResult = $MainForm.ShowDialog()
    $MainFormResult
    
    