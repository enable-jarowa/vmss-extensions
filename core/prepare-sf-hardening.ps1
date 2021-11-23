Write-Output "------------------------------------------"
Write-Output "Custom script: prepare-sf-hardening.ps1"
Write-Output "------------------------------------------"
Write-Output "$($args.Count) received"
Write-Output "------------------------------------------"
$f_url = $args[0]
$f_folder = $args[1]
$f_drive = $args[2]
$f_account = $args[3]
$f_key= $args[4]
$f_features="$($args[5])"
Write-Output "Features=$($f_features)"
$f_featurearray = $f_features.ToLower().Split(",").Trim().Where({ $_ -ne "" });

if ($True -or ($f_featurearray.Contains("hardening"))) {

    # Description:
    #   Microsoft Windows Explorer AutoPlay Not Disabled
    # Impact:
    #   Exploiting this vulnerability can cause malicious applications to be executed
    #   unintentionally at escalated privilege.
    # Threat:
    #   The setting that prevents applications from any drive to be automatically executed is not enabled on the host.
    # Remediation: Disable autoplay from any disk type by setting the value NoDriveTypeAutoRun to 255 under
    #   this registry key:
    #   HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
    # TODO

    # Description:
    #      SMB Signing Disabled or SMB Signing Not Required
    # Impact:
    #     Unauthorized users sniffing the network could catch many challenge/response exchanges and replay the
    #     whole thing to grab particular session keys, and then authenticate on the Domain Controller.
    # Threat:
    #     This host does not seem to be using SMB (Server Message Block) signing. SMB signing is a security
    #     mechanism in the SMB protocol and is also known as security signatures. SMB signing is designed to help
    #     improve the security of the SMB protocol.
    #     SMB signing adds security to a network using NetBIOS, avoiding man-in-the-middle attacks.
    #     When SMB signing is enabled on both the client and server SMB sessions are authenticated between the machines
    #     on a packet by packet basis.
    #     QID Detection Logic:
    #     This checks from the registry value of RequireSecuritySignature and EnableSecuritySignature form
    #     HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\LanmanWorkStation\Parameters for client and
    #     HKEY_LOCAL_MACHINE\System\CurrentControlSetServices\LanmanServer\Parameters for servers to check if SMB signing is required or enabled or disabled.
    #     Note: On 5/28/2020 the QID was updated to check for client SMB signing behavior via the registry key HKEY_LOCAL_MACHINE\SystemCurrent\ControlSetServices\LanmanWorkStation\Parameters. The complete detection logic is explained above.
    #     Remediation:
    #     Without SMB signing, a device could intercept SMB network packets from an originating computer, alter their contents, and broadcast them to the destination computer. Since, digitally signing the packets enables the recipient of the packets to confirm their point of origination and their authenticity, it is recommended that SMB signing is enabled and required.
    #     Please refer to Microsoft's article http://support.microsoft.com/kb/887429 and The Basics of SMB Signing https://docs.microsoft.com/archive/blogs/josebda/the-basics-of-smb-signing-covering-both-smb1-and-smb2?WT.mc_id=Portal-Microsoft_Azure_Security (covering both SMB1 and SMB2) for information on enabling SMB signing.
    #     For Windows Server 2008 R2, Windows Server 2012, please refer to Microsoft's article Require SMB Security Signatures http://technet.microsoft.com/en-us/library/cc731957.aspx for information on enabling SMB signing. For group policies please refer to Microsoft's article Modify Security Policies in Default Domain Controllers Policy http://technet.microsoft.com/en-us/library/cc731654
    #
    # For UNIX systems:
    #     To require samba clients running "smbclient" to use packet signing, add the following to the "[global]" section of the Samba configuration file:
    #     client signing = mandatory
    # TODO

    # Description:
    #   Enabled Cached Logon Credential
    # Impact:
    #   Unauthorized users can gain access to this cached information, thereby obtaining sensitive logon information.
    # Threat: Windows NT may use a cache to store the last interactive logon (i.e. console logon), to provide a safe
    #   logon for the host in the event that the Domain Controller goes down. This feature is currently activated
    #   on this host.
    # Remediation: We recommend that you locate the following Registry key, and then set or create a REG_SZ
    #   'CachedLogonsCount' entry with a '0' value:
    #   HKEY_LOCAL_MACHINE\Software\Microsoft\Windows Nt\CurrentVersion\Winlogon
    # TODO

    # Description:
    #     Allowed Null Session
    # Impact:
    #     Unauthorized users can establish a null session and obtain sensitive information, such as usernames and/or the share list, which could be used in further attacks against the host.
    # Threat
    #     It is possible to log into the target host using a NULL session.
    #     Windows NT has a feature allowing anonymous users to obtain domain user names and the share list. Windows NT ACL editor requires the Domain Controllers to return a list of account names.
    #     We check for "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\LSA RestrictAnonymous" as well as "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters RestrictNullSessAccess" = 0 as Microsoft has stated that "Remote access to the registry may still be possible after you follow the steps in this article if the RestrictNullSessAccess registry value has been created and is set to 0. This value allows remote access to the registry by using a null session. The value overrides other explicit restrictive settings."
    # Remediation:
    #     To disable or restrict null session, please refer to Microsoft Knowledge Base Article For restricting-information-available-to-anonymous-logon-users or Microsoft TechNet : RestrictNullSessAccess for further details.
    # TODO

}

Write-Output "------------------------------------------"
Write-Output "prepare-sf-hardening.ps1"
Write-Output "------------------------------------------"
$True
