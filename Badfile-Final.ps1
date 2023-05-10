function BadfileReport
{

$badfile = Get-ChildItem  "C:\Automation\To_be_process\" 

foreach($file in $badfile)
{
 $filename=$file
 $badfilepath= "C:\Automation\To_be_process\",$filename -join '' 


 
$failure=Get-Content -Path $badfilepath | Select-String -Pattern "This is an automatically generated Delivery Status Notification." -Context 0,9 
try{
if($failure -ne "")
{
$newfail=$failure.ToString()
$sep="--"
$part = $newfail.Split($sep)
$newfailure=$part[0]
}
else{$newfailure=$newfailure.Trim()}
}
catch{
   Write-Host "some feilds are missing from file"
}

$servername=Get-Content -Path $badfilepath | Select-String -Pattern "Content-Type: message/rfc822" -Context 0,10

$sname=$servername.ToString()

$arr=$sname.Split(" ")
$serverIP=$arr[8,9]
$serverIP.ToString()

$newserverip=$serverIP -join ''
$newserverip=$newserverip.Trim()

$newdate =$arr[17,18,19,20,21,22]
$newdate.ToString()
$date=$newdate -join ''
$date=$newdate.Trim()


$sname | Out-File c:\temp\logs.txt


$from=Get-Content c:\temp\logs.txt | select-string 'From:'

$f=$from.ToString()
$newfrom=$f -split ':' -replace 'From',''
$Newfrom=$newfrom -join ''
$Newfrom=$Newfrom.Trim()





$to=Get-Content c:\temp\logs.txt | select-string  'To:'

$t = $to | Select-Object -Last 1
$new=$t.ToString()
$newto=$new -split ':' -replace 'To'
$newto=$newto -join ''
$newto=$newto.Trim()



$s=Get-Content c:\temp\logs.txt | select-string 'Subject:'
$sub=$s.ToString()
$subject=$sub -split ': ' -replace 'Subject',''
$subject=$subject.Trim()



$c=Get-Content c:\temp\logs.txt | select-string 'cc:' 

if($c -eq $null)
{
  $newcc= "NA"
}
else{
      $cc=$c.ToString()
      $newcc=$cc -split ': ' -replace 'cc',''
}

$b=Get-Content c:\temp\logs.txt | select-string 'bcc:'

if($b -eq $null)
{
  $newbcc= "NA"
}
else{
      $bcc=$b.ToString()
      $newbcc=$bcc -split ': ' -replace 'bcc','' 
}

if($newserverip -eq "" -or $newfailure -eq "" -or $date -eq "" -or $newfrom -eq "" -or $newto -eq "" -or $subject -eq "")
{ 
  $failcsv ="c:\Automation\Records\failed_Record.csv" 
  $filename | Select-Object  @{n=”Filename”;e={$filename}},@{n=”Date”;e={$date}},@{n=”FromServer”;e={$Newserverip}},@{n="FromEmailID";e={$Newfrom}},@{n="ToEmailID";e={$newto}},@{n="CCEmailID";e={$newcc}},@{n="BCCEmailID";e={$newbcc}},@{n="Subjectline";e={$subject}},@{n="FailureReason";e={$newfailure}} | Export-csv $failcsv -NoTypeInformation -Append
  Move-Item -Path $badfilepath -Destination C:\Automation\Failures_files\

}
else{

    $csv = "C:\Automation\Records\successful_Report.csv"
    $Filename | Select-Object @{n=”Filename”;e={$filename}},@{n=”Date”;e={$date}},@{n=”FromServer”;e={$Newserverip}},@{n="FromEmailID";e={$Newfrom}},@{n="ToEmailID";e={$newto}},@{n="CCEmailID";e={$newcc}},@{n="BCCEmailID";e={$newbcc}},@{n="Subjectline";e={$subject}},@{n="FailureReason";e={$newfailure}} | Export-Csv $csv -NoTypeInformation -Append -Force
    Move-Item -Path $badfilepath -Destination C:\Automation\Proceed_files\

}
}

}


BadfileReport


