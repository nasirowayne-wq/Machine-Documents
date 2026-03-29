$SourceData = "D:\Kashif Raza Khan\Machine Documents"
Set-Location $SourceData

Write-Host "--- CLEANING 10GB OF JUNK DATA ---" -ForegroundColor Cyan

# 1. Delete the folders that contain the thousands of tiny .js files
Write-Host "Removing .download and _files folders..." -ForegroundColor Yellow
Get-ChildItem -Path $SourceData -Recurse -Directory -Filter "*.download" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
Get-ChildItem -Path $SourceData -Recurse -Directory -Filter "*_files" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# 2. Delete loose system and web junk files
Write-Host "Removing loose junk files..." -ForegroundColor Yellow
Get-ChildItem -Path $SourceData -Recurse -File -Include *.js, *.css, *.ini, *.tmp | Remove-Item -Force -ErrorAction SilentlyContinue

# 3. Reset the "Broken" Git memory (to start fresh without the 10GB baggage)
if (Test-Path ".git") {
    Write-Host "Resetting old Git connection..." -ForegroundColor Gray
    Remove-Item -Recurse -Force .git
}

Write-Host "--- CLEANUP COMPLETE ---" -ForegroundColor Green
Write-Host "Your folder is now ready for the 10-part upload." -ForegroundColor White
Pause