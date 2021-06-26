Add-Type -AssemblyName PresentationFramework
[xml]$xaml = @"
<Window

  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"

  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  
  Title="Please Select Options" ResizeMode="NoResize" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterScreen" Width="300" Height="200">

    <Grid Width="300" Height="150">

        <GroupBox Header="Blacklist/Whitelist?" HorizontalAlignment="Left" Height="60" Margin="10,10,0,0" VerticalAlignment="Top" Width="280">

            <Grid Margin="10,10,380,6">

                <RadioButton x:Name="BlackRadioButton" Content="Blacklist" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="0,0,-90,0"/>
                <RadioButton x:Name="WhiteRadioButton" Content="Whitelist" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,-180,0"/>

            </Grid>

        </GroupBox>
        <GroupBox Header="Add/Remove?" HorizontalAlignment="Left" Height="60" Margin="10,70,0,0" VerticalAlignment="Top" Width="280">

            <Grid Margin="10,10,380,6">

                <RadioButton x:Name="AddRadioButton" Content="Add" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="0,0,-90,0"/>
                <RadioButton x:Name="RemoveRadioButton" Content="Remove" HorizontalAlignment="Right" VerticalAlignment="Top" Margin="0,0,-180,0"/>

            </Grid>

        </GroupBox>
        <Button x:Name="OKButton" Content="GO" HorizontalAlignment="Left" Height="20" Margin="10,130,0,0" VerticalAlignment="Top" Width="280"/>

    </Grid>

</Window>
"@
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$window.ShowDialog()

