#the script is to add the users in a specific group to all subcriptions as reader
#the script should be run by superadmin who has permissions of all subscriptions

$subids = (Get-AzureRmSubscription).SubscriptionId
#$subids = get-content -Path D:\bbb.txt
$admingroupid = (Get-AzureRmADGroup -SearchString azureadmin_cn).id.tostring()
foreach($subid in $subids)
{
    Get-AzureRmSubscription -SubscriptionId $subid | Select-AzureRmSubscription
    New-AzureRmRoleAssignment -ObjectId $admingroupid -RoleDefinitionName reader -Scope /subscriptions/$subid 
}