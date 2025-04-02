# Importer le module Active Directory
Import-Module ActiveDirectory

# Configuration
$Domain = "rhoaias.local"
$AdminsCsvPath = "C:\user_injector_ad-main\admins.csv"
$UsersCsvPath = "C:\user_injector_ad-main\users.csv"

# Chemins des OUs avec hiérarchie CORE > HUMANS
$AdminsOU = "OU=ADMINS,OU=HUMANS,OU=CORE,DC=rhoaias,DC=local"
$UsersOU = "OU=USERS,OU=HUMANS,OU=CORE,DC=rhoaias,DC=local"

# Fonction pour créer des utilisateurs dans une OU spécifique
function New-ADUserFromCSV {
    param(
        [string]$CsvPath,
        [string]$TargetOU
    )

    $Users = Import-Csv -Path $CsvPath -Encoding UTF8

    foreach ($User in $Users) {
        try {
            $SamAccountName = ($User.first_name.Substring(0,1) + $User.last_name).ToLower()
            $UPN = "$SamAccountName@$Domain"
            $DisplayName = "$($User.first_name) $($User.last_name)"

            # Vérifier l'existence de l'OU
            if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$TargetOU'" -ErrorAction SilentlyContinue)) {
                throw "L'OU $TargetOU n'existe pas"
            }

            if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue) {
                Write-Host "[SKIP] L'utilisateur $SamAccountName existe déjà." -ForegroundColor Yellow
                continue
            }

            New-ADUser -SamAccountName $SamAccountName `
                       -UserPrincipalName $UPN `
                       -Name $DisplayName `
                       -GivenName $User.first_name `
                       -Surname $User.last_name `
                       -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
                       -Enabled $true `
                       -Path $TargetOU `
                       -ChangePasswordAtLogon $true

            Write-Host "[OK] Utilisateur $DisplayName créé dans l'OU $TargetOU." -ForegroundColor Green
        }
        catch {
            Write-Host "[ERREUR] Échec de la création de l'utilisateur $($User.first_name) $($User.last_name) : $_" -ForegroundColor Red
        }
    }
}

# Exécution principale : Création des utilisateurs dans les OUs imbriquées
Write-Host "Création des administrateurs dans CORE > HUMANS > ADMINS..." -ForegroundColor Cyan
New-ADUserFromCSV -CsvPath $AdminsCsvPath -TargetOU $AdminsOU

Write-Host "Création des utilisateurs dans CORE > HUMANS > USERS..." -ForegroundColor Cyan
New-ADUserFromCSV -CsvPath $UsersCsvPath -TargetOU $UsersOU
