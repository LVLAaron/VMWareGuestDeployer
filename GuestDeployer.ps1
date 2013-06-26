# Add PowerCLI bits
Add-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
# Connect to Virtual Infrastructure
Connect-VIserver LouPrMgt011.zcloud.com
  
$vmlist = Import-CSV "C:\vm.csv"
  
# Syntax and sample for CSV File:
# ipaddress,subnet,gateway,pdns,sdns,vmname,template,diskformat,dvpg
  
foreach ($item in $vmlist) {
  
    # Map variables
    $ipaddr = $item.ipaddress
    $subnet = $item.subnet
    $gateway = $item.gateway
    $pdns = $item.pdns
    $sdns = $item.sdns
    $vmname = $item.vmname
    $template = $item.template
    $diskformat = $item.diskformat
    $dvpg = $item.dvpg
      
# Determine cluster and customization spec file to use
if ($vmname -like "LouPr*") {$vmcluster = "Production";$customspecfile = "scripted_prod";$VMFSVol = "Production_0"}
if ($vmname -like "LouQa*") {$vmcluster = "Development";$customspecfile = "scripted_qa";$VMFSVol = "XIO_DevQa_0"}
if ($vmname -like "LouDv*") {$vmcluster = "Development";$customspecfile = "scripted_dev";$VMFSVol = "XIO_DevQa_0"}
  
      
# Find matching datastore with most free space
$LargestStore = Get-Datastore | where {$_.Name -match $VMFSVol} | Sort FreeSpaceGB | Select -Last 1
# Find host with most available memory
$BestHost = Get-Cluster $vmcluster | Get-VMHost | Sort MemoryUsageGB | Select -Last 1   
  
# Deal with customization spec file
Get-OSCustomizationSpec $customspecfile | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -Dns $pdns,$sdns
  
#Deploy the VM based on the template with the adjusted Customization Specification
New-VM -Name $vmname -Template $template -Datastore $LargestStore -DiskStorageFormat $diskformat -VMHost $BestHost -OSCustomizationSpec $customspecfile
 
#Set the Port Group Network Name (Match PortGroup names with the VLAN name)
Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $dvpg -Confirm:$false
  
Start-VM $vmname
}
