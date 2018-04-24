$lists = New-Object System.Collections.ArrayList
$subnames = (Get-AzureRmSubscription).Name
foreach($subname in $subnames)
{
    Get-AzureRmSubscription -SubscriptionName $subname | Select-AzureRmSubscription
    $cloudserviceids=(get-azurermresource | where-object -filterscript {$_.ResourceType -eq "Microsoft.ClassicCompute/domainNames"}).resourceid
    foreach($cloudserviceid in $cloudserviceids)
    {
        $rgname=(Get-AzureRmResource -ResourceId $cloudserviceid).resourcegroupname
        $cloudservicehost=(Get-AzureRmResource -ResourceId $cloudserviceid).Properties.hostname
        nslookup $cloudservicehost >> .\111.txt
        $ipstring=(Get-Content -Path .\111.txt -TotalCount 5)[-1]
        $ip=$ipstring.Substring(9)
        Remove-Item -Path .\111.txt
        $list = @{ip = $ip ;rgname = $rgname ;host = $cloudservicehost ;sub = $subname}
        $lists.Add($list)
    }   
}
$lists | select @{name="Subscription";expression={$_["sub"]}},@{name="ResourceGroup";expression={$_["rgname"]}},@{name="IP";expression={$_["ip"]}}, @{name="Hostname";expression={$_["host"]}}| Out-GridView
