 Function SetReadOnlyAccess()
 {
  $path= "D:\source\0033a1300141412202200000006.BAD"
 
  #Perform tasks on the local machine
  $accessRules = @();
  $acl = Get-Acl -path $path;
  $allaccess = ($acl).Access;

  #get properties of file before making ReadOnly
  $before = Get-ItemProperty $path
  $beforeReadonly= $before.IsReadOnly
  $lastAccess= $before.LastAccessTime
  $creationTime= $before.CreationTime
 
  Write-Output "Getting all roles for the path: $path";

  foreach ($access in $allaccess) 
  {
    if (!$access.IdentityReference.Value.ToLower().Contains('admin')) 
    {
      $accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($access.IdentityReference.Value, "Read", "ContainerInherit, ObjectInherit", "None", "Allow")
      $accessRules += $accessrule
    }
  }

  foreach ($accessRule in $accessRules) 
  {  
   
    Write-Output "Setting access for $($accessrule.IdentityReference.Value) to Read-Only on path $path";
    $acl.SetAccessRuleProtection($True, $False)     # Inherited = false breaking Inheritance 
    Set-ItemProperty -Path $path -Name IsReadOnly -Value $True

    }

    # Get properties of file after making it ReadOnly
    $after = Get-ItemProperty $path
    
    $afterReadonly= $after.IsReadOnly

   $properties= [PSCustomObject]@{
   
       Filepath= $path
       CreationTime= $creationTime
       LastAccessTime= $lastAccess
       BeforeReadOnly = $beforeReadonly
       AfterReadOnly = $afterReadonly
   }

   $properties | Export-Csv -Path D:\Output.csv -Append -NoTypeInformation


  
}


#calling function
SetReadOnlyAccess