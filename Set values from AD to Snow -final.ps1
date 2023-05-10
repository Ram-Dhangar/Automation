function SetValues()
{


# Set ServiceNow credentials and instance URL
$username = "testadaccount"
$password = ':icj$Y@<T,3q2gJjz^qhhj7lmQ]@7?tb)pQ4lkCK'
$instanceUrl = "https://bakelitedev.service-now.com"
 
# Set variables for email configuration
$smtpServer = "smtp1.lntinfotech.com"
$from = "Ramkrushna.Dhangar@lntinfotech.com"
$to = "generalnhacc@gmail.com"
$subject = "Users with Blank Manager Values in AD"
 
# Get all AD users who do not have a manager set
$adUsers = Get-ADUser -filter * -Properties *


# Connect to ServiceNow using REST API
$uri = $instanceUrl + "/api/now/table/sys_user"
$auth = "Basic " + [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($username + ":" + $password))
$headers = @{ "Authorization" = $auth; "Content-Type" = "application/json" }
 
# Loop through the list of users and update the manager value to blank in ServiceNow
$logMessage = "The following users had their manager value set to blank in ServiceNow:`r`n"
 
foreach ($user in $adUsers) {
   # Get the ServiceNow user record for the current AD user
   $url = "$instanceUrl/api/now/table/sys_user?sysparm_query=user_name=" + $user.UserPrincipalName
   $response = Invoke-RestMethod -Uri $url -Headers $headers
   Write-Host "processing account:",$user.displayName
 
   if ($response.result) {
       # Get the sys_id of the ServiceNow user record
       $sys_id = $response.result.sys_id
 
       # Update the manager field of the ServiceNow user record to blank
       $url = "$instanceUrl/api/now/table/sys_user/$sys_id"
       $samaccountname=$user.SamAccountName
       $mail = if ([string]::IsNullOrEmpty($user.mail)) { "" } else { $user.mail }
       $pager = if ([string]::IsNullOrEmpty($user.pager)) { "" } else { $user.pager }
       $upn = if ([string]::IsNullOrEmpty($user.UserPrincipalName)) { "" } else { $user.UserPrincipalName }
       $givenName = if ([string]::IsNullOrEmpty($user.givenName)) { "" } else { $user.givenName }
       $surname = if ([string]::IsNullOrEmpty($user.sn)) { "" } else { $user.sn }

       $name=Get-ADUser -Identity $samaccountname -Properties manager | Select-Object -ExpandProperty manager | Get-ADUser | Select-Object -Property name
       $Mname=$name.name
       $manager = if ([string]::IsNullOrEmpty($Mname)) { "" } else { $Mname }
       $telephone = if ([string]::IsNullOrEmpty($user.telephoneNumber)) { "" } else { $user.telephoneNumber }
       $title = if ([string]::IsNullOrEmpty($user.Title)) { "" } else { $user.Title }
       $city = if ([string]::IsNullOrEmpty($user.City)) { "" } else { $user.City }
       $country = if ([string]::IsNullOrEmpty($user.Country)) { "" } else { $user.Country }
       $company = if ([string]::IsNullOrEmpty($user.Company)) { "" } else { $user.Company }
       $cost_center = if ([string]::IsNullOrEmpty($user.Description)) { "" } else { $user.Description }
       $department = if ([string]::IsNullOrEmpty($user.Department)) { "" } else { $user.Department }
       $location = if ([string]::IsNullOrEmpty($user.comment)) { "" } else { $user.comment }
       $mobile = if ([string]::IsNullOrEmpty($user.mobile)) { "" } else { $user.mobile}
       $state = if ([string]::IsNullOrEmpty($user.State)) { "" } else { $user.State}
       $street = if ([string]::IsNullOrEmpty($user.Street)) { "" } else { $user.Street}
       $zip = if ([string]::IsNullOrEmpty($user.PostalCode)) { "" } else { $user.PostalCode}

       $body = @{ user_name=$upn;manager =$manager;email=$mail;employee_number=$pager;first_name=$givenName;last_name=$surname;phone=$telephone;title=$title;city=$city;country=$country;company=$company;cost_center=$cost_center;department= $department;location=$location;mobile_phone=$mobile;state=$state;street=$street;zip=$zip;u_crd_name="100135C"} | ConvertTo-Json
       $response = Invoke-RestMethod -Uri $url -Method Put -Headers $headers -Body $body
         Write-Host $user.displayName,"Successfully updated values!"
       $logMessage += "$($user.DisplayName) ($($user.UserPrincipalName))`r`n"
   }
}

}



#calling function
SetValues






