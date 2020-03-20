$ClientId = 'd3ce6326-1661-4ae7-ad3d-a7a3cd26d624'
$ClientSecret = 'RzszCwP6+zvxzjQLjW6BK/Pw0CPILZMYD3jZ7Ocke2o='
$TenantId = '72f988bf-86f1-41af-91ab-2d7cd011db47'
$SubscriptionId = '6b991466-448b-4d86-8e6b-26f29920d721'
$ResourceGroupName = 'avresourcegci'
$AlertCategory = 'Alertibiza'
$SaveToDirectory =  'c:\temp'

Set-AzureRMContext -SubscriptionId $SubscriptionId

$WorkspaceName = "avomsci"
$Workspace = Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName

#NOTWORKING 
$SavedSearches = Get-AzureRmResource -ResourceId "subscriptions/$SubscriptionId/resourcegroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/savedSearches/" -ApiVersion "2015-03-20"

#Working
$SavedSearches = Get-AzureRmOperationalInsightsSavedSearch -ResourceGroupName $ResourceGroupName -WorkspaceName $WorkspaceName
$AlertQueries = $SavedSearches.Value | Where-Object {$_.properties.Category -eq $AlertCategory}

#NOTWORKING 
$Views = Get-AzureRmResource -ResourceId "subscriptions/$SubscriptionId/resourcegroups/$ResourceGroupName/providers/Microsoft.OperationalInsights/workspaces/$WorkspaceName/views/" -ApiVersion "2017-03-15-preview" 
$Dashboards = $Views.Properties.Dashboard 
$ChartQueries = New-Object System.Collections.Generic.List[System.Object]
foreach($dashboard in $Dashboards)
{
    $Charts = $dashboard.Configuration.charts
    
    if($Charts.Count -gt 0)
    {
        foreach($chart in $Charts)   
        {
            $ChartQueries.Add($chart)
        }
    }
}

$path = "$SaveToDirectory"
Write-Host "$path"
If(!(test-path $path))
{
       Write-Host "Directory does not exists."
      New-Item -ItemType Directory -Force -Path $path -Verbose
}
$Workspace | ConvertTo-Json | Out-File "$SaveToDirectory\OmsWorkspace.json" -Force -Verbose
$ChartQueries | ConvertTo-Json | Out-File "$SaveToDirectory\ChartQueries.json" -Force -Verbose
$AlertQueries | ConvertTo-Json | Out-File "$SaveToDirectory\AlertQueries.json" -Force -Verbose
$Views        | ConvertTo-Json | Out-File "$SaveToDirectory\Views.json" -Force 
$Views.Properties | ConvertTo-Json | Out-File "$SaveToDirectory\Dashboard.json" -Force
$Dashboards   | ConvertTo-Json | Out-File "$SaveToDirectory\Dashboard.json" -Force
$AlertQueries | ForEach-Object {$_.Properties} | ConvertTo-Json | Out-File "$SaveToDirectory\AlertQueries.Skimmed.json" -Force 
