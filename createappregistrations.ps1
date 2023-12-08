apt-get update ; ` apt-get install git curl wget -y ; ` curl -sL https://aka.ms/InstallAzureCLIDeb | bash ; ` az login --identity ; ` $ADApplicationID = $null; ` $ADApplicationSecret = $null; ` $ADMTApplicationID = $null; ` try { $ADApplication = $( az ad app create --only-show-errors --display-name $WebAppNamePrefix-FulfillmentAppReg | ConvertFrom-Json); ` $ADObjectID = $ADApplication.id; ` $ADApplicationID = $ADApplication.appId; ` Start-Sleep -Seconds 5; ` $ADApplicationSecret = $( az ad app credential reset --id $ADObjectID --append --display-name "SaaSAPI" --years 2 --query password --only-show-errors --output tsv); ` Write-Host ApplicationID: $ADApplicationID; ` Write-Host AppSecret: $ADApplicationSecret } catch [System.Net.WebException], [System.IO.IOException] {; ` Write-Host $PSItem.Exception; ` break; }; ` Write-Host CreatingLandingPageSSOAppRegistration; ` try { $appCreateRequestBodyJson = '{ \"displayName\" : \"$WebAppNamePrefix-LandingpageAppReg\", \"api\":  { \"requestedAccessTokenVersion\" : 2 }, \"signInAudience\" : \"AzureADandPersonalMicrosoftAccount\", \"web\": { \"redirectUris\":   [ \"https://$WebAppNamePrefix-portal.azurewebsites.net\",  \"https://$WebAppNamePrefix-portal.azurewebsites.net/\",  \"https://$WebAppNamePrefix-portal.azurewebsites.net/Home/Index\",  \"https://$WebAppNamePrefix-portal.azurewebsites.net/Home/Index/\",  \"https://$WebAppNamePrefix-admin.azurewebsites.net\",  \"https://$WebAppNamePrefix-admin.azurewebsites.net/\",  \"https://$WebAppNamePrefix-admin.azurewebsites.net/Home/Index\",  \"https://$WebAppNamePrefix-admin.azurewebsites.net/Home/Index/\" ],  \"logoutUrl\": \"https://$WebAppNamePrefix-portal.azurewebsites.net/logout\",  \"implicitGrantSettings\": { \"enableIdTokenIssuance\" : true } }, \"requiredResourceAccess\": [{ \"resourceAppId\": \"00000003-0000-0000-c000-000000000000\",  \"resourceAccess\":  [{   \"id\": \"e1fe6dd8-ba31-4d61-89e7-88639da4683d\",  \"type\": \"Scope\"   }] }] }'; ` $landingpageLoginAppReg = $( az rest --method POST --headers "Content-Type=application/json" --uri https://graph.microsoft.com/v1.0/applications --body $appCreateRequestBodyJson | ConvertFrom-Json ); ` $ADMTApplicationID = $landingpageLoginAppReg.appId; ` $ADMTObjectID = $landingpageLoginAppReg.id; ` Write-Host ApplicationId: $ADMTApplicationID } catch [System.Net.WebException], [System.IO.IOException] {; ` Write-Host $PSItem.Exception; ` break; }; ` $output = "$ADApplicationID#$ADApplicationSecret#$ADMTApplicationID"; ` Write-Output $output; ` $DeploymentScriptOutputs = @{}; ` $DeploymentScriptOutputs['text'] = $output
