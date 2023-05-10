function ExpirationStatus($dateTime)
{ 
# Get-Credential
$cred = get-Credential
$loginUserName=$cred.UserName


# Get all the accounts in Active Directory 
#adAccounts = Get-ADUser -Filter {(enabled -eq $True) -and (pager -eq "Contractor")} -Properties * | Select SamAccountName,mail,pager,displayName,cn,mobile,telephoneNumber,location,AccountExpirationDate, accountExpires,manager,@{L='Manageremailid';e={$manager=$_.manager;(get-aduser -Identity $manager -Properties mail).mail}},@{Name='ManagerName';Expression={ (($_ |Get-ADUser -Properties manager).manager | Get-ADUser).Name}}
$adAccounts = Get-ADUser -SearchBase 'OU=LTI_Test,DC=bakelite,DC=net' -Filter {(enabled -eq $True) -and (pager -eq "Contractor")} -Properties * | Select SamAccountName,mail,pager,displayName,mobile,telephoneNumber,location,AccountExpirationDate, accountExpires,manager,@{L='Manageremailid';e={$manager=$_.manager;(get-aduser -Identity $manager -Properties mail).mail}},@{Name='ManagerName';Expression={ (($_ |Get-ADUser -Properties manager).manager | Get-ADUser).Name}}
#$adAccounts = Get-ADUser -SearchBase 'OU=LTI_Test,DC=bakelite,DC=net'-Filter 'enabled -eq $true '  -Properties * | Select SamAccountName,mail,pager,givenName,cn,mobile,telephoneNumber,location,AccountExpirationDate, accountExpires,manager,@{L='Manageremailid';e={$manager=$_.manager;(get-aduser -Identity $manager -Properties mail).mail}},@{Name='ManageName';Expression={ (($_ |Get-ADUser -Properties manager).manager | Get-ADUser).Name}} # Create arrays to store the accounts that will expire soon and the accounts that have already expired
$expiringSoon = @() 
# Get the current date
$currentdate = Get-Date # Loop through all the accounts and determine their expiration status
foreach ($account in $adAccounts) {
  # Check if the account has an expiration date
  if ($account.AccountExpirationDate) {
    # Calculate the number of days until the account will expire
    $daysUntilExpiration = ($account.AccountExpirationDate - $currentdate).Days     # Add the expiration status to the account
    if ($daysUntilExpiration -le 0) {
      write-host "Already expired",$account.SamAccountName 
      $account | Add-Member -NotePropertyName "ExpirationStatus" -NotePropertyValue "Account is Already Expired" -Force     }
    elseif ($daysUntilExpiration -le 5) {
      write-host "Expire in 5Days",$account.SamAccountName       
      $account | Add-Member -NotePropertyName "ExpirationStatus" -NotePropertyValue "Account expiring in 5 or lesser days" -Force
      }     elseif ($daysUntilExpiration -le 10) {
      write-host "Expire in 10Days",$account.SamAccountName       
      $account | Add-Member -NotePropertyName "ExpirationStatus" -NotePropertyValue "Account expiring in 10 or lesser days" -Force 
    }
    elseif ($daysUntilExpiration -le 30 -and $daysUntilExpiration -gt 15 ) {
      write-host "Expire in 15-30days",$account.SamAccountName
      $account | Add-Member -NotePropertyName "ExpirationStatus" -NotePropertyValue "Account expiring in 15-30 days" -Force
    }
    elseif ($daysUntilExpiration -gt 30) {
      write-host "Expire in 30days",$account.SamAccountName
        $account | Add-Member -NotePropertyName "ExpirationStatus" -NotePropertyValue "Account expiring in more 30 days" -Force
        }        elseif ($daysUntilExpiration -le 45) {
      write-host "Expire in 45days",$account.SamAccountName
        $account | Add-Member -NotePropertyName "ExpirationStatus" -NotePropertyValue "Account expiring in  30-45 days" -Force
        }
     # Add the account to the expiring soon array
      $expiringSoon += $account
}
else{
     $account | Add-Member -NotePropertyName "accountExpires" -NotePropertyValue "Account does not expire" -Force 
    $expiringSoon += $account
}  
$expiringSoon | Select-Object SamAccountName, ManagerName,Manageremailid,TelephoneNumber, displayName, mobile, location,pager, mail,givenName,sn, ExpirationStatus, AccountExpirationDate | Export-Csv -Path "D:\temp\ExpiringADuser_$dateTime.csv"  -NoTypeInformation  
 }


#calling sendmail function
Sendmail -dateTime $dateTime -loginUserName $loginUserName

}  


