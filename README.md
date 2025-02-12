The PowerShell script checks for certificates expiring within a specified number of days and sends an email report if any are found. Specify the number of days to check for expiring certificates in the $expiringDays variable and customize the Where-Object clause to filter certificates based on specific criteria (e.g. RequesterName should include domain admins then do something like AD\admin*).

The script retrieves certificate data using certutil, filters the results, converts them into an HTML table, and sends an email with the report if there are any expiring certificates. If no certificates are expiring, no email is sent.

Example Email:

![Email Screenshot Example](https://github.com/user-attachments/assets/c5d07c03-4b9e-42dd-8815-cd3a7ec4784c)
