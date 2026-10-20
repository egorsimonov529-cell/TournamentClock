# PowerShell script to copy SSH key using sshpass-like functionality
$Password = '4#9inC3%MYZ84F9f'
$ServerIP = '188.225.81.114'
$User = 'root'

# Read public key
$PubKey = Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub" -Raw

# Create a script that will be executed on the server
$ServerScript = @"
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$PubKey' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "Key copied successfully"
"@

# Write script to temp file
$ServerScript | Out-File -FilePath "$env:TEMP\server_script.sh" -Encoding ASCII

Write-Host "Attempting to copy SSH key to server..."

# Try using ssh with password prompt automation
$processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
$processStartInfo.FileName = "C:\Windows\System32\OpenSSH\ssh.exe"
$processStartInfo.Arguments = "-o StrictHostKeyChecking=no $User`@$ServerIP"
$processStartInfo.UseShellExecute = $false
$processStartInfo.RedirectStandardInput = $true
$processStartInfo.RedirectStandardOutput = $true
$processStartInfo.RedirectStandardError = $true
$processStartInfo.CreateNoWindow = $true

$process = [System.Diagnostics.Process]::Start($processStartInfo)

# Send password and commands
Start-Sleep -Seconds 2
$process.StandardInput.WriteLine($Password)
Start-Sleep -Milliseconds 500
$process.StandardInput.WriteLine("mkdir -p ~/.ssh")
Start-Sleep -Milliseconds 500
$process.StandardInput.WriteLine("chmod 700 ~/.ssh")
Start-Sleep -Milliseconds 500
$process.StandardInput.WriteLine("echo '$PubKey' >> ~/.ssh/authorized_keys")
Start-Sleep -Milliseconds 500
$process.StandardInput.WriteLine("chmod 600 ~/.ssh/authorized_keys")
Start-Sleep -Milliseconds 500
$process.StandardInput.WriteLine("echo 'Key copied successfully'")
Start-Sleep -Milliseconds 500
$process.StandardInput.WriteLine("exit")

$output = $process.StandardOutput.ReadToEnd()
$errorOutput = $process.StandardError.ReadToEnd()
$process.WaitForExit()

Write-Host "STDOUT:"
Write-Host $output
Write-Host "STDERR:"
Write-Host $errorOutput
Write-Host "Exit Code: $($process.ExitCode)"
