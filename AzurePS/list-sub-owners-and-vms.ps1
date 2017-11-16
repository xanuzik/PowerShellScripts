 New-Item .\sublist\ -ItemType directory
 $subnos =  (Get-AzureRmSubscription | foreach {$_.Name}).Length
 Get-AzureRmSubscription | foreach {$_.Name} | Out-File -FilePath .\sublist\subnames.txt
 Get-AzureRmSubscription | foreach {$_.id} | Out-File -FilePath .\sublist\subids.txt
 for ($i = 1; $i -le $subnos; $i++)
    {
    if($i -eq 1)
        {
        $subname = (get-content -Path .\sublist\subnames.txt -TotalCount 1)
        $id = (get-content -Path .\sublist\subids.txt -TotalCount 1)
        }
    if ($i -ne 1)
        {
        $subname = (get-content -Path .\sublist\subnames.txt -TotalCount $i)[-1]
        $id = (get-content -Path .\sublist\subids.txt -TotalCount $i)[-1]
        }
        $noput = Get-AzureRmSubscription -SubscriptionName $subname | Select-AzureRmSubscription
        echo $subname
        Get-AzureRmRoleAssignment -RoleDefinitionName owner -Scope /subscriptions/$id | Select-Object displayname, signinname, roledefinitionname |Format-Table 
        echo "VMs in $subname"
        Get-AzureRmVM | Format-Table
    }
