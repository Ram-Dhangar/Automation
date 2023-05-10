function Adduser($firstname,$lastname)
{
#Install-Module msOnline
$license=(Get-MsolAccountSku)
$licenseType=$licencetype[0].AccountSkuId

$upn="$firstname$lastname@LTIMIndtree243.onmicrosoft.com"
$display="$firstname $lastname"
$defaultpasswd="Password@123"
 
#Admin user and Password
$admin_username = "UnnatiJoshi@LTIMIndtree243.onmicrosoft.com"
$admin_passwd = "Newuser@123"
$admin_secpasswd = ConvertTo-SecureString -String $admin_passwd -AsPlainText -Force
$admin_cred = New-Object Management.Automation.PSCredential ($admin_username, $admin_secpasswd)
Connect-MsolService -Credential $cred

 


#getting the list of users

$user=Get-MsolUser -UserPrincipalName $upn -ErrorAction SilentlyContinue
if($user -ne $null)
{
  Write-Host $upn," User is already exist"
  
} 
else
{
 New-MsolUser -DisplayName $display -FirstName $firstname -LastName $lastname -UserPrincipalName $upn -UsageLocation IN -Password $defaultpasswd -ForceChangePassword $true
 Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $licenseType
}


 
}


Adduser -firstname "Chetan" -lastname "Baviskar"