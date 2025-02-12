# Created 2/11/25 by Surf2AirMissile
# Credits to ihaxr on Reddit for the original script inspiration
# Modify the value on line 11 (Where-Object) for your specific needs (currently a wildcard '*' value)
# You can use RequesterName (e.g. ADName\adminusers*) or CommonNames (e.g. yourCompany.ad.*specificservers.com)

# Set variable for expiry days you want it to check for?
$expiringDays = 30
$dates = "NotAfter <= {0},NotAfter >= {1}" -f (Get-Date).AddDays($expiringDays).ToShortDateString(),(Get-Date).ToShortDateString() 

# Get the certificate data
$results = certutil -view -restrict $dates -out "RequesterName,CommonName,Certificate Expiration Date" csv | 
    ConvertFrom-Csv -Header 'RequesterName','CommonName','ExpirationDate' |
    Select-Object -Skip 2 |
    Where-Object { $_.RequesterName -like '*' }

if ($results.Count -gt 0) {
    # Create HTML table style and header
    $htmlHeader = @"
<style>
    table {
        border-collapse: collapse;
        width: 100%;
        font-family: Arial, sans-serif;
    }
    th, td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: left;
    }
    th {
        background-color: #4CAF50;
        color: white;
    }
    tr:nth-child(even) {
        background-color: #f2f2f2;
    }
    tr:hover {
        background-color: #ddd;
    }
</style>
"@

    # Convert results to HTML
    $htmlBody = $results | ConvertTo-Html -Head $htmlHeader -PreContent "<h2>Certificates Expiring in the Next $expiringDays Days</h2>" -Property RequesterName,CommonName,ExpirationDate

    # Convert HTML body to string
    $htmlBodyString = $htmlBody -join "`n"

    # Email settings
    $smtpServer = "YourSMTPServer@email.com"  # Replace with your SMTP server
    $from = "no-reply@email.com"     # Replace with your sender address
    $to = "CertAdmins@email.com"    # Replace with recipient email
    $subject = "AD Certificate Expiration Report - $(Get-Date -Format 'MM/dd/yyyy')"

    # Send email
    $emailParams = @{
        SmtpServer = $smtpServer
        From = $from
        To = $to
        Subject = $subject
        Body = $htmlBodyString
        BodyAsHtml = $true
    }

    Send-MailMessage @emailParams

    # Optional: Also display in console
    Write-Host "Email sent with $($results.Count) certificates expiring in the next $expiringDays days."
} else {
    Write-Host "No certificates expiring in the next $expiringDays days. No email sent."
} 
