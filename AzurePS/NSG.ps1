Login-AzureRmAccount #登入Azure
New-Item .\nsg -ItemType directory #创建工作目录
$rgn= Read-Host "Please enter resource group name" #输入网络资源组名称

$rule1 =  New-AzureRmNetworkSecurityRuleConfig -name CCRDP -Access allow -protocol tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix 10.1.0.0/16 -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389
$rule2 =  New-AzureRmNetworkSecurityRuleConfig -name DLRDP -access Allow -protocol tcp -Direction Inbound -Priority 1020 -SourceAddressPrefix 10.2.0.0/16 -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 3389

#$rule自定义规则

Get-AzureRmNetworkInterface -ResourceGroupName $rgn | Select-Object location | Out-File -FilePath .\nsg\location.txt #获取该资源组下所有网卡的地址，注意，这是有重复项的

$locationlinecount = ((Get-Content -Path .\nsg\location.txt).Length - 2)  #计算有效行数，因为上一步select-object直接生成出来的txt后面有两行空白，因此将行数减2处理

for ($i = 4; $i -le $locationlinecount;$i++) #每次select-object生成的txt前三行为tietle，因此从第四行开始，读取每一行的字符，并附加到$nsg_2.txt文件的末尾
    {
    (Get-Content -path .\nsg\location.txt -totalCount $i)[-1] | Out-File -Append .\nsg\location_2.txt
    }

Get-Content -Path .\nsg\location_2.txt| Sort-Object -unique | Out-File .\nsg\location_3.txt #去掉重复的location项，然后生成包含了所有location的文件

$locationcount = (get-content -Path .\nsg\location_3.txt).Length #获取location的数目

for ($i = 1; $i -le $locationcount;$i++) #为每个location创建网络安全组
    {
    if ($i -eq 1)
        {
        $location = (Get-Content -path .\nsg\location_3.txt -totalCount 1)
        New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgn -name allowrdp-$location -location $location -SecurityRules $rule1, $rule2
        }
    if ($i -ne 1)
        {
        $location = (Get-Content -path .\nsg\location_3.txt -totalCount $i)[-1]
        New-AzureRmNetworkSecurityGroup -ResourceGroupName $rgn -name allowrdp-$location -location $location -SecurityRules $rule1, $rule2
        }
    }

Get-AzureRmNetworkInterface -ResourceGroupName $rgn | Select-Object name | Out-File -FilePath .\nsg\nic.txt #获取该资源组下所有网卡的名称

$niclinecount = ((Get-Content -Path .\nsg\nic.txt).Length - 2) #计算有效的网卡数量，因为上一步select-object直接生成出来的txt后面有两行空白，因此将行数减2处理

for ($i = 4; $i -le $niclinecount;$i++) #为每个网卡配置在其地理位置的网络安全组
    {
    $nicname = (Get-Content -path .\nsg\nic.txt -totalCount $i)[-1]
    $niclocation = (Get-Content -path .\nsg\location.txt -totalCount $i)[-1]
    $nic = Get-AzureRmNetworkInterface -ResourceGroupName $rgn -Name $nicname
    $nsg =  Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rgn -Name allowrdp-$niclocation
    $nic.NetworkSecurityGroup = $nsg
    Set-AzureRmNetworkInterface -NetworkInterface $nic
    }

 Remove-Item -Path .\nsg\ -Recurse -Force #删除工作目录