
# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All","Policy.ReadWrite.ConditionalAccess","Directory.ReadWrite.All"
Select-MgProfile -Name "beta"

# 1. Create Users
# Example: Create 3 sample users
$users = @(
    @{DisplayName="Alice Johnson"; UserPrincipalName="alice.johnson@yourtenant.onmicrosoft.com"; MailNickname="alicej"; Password="P@ssw0rd123"},
    @{DisplayName="Bob Smith"; UserPrincipalName="bob.smith@yourtenant.onmicrosoft.com"; MailNickname="bobsmith"; Password="P@ssw0rd123"},
    @{DisplayName="Charlie Brown"; UserPrincipalName="charlie.brown@yourtenant.onmicrosoft.com"; MailNickname="charlieb"; Password="P@ssw0rd123"}
)

foreach ($u in $users) {
    New-MgUser -AccountEnabled $true `
               -DisplayName $u.DisplayName `
               -UserPrincipalName $u.UserPrincipalName `
               -MailNickname $u.MailNickname `
               -PasswordProfile @{Password=$u.Password; ForceChangePasswordNextSignIn=$true}
}

# 2. Enforce MFA for all users via Conditional Access
# Create a Conditional Access policy requiring MFA for all users
$policy = @{
    DisplayName = "Require MFA for All Users"
    State = "enabled"
    Conditions = @{
        Users = @{
            IncludeUsers = @("All")
        }
        Applications = @{
            IncludeApplications = @("All")
        }
    }
    GrantControls = @{
        Operator = "OR"
        BuiltInControls = @("mfa")
    }
}

New-MgIdentityConditionalAccessPolicy @policy

# 3. Optional: Verify MFA registration status
Get-MgUserAuthenticationMethod -UserId alice.johnson@yourtenant.onmicrosoft.com
