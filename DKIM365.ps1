function connexion{
Write-host ******************************************
Write-host * CONNEXION A LA CONSOLE EXCHANGE ONLINE *
Write-host ******************************************`r `n

Install-Module -Name ExchangeOnlineManagement -MinimumVersion 2.0.3
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline

function test-tenant {
Write-host *****************************************************
Write-host * ETAT DE DKIM SUR LE DOMAINE ONMICROSOFT DU TENANT *
Write-host *****************************************************`r `n

Get-DkimSigningConfig | Where-object {$_.Domain -Like "*onmicrosoft.com" } |ForEach-Object {
    if ($_.Enabled -eq $True)
        {
        Write-host $_.Domain :DKIM est ACTIF -ForegroundColor Green
        Write-host  Nous pouvons continuer la configuration DKIM des autres domaines -ForegroundColor Green `r `n
        $New = '0'
        }
    else 
        {
        Write-host $_.Domain :DKIM est INACTIF -ForegroundColor Red
        Write-Host Pour activer DKIM sur des domaines -ForegroundColor Yellow 
        Write-Host "Il est impératif de l'activer d'abord" -ForegroundColor Yellow
        Write-Host sur le domaine du tenant : $_.Domain -ForegroundColor Yellow
        $modifDkimTenant= Read-Host Voulez-vous activer DKIM sur le domaine $_.Domain  "(O/N)" ?
        while("o","n","O","N" -notcontains $modifDkimTenant )
        {$modifDkimTenant=Read-Host Voulez-vous activer DKIM sur le domaine $_.Domain  "(O/N)" ?}
        If ($modifDkimTenant -eq 'N' -Or $modifDkimTenant -eq 'n')
            {
            write-host ok pas de souci Bye Bye!
            }
        else
            {
            write-host activation de DKIM sur le domaine $_.Domain -ForegroundColor Yellow
            Set-DkimSigningConfig -identity $_.Domain -Enabled $True
            $New = '1'
            test-tenant
            }
        }
                                                                                            }
}

Function test-domains { 
Write-host *******************************************
Write-host * ETAT DE DKIM SUR LES DOMAINES DU TENANT *
Write-host *******************************************`r `n

Get-DkimSigningConfig | Where-object {$_.Domain -NotLike "*onmicrosoft.com" } |ForEach-object {
    if ($_.Enabled -eq $true)
    {
        Write-host $_.Domain :DKIM est ACTIF -ForegroundColor Green
    }
else 
    {
    Write-host $_.Domain :DKIM est INACTIF -ForegroundColor Red

    $modifDkimDomain=Read-Host Voulez-vous activer DKIM sur le domaine $_.Domain  "(O/N)" ?
    while("o","n","O","N" -notcontains $modifDkimDomain )
    {Read-Host Voulez-vous activer DKIM sur le domaine $_.Domain  "(O/N)" ?}
        If ($modifDkimDomain -eq 'n' -Or $modifDkimDomain -eq 'N')
        {
        write-host ok pas de souci!
        }
        else
        {
        write-host Activation de DKIM sur le domaine $_.Domain -ForegroundColor Yellow
            if ($New -eq '1')
            {
            New-DkimSigningConfig -DomainName $_.domain -Enabled $True
            }
            else
            {
            Set-DkimSigningConfig -identity $_.domain -Enabled $True
            }

        Get-DkimSigningConfig -Identity $_.Domain | select Domain, Selector1CNAME, Selector2CNAME |ForEach-object {
        Write-Host VOICI LES ENREGISTREMENTS CNAME A RENSEIGNER SUR LA ZONE DNS DU DOMAINE: $_.Domain -ForegroundColor Green
        Write-Host Hôte: selector1._domainkey  avec la valeur: $_.Selector1CNAME -ForegroundColor Green
        Write-Host Hôte: selector2._domainkey  avec la valeur: $_.Selector2CNAME -ForegroundColor Green
                                                                                                                   }
      }
      }
    }
                                                                                                }
# connexion
test-tenant
test-domains
pause
 
