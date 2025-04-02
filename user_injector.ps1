# Importer le module Active Directory
Import-Module ActiveDirectory

# Déclaration des variables
$Domain = "rhoaias.local"                       # Domaine AD
$AdminsCsvPath = "C:\admin.csv"    # Chemin du fichier CSV pour les ADMINS
$UsersCsvPath = "C:\users.csv"      # Chemin du fichier CSV pour les Users
$AdminsOU = "OU=ADMINS,DC=rhoaias,DC=local"     # Chemin LDAP de l'OU ADMINS
$UsersOU = "OU=Users,DC=rhoaias,DC=local"       # Chemin LDAP de l'OU Users

# Fonction pour créer des utilisateurs dans une OU spécifique
function New-ADUserFromCSV {
    param(
        [string]$CsvPath,
        [string]$TargetOU
    )

    # Importer les données du fichier CSV
    $Users = Import-Csv -Path $CsvPath -Encoding UTF8

    foreach ($User in $Users) {
        try {
            # Génération des identifiants utilisateur
            $SamAccountName = ($User.first_name.Substring(0,1) + $User.last_name).ToLower()
            $UPN = "$SamAccountName@$Domain"
            $DisplayName = "$($User.first_name) $($User.last_name)"

            # Vérification de l'existence de l'utilisateur dans AD
            if (Get-ADUser -Filter "SamAccountName -eq '$SamAccountName'" -ErrorAction SilentlyContinue) {
                Write-Host "[SKIP] L'utilisateur $SamAccountName existe déjà." -ForegroundColor Yellow
                continue
            }

            # Création de l'utilisateur dans AD
            New-ADUser -SamAccountName $SamAccountName `
                       -UserPrincipalName $UPN `
                       -GivenName $User.first_name `
                       -Surname $User.last_name `
                       -DisplayName $DisplayName `
                       -AccountPassword (ConvertTo-SecureString $User.Password -AsPlainText -Force) `
                       -Enabled $true `
                       -Path $TargetOU `
                       -ChangePasswordAtLogon $true `
                       -PassThru | Out-Null

            Write-Host "[OK] Utilisateur $DisplayName créé dans l'OU $TargetOU." -ForegroundColor Green
        }
        catch {
            Write-Host "[ERREUR] Échec de la création de l'utilisateur $($User.first_name) $($User.last_name) : $_" -ForegroundColor Red
        }
    }
}

# Exécution principale : Création des utilisateurs dans les OUs correspondantes
Write-Host "Création des utilisateurs dans l'OU ADMINS..." -ForegroundColor Cyan
New-ADUserFromCSV -CsvPath $AdminsCsvPath -TargetOU $AdminsOU

Write-Host "Création des utilisateurs dans l'OU Users..." -ForegroundColor Cyan
New-ADUserFromCSV -CsvPath $UsersCsvPath -TargetOU $UsersOU
