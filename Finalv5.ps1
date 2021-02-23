function Show-Menu
{
    param (
          [string]$Title = 'Select options for the operations'
    )
    cls
    Write-Host "================ $Title ================"
   
    Write-Host "1: Press '1' to To get complete disk details and export to CSV"
    Write-Host "2: Press '2' to Get SQL server edition & version"
    Write-Host "3: Press '3' to Snapcenter/snapdrive service status"
    Write-Host "4: Press '4' to Snapcenter port status"
    Write-Host "5: Press '5' to Display snapcenter eventlogs(Critical,error)"
    Write-Host "6: Press '6' to Display Ping and NSlookup results"
    Write-Host "Q: Press 'Q' to quit."
}
 
Function function1 {
Get-Volume | ForEach-Object {
  $VolObj = $_
  $ParObj = Get-Partition | Where-Object { $_.AccessPaths -contains $VolObj.Path }
  if ( $ParObj ) {
       $ParObj | Select-Object -Property * | Export-Csv -Path C:\Partiondata.csv -NoTypeInformation -Append
      '----------------------------------'
              $VolObj | Select-Object -Property * | Export-Csv -Path C:\voldata.csv -NoTypeInformation -Append
       '------------'
  }
}
}
Function function2 {
$inst = (get-itemproperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server').InstalledInstances
foreach ($i in $inst)
{
 $p = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL').$i
 (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Edition 
 (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$p\Setup").Version
}
}
Function function3 {
$servicename = Read-Host -Prompt 'Input your service name Ex:SnapManagerCoreService,SWSvc'
$arrservice = Get-service -name $servicename
 
if($arrservice.Status -eq 'Running')
{
 
Write-Host "$servicename is Running" -ForegroundColor Green
}
Else
{
Write-Host "$servicename is not Running" -ForegroundColor Red
}
} 

Function function4 {
$ErrorActionPreference = "SilentlyContinue"
$Ipaddress= Read-Host "Enter the IP address:"
$Port= Read-host "Enter the port number to access:"
 
$t = New-Object Net.Sockets.TcpClient
$t.Connect($Ipaddress,$Port)
   if($t.Connected)
   {
      
    Write-Host "Port $Port is operational" -ForegroundColor Green
   }
   else
   {
      Write-Host "Port $Port is closed" -ForegroundColor Red
   }
}
 
Function function5 {
Get-EventLog -LogName application -after(get-date).Adddays(-10) -Source s* -EntryType error,warning | Select-Object EntryType,Source,timegenerated,Message
Get-EventLog -LogName system -after(get-date).Adddays(-10) -Source s* -EntryType error,warning | Select-Object EntryType,Source,timegenerated,Message
}
Function function6 {
$ips = Read-Host -Prompt 'Input your server IP'
 
if (test-Connection -ComputerName $ips -Count 2 -Quiet ) {  
                   write-Host "$ips responded to ping" -ForegroundColor Green 
                   } else 
                   { Write-Warning "$address does not respond to pings"              
                   }  
       

Foreach ($ip in $ips) 

 
{

$name = nslookup $ip 2> $null | select-string -pattern "Name:" 

if ( ! $name ) { $name = "" } 

$name = $name.ToString() 

if ($name.StartsWith("Name:")) 

{ $name = (($name -Split ":")[1]).Trim() } 

else 

{ $name = "NOT FOUND" } 

Echo "$ip `t $name" 

}
}
 
#Main menu loop
do
{
    Show-Menu
    $input = Read-Host "Please make a selection"
    switch ($input)
    {
          '1' {
               cls
               function1
          } '2' {
               cls
               function2
          } '3' {
               cls
               function3
  } '4' {
               cls
               function4
  } '5' {
               cls
               function5
  } '6' {
               cls
               function6
          } 'q' {
               return
          }
    }
    pause
}
until ($input -eq 'q') 