param([System.String]$dir)

$currwd = Get-Location

if(-not($dir)) { $dir = $currwd }

if ($dir -notmatch '\\$') { $dir += '\' }

$client = new-object System.Net.WebClient
$client.DownloadFile("https://github.com/judge0/judge0/releases/download/v1.13.0/judge0-v1.13.0.zip", $dir + "judge0ce.zip")

Write-Output "Downloaded source zip."

$unzippedFp = $null

$zipPath =  $dir + "judge0ce.zip"

Expand-Archive -Path $zipPath -DestinationPath $dir -Verbose -Force *>&1 | % {
	if($_.message -match "Created '(.*docker-compose.yml)'.*") {
		$unzippedFp = $Matches[1]
	}
}

if(-not($unzippedFp)) {
	Write-Output "Error unzipping file."
	exit
}

Write-Output "Unzipped documents."

Remove-Item $zipPath

$unzippedFp = Split-Path -Path $unzippedFp -Parent

Set-Location -Path $unzippedFp

Write-Output "Starting Docker setup."

docker-compose up -d --wait db redis  | Out-Null

Write-Output "Databases setup complete."

docker-compose up -d --wait | Out-Null

Write-Output "Main service setup complete."

Set-Location $currwd

Write-Output "Your Judge0 instance should now be running at http://<IP ADDRESS OF YOUR SERVER | 0.0.0.0>:2358"