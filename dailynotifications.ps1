$CBSRebootKey = Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -ErrorAction Ignore
$WURebootKey = Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -ErrorAction Ignore
$FileRebootKey = Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -ErrorAction Ignore
if (($null -ne $CBSRebootKey) -OR ($null -ne $WURebootKey) -OR ($null -ne $FileRebootKey)) {
            $LauncherID = "{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe"
 
        #Load Assemblies
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null
         
        #Build XML Template
        [xml]$ToastTemplate = 
        @"
        <toast scenario="$Scenario">
            <visual>
            <binding template="ToastGeneric">
                <image placement="hero" src="$HeroImage"/>
                <image id="1" placement="appLogoOverride" hint-crop="circle" src="$LogoImage"/>
                <text placement="attribution">$AttributionText</text>
                <text>IT kindly reminds you...</text>
                <group>
                    <subgroup>
                        <text hint-style="title" hint-wrap="true" >Your computer needs to restart!</text>
                    </subgroup>
                </group>
                <group>
                    <subgroup>     
                        <text hint-style="body" hint-wrap="true" >For security and stability reasons, we kindly ask you to restart your computer as soon as possible</text>
                    </subgroup>
                </group>
                <group>
                    <subgroup>     
                        <text hint-style="body" hint-wrap="true" >Make sure power is connected to the computer</text>
                    </subgroup>
                </group>
                <group>
                    <subgroup>     
                        <text hint-style="body" hint-wrap="true" >Restarting your computer on a regular basis ensures a secure and stable Windows. Thank you in advance.</text>
                    </subgroup>
                </group>
            </binding>
            </visual>
            <actions>
                <action activationType="protocol" arguments="ToastReboot:" content="Restart Computer" />
                <action activationType="system" arguments="dismiss" content="Dismiss"/>
            </actions>
        </toast>
"@
        #Prepare XML
        $ToastXml = [Windows.Data.Xml.Dom.XmlDocument]::New()
        $ToastXml.LoadXml($ToastTemplate.OuterXml)
         
        #Prepare and Create Toast
        $ToastMessage = [Windows.UI.Notifications.ToastNotification]::New($ToastXML)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($LauncherID).Show($ToastMessage)
        
        #Show-Notification -ToastTitle "Computer Restart Required" -ToastText "Please make sure computer is connected to power and restart computer" 
}