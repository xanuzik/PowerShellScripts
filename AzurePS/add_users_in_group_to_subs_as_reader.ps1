#the script is to add the users in a specific group to all subcriptions as reader
#the script should be run by superadmin who has permissions of all subscriptions

#$subids = (Get-AzureRmSubscription).SubscriptionId
#$subids = get-content -Path D:\bbb.txt
$admingroupid = (Get-AzureRmADGroup -SearchString azureadmin_cn).id.tostring()
$adminnames = (Get-AzureRmADGroupMember -GroupObjectId $admingroupid).userprincipalname
foreach($subid in $subids)
{
    Get-AzureRmSubscription -SubscriptionId $subid | Select-AzureRmSubscription
    $subuers = (Get-AzureRmRoleAssignment).signinname
    foreach($adminname in $adminnames)
    {
        $judge = $subuers.Contains($adminname)
        if ($judge -eq "true")
        {
        }
        else
        {
          $adminnameid = (Get-AzureRmADUser -UserPrincipalName $adminname).id.tostring()
          New-AzureRmRoleAssignment -ObjectId $adminnameid -RoleDefinitionName reader -Scope /subscriptions/$subid  
        }
    }
}