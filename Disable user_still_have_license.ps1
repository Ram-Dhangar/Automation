function Get_licenseOf_DisableUser()
{
#Install-Module msOnline
 

Connect-MsolService 

#Get-MsolUser -All | Where-Object {$_.isLicensed -eq $true -and $_.BlockCredential -eq $true} | Select UserPrincipalName,DisplayName,isLicensed

$disabledUsers = Get-ADUser -filter 'enabled -eq $false'  -Properties *
foreach ($user in $disabledUsers) {
    Get-MsolUser -UserPrincipalName $user.UserPrincipalName | Where-Object {$_.isLicensed -eq $true} | Select UserPrincipalName,DisplayName,isLicensed,Licenses | Export-Csv -Path 'D:\disable_have_license.csv'
}


$smtpserver = "smtp server mail"
$emailFrom="service desk mail"
$emailTo = "reciver email"
$subject = "Disable user still have o365 licenses assigned"

$body = "Hi Admin , <BR><BR> This is to inform you that $user.UserPrincipalName have still license assigned. <B></B>.  Thanks <br><br><hr><br>It is a system generated mail, please do not reply on this mail."
Send-MailMessage -To $emailTo -From $emailFrom  -Subject $subject -BodyAsHtml -Body $body -SmtpServer $smtpserver

}

Get_licenseOf_DisableUser







#[Net.ServicePointManager]::SecurityProtocol
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12


