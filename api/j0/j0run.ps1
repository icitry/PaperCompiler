param([System.String]$dir)

$currwd = Get-Location

if(-not($dir)) { $dir = $currwd }

if ($dir -notmatch '\\$') { $dir += '\' }

Set-Location -Path $dir

Write-Output "Starting Docker setup."

docker-compose up -d --wait db redis  | Out-Null

Write-Output "Databases setup complete."

docker-compose up -d --wait | Out-Null

Write-Output "Main service setup complete."

Set-Location $currwd

Write-Output "Your Judge0 instance should now be running at http://<IP ADDRESS OF YOUR SERVER | 0.0.0.0>:2358"