Add-Type -AssemblyName PresentationFramework

if(-not(Get-Module ExchangeOnlineManagement -ListAvailable)){
    $null = [System.Windows.MessageBox]::Show('Please Install ExchangeOnlineManagement - view ITG for details https://worksmart.itglue.com/2503920/docs/7777752')
    Exit
}

### Start XAML and Reader to use WPF, as well as declare variables for use
[xml]$xaml = @"
<Window

  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"

  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

  Title="Please Select Options" ResizeMode="NoResize" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen" Width="525" Height="350">

    <Grid Name="MainForm">
        <TabControl HorizontalAlignment="Left" Height="299" Margin="10,10,0,0" VerticalAlignment="Top" Width="497">
            <TabItem Header="Add">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Please Enter The Email or Domain to be Added" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" RenderTransformOrigin="-1.323,-0.347" Width="257"/>
                    <TextBox Name="AddTextBox" HorizontalAlignment="Left" Height="23" Margin="10,41,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="471"/>
                    <Button Name="AddBlacklistButton" Content="Blacklist" HorizontalAlignment="Left" Margin="10,161,0,0" VerticalAlignment="Top" Width="235" Height="100"/>
                    <Button Name="AddWhiteListButton" Content="Whitelist" HorizontalAlignment="Left" Margin="246,161,0,0" VerticalAlignment="Top" Width="235" Height="100"/>
                    <RichTextBox Name="AddTextBlock" HorizontalAlignment="Left" Height="87" Margin="10,69,0,0" VerticalAlignment="Top" Width="471" Background="#FF646464" Foreground="Cyan">
                        <FlowDocument/>
                    </RichTextBox>
                    <Button Name="ReconnectButton" Content="Change Tenants/Reconnect" HorizontalAlignment="Left" Margin="272,10,0,0" VerticalAlignment="Top" Width="209" Height="26"/>
                </Grid>
            </TabItem>
            <TabItem Header="Remove" Foreground="#FF00C8FF">
                <Grid Background="#FFE5E5E5">
                    <Button Name="RemoveBlacklistSenderButton" Content="Remove Blacklisted Sender" HorizontalAlignment="Left" Margin="10,211,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <Button Name="RemoveWhitelistSenderButton" Content="Remove Whitelisted Sender" HorizontalAlignment="Left" Margin="246,211,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <Label Content="Please Select Option Below, A New Window Will Pop Out To Select" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Height="30" Width="471"/>
                    <Button Name="RemoveBlacklistDomainButton" Content="Remove Blacklisted Domain" HorizontalAlignment="Left" Margin="10,159,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <Button Name="RemoveWhitelistDomainButton" Content="Remove Whitelisted Domain" HorizontalAlignment="Left" Margin="246,159,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <RichTextBox Name="RemoveTextBlock" HorizontalAlignment="Left" Height="109" Margin="10,45,0,0" VerticalAlignment="Top" Width="471" Background="#FF646464" Foreground="Cyan">
                        <FlowDocument/>
                    </RichTextBox>
                </Grid>
            </TabItem>
        </TabControl>
    </Grid>

</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
Try{
    $O365Form = [Windows.Markup.XamlReader]::Load($reader)
}
Catch{
    Write-Host "Unable to load Windows.Markup.XamlReader.  Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."
    Exit
}

#Create Variables For Use In Script Automatically
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $O365Form.FindName($_.Name)}


# Create Functions For Color Changing Messages
Function WriteAddTextBlock {
    Param(
        [string]$text,
        [string]$color = "Cyan"
    )

    $RichTextRange = New-Object System.Windows.Documents.TextRange( 
        $AddTextBlock.Document.ContentEnd,$AddTextBlock.Document.ContentEnd ) 
    $RichTextRange.Text = $text
    $RichTextRange.ApplyPropertyValue( ( [System.Windows.Documents.TextElement]::ForegroundProperty ), $color )  

}

Function WriteRemoveTextBlock {
    Param(
        [string]$text,
        [string]$color = "Cyan"
    )

    $RichTextRange = New-Object System.Windows.Documents.TextRange( 
        $RemoveTextBlock.Document.ContentEnd,$RemoveTextBlock.Document.ContentEnd ) 
    $RichTextRange.Text = $text
    $RichTextRange.ApplyPropertyValue( ( [System.Windows.Documents.TextElement]::ForegroundProperty ), $color )  

}

### End XAML, Reader, and Declarations


#Test And Connect To Microsoft Exchange Online If Needed
try {
    Get-Mailbox -ErrorAction Stop | Out-Null
}
catch {
    Connect-ExchangeOnline
}

$ReconnectButton.Add_Click({
    Connect-ExchangeOnline
})

