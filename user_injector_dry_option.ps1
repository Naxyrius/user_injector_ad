# Importer le module Active Directory
Import-Module ActiveDirectory

# Configuration
$Domain = "rhoaias.local"
$AdminsCsvPath = "C:\user_injector_ad-main\admin.csv"
$UsersCsvPath = "C:\user_injector_ad-main\users.csv"

# Chemins des OUs avec hiérarchie CORE > HUMANS
$AdminsOU = "OU=ADMINS,OU=HUMANS,OU=CORE,DC=rhoaias,DC=local"
$UsersOU = "OU=USERS,OU=HUMANS,OU=CORE,DC=rhoaias,DC=local"

# Demande de mode d'exécution
$choice = $null
while ($choice -notin 'Y','N') {
    $choice = Read-Host "Voulez-vous exécuter en mode Dry Run ? (Y/N)"
}

$DryRunMode = ($choice -eq 'Y')

# Fonction pour créer des utilisateurs avec vérification Dry Run
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

            # Vérification OU (toujours exécutée)
            if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$TargetOU'" -ErrorAction SilentlyContinue)) {
                throw "L'OU $TargetOU n'existe pas"
            }

            $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue

            if ($ExistingUser) {
                $message = "[SKIP] L'utilisateur $SamAccountName existe déjà."
                if ($DryRunMode) { $message += " (Dry Run)" }
                Write-Host $message -ForegroundColor Yellow
                continue
            }

            if (-not $DryRunMode) {
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
            else {
                Write-Host "[DRY RUN] Utilisateur $DisplayName serait créé dans l'OU $TargetOU." -ForegroundColor Cyan
            }
        }
        catch {
            $errorMessage = "[ERREUR] Échec de la création de $($User.first_name) $($User.last_name) : $_"
            if ($DryRunMode) { $errorMessage += " (Dry Run)" }
            Write-Host $errorMessage -ForegroundColor Red
        }
    }
}

# Exécution principale
if ($DryRunMode) {
    Write-Host "`n=== MODE DRY RUN ACTIVÉ ===" -ForegroundColor Magenta
    Write-Host "Aucune modification ne sera appliquée à l'AD`n" -ForegroundColor Magenta
}

Write-Host "Création des administrateurs dans CORE > HUMANS > ADMINS..." -ForegroundColor Cyan
New-ADUserFromCSV -CsvPath $AdminsCsvPath -TargetOU $AdminsOU

Write-Host "`nCréation des utilisateurs dans CORE > HUMANS > USERS..." -ForegroundColor Cyan
New-ADUserFromCSV -CsvPath $UsersCsvPath -TargetOU $UsersOU

if ($DryRunMode) {
    Write-Host "`n=== DRY RUN TERMINÉ ===" -ForegroundColor Magenta
    Write-Host "Résumé simulé - Aucun utilisateur créé" -ForegroundColor Magenta
}
