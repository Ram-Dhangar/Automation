function CheckFileModified 
{
$data = Import-Csv -Path "D:\temp\220219-11 - Import from file share to Documents.csv"
#Filter the rows based on a status condition
$filteredData = $data | Where-Object {$_.Status -eq 'Success' -or $_.Status -eq 'Skipped' -or $_.Status -eq 'Warning' -and $_.Type -eq 'File' }

foreach($files in $filteredData)
{
   $FilePath=$files.'Source path'
   $destinationPath= $files.'Destination path'
   $Migrateddate = $files.Date
   Write-Host $FilePath 
  
   $Path ="D:\temp\220219-11 - Import from file share to Documents.csv"
   #$FilePath="D:\source\MasterFile.txt"


# Check if the file exists

    if (-not (Test-Path $FilePath)) {

        Write-Error "File not found: $FilePath"

        return
       }

    # Get the file's last modified date/time

    $LastModifiedDate = (Get-Item $FilePath).LastWriteTime
    $fileName= (Get-Item $FilePath).Name
    $LastModifiedDateTime= $LastModifiedDate.ToString("M/d/yyyy")   
    
    
     
    # Move the file if it hasn't been modified 
   if ($LastModifiedDateTime -eq $Migrateddate) 
   {
     Write-Host "$fileName has not been modified "

     Move-Item $FilePath $destinationPath
     Write-Host "$fileName has successfully moved to $destinationPath"   
     $files.'Archive status'="File Archive Successfully"
     $files.'Archive path'=$destinationPath
     $files.'Archive FileName'=$fileName
     

    }  
   else{
    Write-Host "$fileName has been modified" 
      $files.'Archive status' = "File Not Archive" 
      $files.'Archive FileName' = $fileName
    }

    $filteredData | Export-Csv $Path -NoTypeInformation
}


}


#calling function
CheckFileModified 
















