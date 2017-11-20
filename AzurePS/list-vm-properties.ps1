<#
Go through all the subscriptions which are accessible by current account.
Go through every rescource groups and VMs in each groups.
List the properties such as VMsize, VM public IP, VM running state and latest status changing time.
#>

$lists = New-Object System.Collections.ArrayList
$subnames = (Get-AzureRmSubscription).Name
foreach($subname in $subnames)
{
    Get-AzureRmSubscription -SubscriptionName $subname | Select-AzureRmSubscription
    $rgnames = (get-azurermresourcegroup).resourcegroupname
    foreach ($rgname in $rgnames)
    {
        $vm = get-azurermvm -ResourceGroupName $rgname
        $vmnames = $vm.name
        foreach ($vmname in $vmnames)
        {
            $vmsize = (get-azurermvm -ResourceGroupName $rgname -Name $vmname).HardwareProfile.VmSize 
            $vmstatus = (get-azurermvm -ResourceGroupName $rgname -Name $vmname -Status).Statuses.displaystatus[1] 
            ((get-azurermvm -ResourceGroupName $rgname -Name $vmname -Status).Statuses.time ) >>  .\000.txt
            $time = (Get-Content -Path .\000.txt -TotalCount 2)[-1]
            remove-item -Path .\000.txt
            $nicid = ((Get-AzureRmVM -ResourceGroupName $rgname -Name $vmname).NetworkProfile.NetworkInterfaces.id)
            $nicname = $nicid.Substring($nicid.LastIndexOf('/')+1)
            $nic = (Get-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $rgname)
            $ipid = $nic.ipconfigurations[0].PublicIpAddress.Id
            $ipname = $ipid.substring($ipid.LastIndexOf('/')+1)
            $vmip = (Get-AzureRmPublicIpAddress -Name $ipname -ResourceGroupName $rgname).IpAddress
            $list = @{subname = $subname ;rgname= $rgname ;vmname = $vmname; size = $vmsize; status = $vmstatus ;ip = $vmip;time=$time}
            $lists.Add($list)
        }
    }
}

$lists | select @{name="subscription";expression={$_["subname"]}},@{name="rgname";expression={$_["rgname"]}}, @{name="vmname";expression={$_["vmname"]}},@{name="size";expression={$_["size"]}},@{name="time";expression={$_["time"]}} ,@{name="status";expression={$_["status"]}},@{name="IP";expression={$_["ip"]}}| Out-GridView