function Sendmail($dateTime,$loginUserName)
{
Write-Host "Current User Logged in: $loginUserName"
$data=Import-Csv -Path "\\bmukbukcxvdip02\e$\Scripts\ContractorExpiryAutomationScript\Script_Output\ExpiringADuser_$dateTime.csv"
$Path ="\\bmukbukcxvdip02\e$\Scripts\ContractorExpiryAutomationScript\Script_Output\ExpiringADuser_$dateTime.csv"
$csv = Import-Csv $Path | Select-Object *, @{Name="Action"; Expression={}}, @{Name="Date"; Expression={}},@{Name="DisableStatus"; Expression={}},@{Name="DisableBy"; Expression={}} 

foreach($item in $csv)
{   
$Samaccountname =$item.Samaccountname
$Expiration= $item.AccountExpirationDate
$dateString = $Expiration
$date = Get-Date $dateString
$formattedDate = $date.ToString("dd\\MM\\yyyy")
$displayName= $item.displayName
$Manager=$item.ManagerName
$CurrentDate= Get-Date -Format  MM/dd/yyyy 
$DaysLeft = New-TimeSpan -Start $CurrentDate -End $Expiration
$Days=$DaysLeft.Days 
write-host "Processing account $Samaccountname"
$usermanager1= Get-ADUser -Identity $Samaccountname -Properties Manager | Select  -ExpandProperty Manager
write-host "EXpiry in $Expiration of $usermanager1 for $Days"
$useremail= Get-ADUser -Identity $Samaccountname | Select  -ExpandProperty UserPrincipalName 

if ($Days -le 45 -and $Days -gt 0) {
    $emailTo =  Get-ADUser -Identity $usermanager1  | Select  -ExpandProperty UserPrincipalName
    $subject = "Account Expiry Notification for $displayName"
    $smtpServer= "baussmtp01.crdnet.net"
    $emailFrom = "AccountExpiryNotification@bakelite.com"
    #$emailCC = "bakelite-command-center@bakelite.com";
	$emailBcc = "sivasankar.navajeevan@lntinfotech.com"
    $Path ="\\bmukbukcxvdip02\e$\Scripts\ContractorExpiryAutomationScript\Script_Output\ExpiringADuser_$dateTime.csv"


    $Image = "\\bmukbukcxvdip02\e$\Test\ContractorExpiryAutomationScript\header.png"
    #Embed Image
    $att1 = new-object Net.Mail.Attachment($Image)
    $att1.ContentType.MediaType = "image/png"
    $att1.ContentId = "Attachment"

 
    $Image2 = "\\bmukbukcxvdip02\e$\Test\ContractorExpiryAutomationScript\Signature.png"
    #Embed Image
    $att2 = new-object Net.Mail.Attachment($Image2)
    $att2.ContentType.MediaType = "image/png"
    $att2.ContentId = "Attachment2"


    $mailmessage = New-Object system.net.mail.mailmessage

    

    #Add attachment to the mail
    $mailmessage.Attachments.Add($att1)
    $mailmessage.Attachments.Add($att2)
    $body = "<p style='font-family: Calibri, sans-serif'>
    <img src='cid:Attachment' /><br />
    <b>THIS IS AN AUTOMATED EMAIL SENT FROM A MAILBOX THAT IS NOT MONITORED, PLEASE DO NOT REPLY TO THIS EMAIL </b>. <Br><Br>Hi $Manager, <br><br> Greetings from Bakelite IT Support.You are receiving this email as you are listed as a manager for the contractor account <b>'$displayName'</b> in our Bakelite IT system, which will expire in $Days Days.<br><br>If this account needs to remain active and needs to be extended beyond the current expiration date of <b>$formattedDate</b>, Please submit an account extension request using this <a href=""https://bakelitedev.service-now.com/b_sp?id=sc_cat_item&sys_id=8018f7811b596910636ea827bd4bcb2c&sysparm_category=c53c019d979e8110840ab7b3f153af6c&catalog_id=-1""><b>Link</b>.</a>. <br><br>Please note that the maximum time an account can be extended is 6 months.<br><br>User Name : $displayName<br> Email Address: $useremail <br><br>After <b>$expiration</b> the account will no longer be active without an extension request. If this account is no longer needed today, please submit a service request from our <a href=""https://bakelite.service-now.com/b_sp?id=sc_cat_item&sys_id=6602d5d597de8110840ab7b3f153af42&sysparm_category=9814c4451ba0d110636ea827bd4bcb92&catalog_id=63770a741bde4110636ea827bd4bcb88"">IT Service Request portal</a> to close this account immediately<br><br> Thank you for attention to this matter, <br> Bakelite IT Support <br><br>
   </p>
      <img src='cid:Attachment2' /><br />"

    try{
    #Mail info
    $mailmessage.from = $emailfrom
    $mailmessage.To.add($emailTo)
    $mailmessage.Bcc.Add($emailBcc)
    $mailmessage.Subject = $subject
    $mailmessage.Body = $body
    $mailmessage.IsBodyHTML = $true
    $SMTPClient = New-Object Net.Mail.SmtpClient($SmtpServer, 25)
    $SMTPClient.Send($mailmessage)
    #Dispose attachments
    $att1.dispose()
    write-host "Mail sent to user's manager whose account is going to expire in $Days days to $emailTo." }    

    $item.Action = "Mail sent to manager"
     Write-Host $item.Action
     $item.Date = Get-Date
    }
    catch{
    
    Write-Host "Mail not deliver to user manager"
      
       $item.Action = "Mail not sent to manager"
    
    }
    #Export the updated CSV file
      $csv | Export-Csv $Path -NoTypeInformation

	
   if ($Days -le -5) {

    $disabledou="OU=Disabled,OU=Z-USR,DC=bakelite,DC=net"
    $emailTo2= "bakelitedev@service-now.com"
    $subject2 = "Notification for disabling account $displayName"
    $smtpServer= "baussmtp01.crdnet.net"
    $emailFrom2 = "AccountExpiryNotification <glo.svc.adauto.01@bakelite.com>"   #provide email in userloginName
    #$emailCC = "bakelite-command-center@bakelite.com";
	$emailBcc = "sivasankar.navajeevan@lntinfotech.com"
	$body = "Hi Team,<br>'$displayName in Active Directory has been expired on $Expiration. This account is now disabled and moved to '$disabledou' as part of Automation script located at \\bmukbukcxvdip02\e$\Test\ContractorExpiryAutomationScript\ This account is now sent to IT systems for record purposes.<Br> <Br>Please note only account has been disabled and complete offboarding process is not completed. Please take necessary steps to complete the offboarding process."
    Send-MailMessage -To $emailTo2 -From $emailFrom2 -BCC $emailBcc -Subject $subject2 -BodyAsHtml $body -SmtpServer $smtpServer
      
      #disabling account after sending mail.
      Disable-ADAccount -Identity $Samaccountname 
      $Distinguishedname= Get-ADUser -Identity $Samaccountname | Select DistinguishedName
      $newdgn= $Distinguishedname.DistinguishedName
      Move-ADObject -Identity $newdgn -TargetPath $disabledou
      Write-Host "Successfully moved the disabled account to disabled OU"
      $item.Action= "Mail send to ticketing system"
      $item.Date= Get-Date
      $item.DisableStatus="Moved to Disable OU"
      $item.DisableBy=$loginUserName
      
    }     
     else {

          Write-Host "Account does not move to disable OU because it's not met criteria"
    
      }         
   #Export the updated CSV file
   $csv | Export-Csv $Path -NoTypeInformation
}   
} 


#calling function
$dateTime=get-Date -UFormat "%Y-%m-%d_%H-%M"
ExpirationStatus -dateTime $dateTime

 