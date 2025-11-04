# Configuration
$imagesFolder = "images"
$excessFolder = "excesses"
$maxImages = 1050

# Create excesses folder if it doesn't exist
if (!(Test-Path $excessFolder)) {
    New-Item -ItemType Directory -Path $excessFolder | Out-Null
}

# Get all subfolders in images/
$classFolders = Get-ChildItem -Path $imagesFolder -Directory

foreach ($folder in $classFolders) {
    $className = $folder.Name
    # Fixed: Get images properly
    $images = Get-ChildItem -Path $folder.FullName -File | Where-Object {$_.Extension -match '\.(jpg|jpeg|png|bmp|webp|tiff)$'}
    
    $totalImages = $images.Count
    
    if ($totalImages -gt $maxImages) {
        Write-Host ""
        Write-Host "Processing $className ($totalImages images)..." -ForegroundColor Cyan
        
        # Create excess folder for this class
        $excessClassFolder = Join-Path $excessFolder $className
        if (!(Test-Path $excessClassFolder)) {
            New-Item -ItemType Directory -Path $excessClassFolder | Out-Null
        }
        
        # Randomly shuffle images
        $shuffledImages = $images | Get-Random -Count $images.Count
        
        # Keep first 1050, move the rest
        $toMove = $shuffledImages | Select-Object -Skip $maxImages
        
        # Move excess images
        $movedCount = 0
        foreach ($img in $toMove) {
            Move-Item -Path $img.FullName -Destination $excessClassFolder
            $movedCount++
        }
        
        Write-Host "  Kept $maxImages images, moved $movedCount to excesses/$className/" -ForegroundColor Green
    }
    else {
        Write-Host ""
        Write-Host "$className has $totalImages images (no action needed)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "============================================================" -ForegroundColor Green
Write-Host "Done! All folders now have max $maxImages images" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green