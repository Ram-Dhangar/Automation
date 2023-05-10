# adding user in bulk in CIS BU

New-ADOrganizationalUnit "CIS" -Description "CIS ACADEMY BATCH 21"

#importing CSV file -name --- CIS_Batch21.csv

$ADuser = Import-Csv C:\CIS\CIS_Batch21.csv

foreach($User in $ADuser)
{
  $Username= $User.uname
  $Password= $User.pass
  $Firstname= $User.fname
  $Lastname= $User.lname
  $Department= $User.dname
  $OU= $User.ou

  if(Get-ADUser -F{SamAccountName -eq $Username})
   {
    Write-Warning "This User account is already exite in directory"
   }
   else
   {
      New-ADUser -SamAccountName "$Username" -Name "$Firstname $Lastname" -GivenName $Firstname -Surname $Lastname -DisplayName $Firstname -Path $OU -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Description "Local User" -Department $Department 
      
   
   }

}
