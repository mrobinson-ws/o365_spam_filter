#Requires -Module ExchangeOnlineManagement
Add-Type -AssemblyName PresentationFramework

### Start XAML and Reader to use WPF
[xml]$xaml = @"
<Window

  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"

  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

  Title="Please Select Options" ResizeMode="NoResize" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen" Width="525" Height="350">

    <Grid Name="MainForm">
        <TabControl HorizontalAlignment="Left" Height="299" Margin="10,10,0,0" VerticalAlignment="Top" Width="497">
            <TabItem Header="Add">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Please Enter The Email or Domain to be Added" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" RenderTransformOrigin="-1.323,-0.347" Width="471"/>
                    <TextBox Name="AddTextBox" HorizontalAlignment="Left" Height="23" Margin="10,41,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="471"/>
                    <Button Name="AddBlacklistButton" Content="Blacklist" HorizontalAlignment="Left" Margin="10,161,0,0" VerticalAlignment="Top" Width="235" Height="100"/>
                    <Button Name="AddWhitelistButton" Content="Whitelist" HorizontalAlignment="Left" Margin="246,161,0,0" VerticalAlignment="Top" Width="235" Height="100"/>
                    <TextBlock Name="AddTextBlock" HorizontalAlignment="Left" Margin="10,69,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="87" Width="471"/>
                </Grid>
            </TabItem>
            <TabItem Header="Remove">
                <Grid Background="#FFE5E5E5">
                    <Button Name="RemoveBlacklistSenderButton" Content="Remove Blacklisted Sender" HorizontalAlignment="Left" Margin="10,211,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <Button Name="RemoveWhitelistSenderButton" Content="Remove Whitelisted Sender" HorizontalAlignment="Left" Margin="246,211,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <Label Content="Please Select Option Below, A New Window Will Pop Out To Select" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Height="30" Width="471"/>
                    <Button Name="RemoveBlacklistDomainButton" Content="Remove Blacklisted Domain" HorizontalAlignment="Left" Margin="10,159,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <Button Name="RemoveWhitelistDomainButton" Content="Remove Whitelisted Domain" HorizontalAlignment="Left" Margin="246,159,0,0" VerticalAlignment="Top" Width="235" Height="50"/>
                    <TextBlock Name="RemoveTextBlock" HorizontalAlignment="Left" Margin="10,45,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Height="109" Width="471"/>
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

#Create Variables For Use In Script
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {Set-Variable -Name ($_.Name) -Value $O365Form.FindName($_.Name)}
### End XAML and Reader


#Test And Connect To Microsoft Exchange Online If Needed
try {
    Write-Verbose -Message "Testing connection to Microsoft Exchange Online"
    Get-Mailbox -ErrorAction Stop | Out-Null
    Write-Verbose -Message "Already connected to Microsoft Exchange Online"
}
catch {
    Write-Verbose -Message "Connecting to Microsoft Exchange Online"
    Connect-ExchangeOnline
}

$AddBlacklistButton.Add_Click({
    $AddTextBlock.Text = "You clicked the Add Blacklist Button"
})

$AddWhitelistButton.Add_Click({
    $AddTextBlock.Text = "You clicked the Add Whitelist Button"
})

$RemoveBlacklistSenderButton.Add_Click({
    Clear-Variable rfbl -ErrorAction SilentlyContinue
    Clear-Variable rfbls -ErrorAction SilentlyContinue
    Clear-Variable RemoveTextBlock.Text -ErrorAction SilentlyContinue
    $rfbls = Get-HostedContentFilterPolicy Default
    $rfbls = $rfbls.BlockedSenders | Select-Object -Property Sender | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
    foreach($rfbl in $rfbls){
        Set-HostedContentFilterPolicy Default -BlockedSenders @{Remove="$($rfbl.sender)"}
        $RemoveTextBlock.AppendText("Removed $($rfbl.Sender) from Blacklist`n`r")
    }
    
})

$RemoveWhitelistSenderButton.Add_Click({
    Clear-Variable rfwl -ErrorAction SilentlyContinue
    Clear-Variable rfwls -ErrorAction SilentlyContinue
    Clear-Variable RemoveTextBlock.Text -ErrorAction SilentlyContinue
    $rfwls = Get-HostedContentFilterPolicy Default
    $rfwls = $rfwls.AllowedSenders | Select-Object -Property Sender | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
    foreach($rfwl in $rfwls){
        Set-HostedContentFilterPolicy Default -AllowedSenders @{Remove="$($rfwl.sender)"}
        $RemoveTextBlock.AppendText("Removed $($rfwl.Sender) from Whitelist`n`r")
    }
})

$RemoveBlacklistDomainButton.Add_Click({
    Clear-Variable rdfbl -ErrorAction SilentlyContinue
    Clear-Variable rdfbls -ErrorAction SilentlyContinue
    Clear-Variable RemoveTextBlock.Text -ErrorAction SilentlyContinue
    $rdfbls = Get-HostedContentFilterPolicy Default
    $rdfbls = $rdfbls.BlockedSenderDomains | Select-Object -Property Domain | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
    foreach($rdfbl in $rdfbls){
        Set-HostedContentFilterPolicy Default -BlockedSenderDomains @{Remove="$($rdfbl.Domain)"}
        $RemoveTextBlock.AppendText("Removed $($rdfbl.Domain) from Whitelist`n`r")
    }
})

$RemoveWhitelistDomainButton.Add_Click({
    Clear-Variable rdfwl -ErrorAction SilentlyContinue
    Clear-Variable rdfwls -ErrorAction SilentlyContinue
    Clear-Variable RemoveTextBlock.Text -ErrorAction SilentlyContinue
    $rdfwls = Get-HostedContentFilterPolicy Default
    $rdfwls = $rdfwls.AllowedSenderDomains | Select-Object -Property Domain | Out-GridView -Passthru -Title "Select Multiple Senders By Holding Ctrl"
    foreach($rdwfl in $rdfwls){
        Set-HostedContentFilterPolicy Default -AllowedSenderDomains @{Remove="$($rdwfl.Domain)"}
        $RemoveTextBlock.AppendText("Removed $($rdwfl.Domain) from Whitelist`n`r")
    }
})

$null = $O365Form.ShowDialog()