$AddBlacklistButton.Add_Click({
    if([string]::IsNullOrwhiteSpace($AddTextBox.Text) -eq $false){
        Try{
            Set-HostedContentFilterPolicy Default -BlockedSenderDomains @{Add="$($AddTextbox.Text)"} -ErrorAction Stop
            WriteAddTextBlock("Added $($AddTextbox.Text) to Domain Blacklist`r")
            $AddTextBlock.ScrollToEnd()
        }
        Catch{
            Try{
                Set-HostedContentFilterPolicy Default -BlockedSenders @{Add="$($AddTextbox.Text)"} -ErrorAction Stop
                WriteAddTextBlock("Added $($AddTextbox.Text) to Sender Blacklist`r")
                $AddTextBlock.ScrollToEnd()
            }
            Catch{
                WriteAddTextBlock("$_.Message indicates $($AddTextbox.Text) is potentially invalid, please review entry and try again`r") -Color "Red"
                $AddTextBlock.ScrollToEnd()
            }
        }
    }
    elseif ([string]::IsNullOrwhiteSpace($AddTextbox.Text) -eq $true){
        WriteAddTextBlock("Please enter a domain or sender into the text box.`r") -Color "Red"
    }
})

$AddWhitelistButton.Add_Click({
    if([string]::IsNullOrwhiteSpace($AddTextBox.Text) -eq $false){
        Try{
            Set-HostedContentFilterPolicy Default -AllowedSenderDomains @{Add="$($AddTextbox.Text)"} -ErrorAction Stop
            WriteAddTextBlock("Added $($AddTextbox.Text) to Domain Whitelist`r")
            $AddTextBlock.ScrollToEnd()
        }
        Catch{
            Try{
                Set-HostedContentFilterPolicy Default -AllowedSenders @{Add="$($AddTextbox.Text)"} -ErrorAction Stop
                WriteAddTextBlock("Added $($AddTextbox.Text) to Sender Whitelist`r")
                $AddTextBlock.ScrollToEnd()
            }
            Catch{
                WriteAddTextBlock("$_.Message indicates $($AddTextbox.Text) is potentially invalid, please review entry and try again`r") -Color "Red"
                $AddTextBlock.ScrollToEnd()
            }
        }
    }
    elseif([string]::IsNullOrwhiteSpace($AddTextbox.Text) -eq $true){
        WriteAddTextBlock("Please enter a domain or sender into the text box.`r") -Color "Red"
    }
})

$RemoveBlacklistSenderButton.Add_Click({
    Clear-Variable rfbl -ErrorAction SilentlyContinue
    Clear-Variable rfbls -ErrorAction SilentlyContinue
    Try{
        $rfbls = Get-HostedContentFilterPolicy Default
        $rfbls = $rfbls.BlockedSenders | Select-Object -Property Sender | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
        foreach($rfbl in $rfbls){
            Set-HostedContentFilterPolicy Default -BlockedSenders @{Remove="$($rfbl.sender)"}
            WriteRemoveTextBlock("Removed $($rfbl.Sender) from Sender Blacklist`r")
            $RemoveTextBlock.ScrollToEnd()
        }
    }
    Catch{
        WriteRemoveTextBlock("$_.Message indicates an error has occurred.  Please review message and retry once resolved.")
    }
})

$RemoveWhitelistSenderButton.Add_Click({
    Clear-Variable rfwl -ErrorAction SilentlyContinue
    Clear-Variable rfwls -ErrorAction SilentlyContinue
    Try{
        $rfwls = Get-HostedContentFilterPolicy Default
        $rfwls = $rfwls.AllowedSenders | Select-Object -Property Sender | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
        foreach($rfwl in $rfwls){
            Set-HostedContentFilterPolicy Default -AllowedSenders @{Remove="$($rfwl.sender)"}
            WriteRemoveTextBlock("Removed $($rfwl.Sender) from Sender Whitelist`r")
            $RemoveTextBlock.ScrollToEnd()
        }
    }
    Catch{
        WriteRemoveTextBlock("$_.Message indicates an error has occurred.  Please review message and retry once resolved.")
    }
})

$RemoveBlacklistDomainButton.Add_Click({
    Clear-Variable rdfbl -ErrorAction SilentlyContinue
    Clear-Variable rdfbls -ErrorAction SilentlyContinue
    Try{
        $rdfbls = Get-HostedContentFilterPolicy Default
        $rdfbls = $rdfbls.BlockedSenderDomains | Select-Object -Property Domain | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
        foreach($rdfbl in $rdfbls){
            Set-HostedContentFilterPolicy Default -BlockedSenderDomains @{Remove="$($rdfbl.Domain)"}
            WriteRemoveTextBlock("Removed $($rdfbl.Domain) from Domain Blacklist`r")
            $RemoveTextBlock.ScrollToEnd()
        }
    }
    Catch{
        WriteRemoveTextBlock("$_.Message indicates an error has occurred.  Please review message and retry once resolved.")
    }
})

$RemoveWhitelistDomainButton.Add_Click({
    Clear-Variable rdfwl -ErrorAction SilentlyContinue
    Clear-Variable rdfwls -ErrorAction SilentlyContinue
    Try{
        $rdfwls = Get-HostedContentFilterPolicy Default
        $rdfwls = $rdfwls.AllowedSenderDomains | Select-Object -Property Domain | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
        foreach($rdwfl in $rdfwls){
            Set-HostedContentFilterPolicy Default -AllowedSenderDomains @{Remove="$($rdwfl.Domain)"}
            WriteRemoveTextBlock("Removed $($rdwfl.Domain) from Domain Whitelist`r")
            $RemoveTextBlock.ScrollToEnd()
        }
    }
    Catch{
        WriteRemoveTextBlock("$_.Message indicates an error has occurred.  Please review message and retry once resolved.")
    }
})

$null = $O365Form.ShowDialog()