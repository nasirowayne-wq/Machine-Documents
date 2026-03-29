# --- CONFIGURATION ---
$SourceData = "D:\Kashif Raza Khan\Machine Documents"
$ScriptFolder = "D:\Kashif Raza Khan\Sudhir_Scripts"
$RepoUrl = "https://github.com/nasirowayne-wq/Machine-Documents.git"

Set-Location $SourceData
if (!(Test-Path $ScriptFolder)) { New-Item -ItemType Directory -Path $ScriptFolder }

Write-Host "--- SCANNING DATA FOR BATCHING ---" -ForegroundColor Cyan

# 1. Get all files (excluding Git and System files)
$AllFiles = Get-ChildItem -Path $SourceData -Recurse -File | Where-Object { $_.FullName -notlike "*\.git*" }
$TotalCount = $AllFiles.Count
$FilesPerBatch = [Math]::Ceiling($TotalCount / 10)

Write-Host "Total Files Found: $TotalCount" -ForegroundColor White
Write-Host "Files per Script: $FilesPerBatch" -ForegroundColor White

# 2. Generate the 10 Scripts
for ($i = 1; $i -le 10; $i++) {
    $StartIndex = ($i - 1) * $FilesPerBatch
    # Ensure we don't go out of bounds on the last batch
    $Count = [Math]::Min($FilesPerBatch, $TotalCount - $StartIndex)
    
    if ($Count -le 0) { break }

    $BatchFiles = $AllFiles[$StartIndex..($StartIndex + $Count - 1)]
    
    # Create the text for the individual upload script
    $ScriptContent = @"
Write-Host "--- STARTING UPLOAD PART $i OF 10 ---" -ForegroundColor Cyan
Set-Location "$SourceData"

# Ensure Git is initialized
if (!(Test-Path ".git")) { 
    git init
    git remote add origin $RepoUrl
    git branch -M main
}

Write-Host "Staging $Count files for Batch $i..." -ForegroundColor Yellow
"@

    # Add each specific file path to the git add command for this script
    foreach ($File in $BatchFiles) {
        $RelativePath = $File.FullName.Replace("$SourceData\", "")
        $ScriptContent += "`ngit add `"$RelativePath`""
    }

    $ScriptContent += @"

Write-Host "Committing Batch $i..." -ForegroundColor Gray
git commit -m "Upload Part $i of 10"

Write-Host "Pushing to GitHub..." -ForegroundColor Green
git push origin main
if (`$LASTEXITCODE -ne 0) {
    Write-Host "Push failed. Trying force push..." -ForegroundColor Red
    git push origin main --force
}

Write-Host "PART $i FINISHED!" -ForegroundColor Green
Pause
"@

    # Save the individual script
    $FilePath = Join-Path $ScriptFolder "Upload_Part$i.ps1"
    $ScriptContent | Out-File -FilePath $FilePath -Encoding utf8
    Write-Host "Created: Upload_Part$i.ps1 ($Count files)" -ForegroundColor Gray
}

Write-Host "--- SUCCESS! 10 SCRIPTS CREATED IN $ScriptFolder ---" -ForegroundColor Green
ii $ScriptFolder