# Prompt the user to enter the directory path
$currentDir = Read-Host "Please enter the path to the directory"

# Remove quotes if user entered them, and normalize backslashes
$currentDir = $currentDir.Trim('"').Replace('\\', '\')

# Check if the directory exists
if (!(Test-Path $currentDir)) {
    Write-Host "The specified directory does not exist. Please check the path and try again."
    exit
}

# Define directories based on user-input path
$landscapeDir = Join-Path $currentDir "Landscape"
$portraitDir = Join-Path $currentDir "Portrait"
$squareDir = Join-Path $currentDir "Square"

# Create directories based on the user-input path
foreach ($dir in @($landscapeDir, $portraitDir, $squareDir)) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Created directory: $dir"
    }
}

# Get all image files in the user-input directory, excluding Portrait, Landscape, and Square directories anywhere in the tree
$images = Get-ChildItem -Path $currentDir -Recurse | 
          Where-Object {
              $_.Extension -match '\.(jpg|jpeg|png|gif)$' -and
              $_.FullName -notlike "$landscapeDir*" -and
              $_.FullName -notlike "$portraitDir*" -and
              $_.FullName -notlike "$squareDir*"
          }

Write-Host "Found $($images.Count) image files"

foreach ($image in $images) {
    try {
        if ($image.Extension -eq ".webp") {
            # Use Magick.NET to process WebP images
            $img = New-Object ImageMagick.MagickImage($image.FullName)
        } else {
            # For other formats, use System.Drawing
            $img = [System.Drawing.Image]::FromFile($image.FullName)
        }

        $width = $img.Width
        $height = $img.Height
        $img.Dispose()

        Write-Host "Processing image: $($image.Name) (${width}x${height})"

        # Determine orientation and move file
        if ($width -gt $height) {
            Move-Item -LiteralPath $image.FullName -Destination $landscapeDir -Force
            Write-Host "Moved $($image.Name) to Landscape directory"
        } elseif ($width -lt $height) {
            Move-Item -LiteralPath $image.FullName -Destination $portraitDir -Force
            Write-Host "Moved $($image.Name) to Portrait directory"
        } else {
            Move-Item -LiteralPath $image.FullName -Destination $squareDir -Force
            Write-Host "Moved $($image.Name) to Square directory"
        }
    }
    catch {
        Write-Error "Error processing image $($image.Name): $_"
    }
}

Write-Host "Image sorting complete."



# # Enable verbose logging
# # $ErrorActionPreference = 'Continue'

# # Define the Magick.NET DLL name and the package
# # $packageName = "Magick.NET-Q8-AnyCPU"
# # $magickNetDllName = "Magick.NET-Q8-AnyCPU.dll"

# # Use where.exe to search for the Magick.NET DLL in the PATH
# # $magickNetDllPath = where.exe $magickNetDllName

# # if (-not $magickNetDllPath) {
# #     Write-Host "Magick.NET is not installed or not in the system PATH. Installing now..."
# #     Install-Package -Name $packageName -Source nuget.org -Force
# # 
# #     # Use where.exe again after installation to locate the DLL
# #     $magickNetDllPath = where.exe $magickNetDllName
# # 
# #     if (-not $magickNetDllPath) {
# #         Write-Host "Unable to find Magick.NET DLL after installation."
# #         exit
# #     }
# # }

# # Write-Host "Magick.NET found at: $magickNetDllPath"

# # Load the Magick.NET assembly for WebP support
# # Add-Type -Path $magickNetDllPath

# # Prompt the user to enter the directory path
# $currentDir = Read-Host "Please enter the path to the directory"

# # Remove quotes if user entered them, and normalize backslashes
# $currentDir = $currentDir.Trim('"').Replace('\\', '\')

# # Check if the directory exists
# if (!(Test-Path $currentDir)) {
#     Write-Host "The specified directory does not exist. Please check the path and try again."
#     exit
# }

# # Define directories based on user-input path
# $landscapeDir = Join-Path $currentDir "Landscape"
# $portraitDir = Join-Path $currentDir "Portrait"
# $squareDir = Join-Path $currentDir "Square"

# # Create directories based on the user-input path
# foreach ($dir in @($landscapeDir, $portraitDir, $squareDir)) {
#     if (!(Test-Path $dir)) {
#         New-Item -ItemType Directory -Path $dir | Out-Null
#         Write-Host "Created directory: $dir"
#     }
# }

# # Get all image files in the user-input directory, excluding Portrait, Landscape, and Square directories anywhere in the tree
# $images = Get-ChildItem -Path $currentDir -Recurse | 
#           Where-Object {
#               $_.Extension -match '\.(jpg|jpeg|png|gif)$' -and
#               $_.FullName -notlike "$landscapeDir*" -and
#               $_.FullName -notlike "$portraitDir*" -and
#               $_.FullName -notlike "$squareDir*"
#           }

# Write-Host "Found $($images.Count) image files"

# foreach ($image in $images) {
#     try {
#         if ($image.Extension -eq ".webp") {
#             # Use Magick.NET to process WebP images
#             $img = New-Object ImageMagick.MagickImage($image.FullName)
#         } else {
#             # For other formats, use System.Drawing
#             $img = [System.Drawing.Image]::FromFile($image.FullName)
#         }

#         $width = $img.Width
#         $height = $img.Height
#         $img.Dispose()

#         Write-Host "Processing image: $($image.Name) (${width}x${height})"

#         # Determine orientation and move file
#         if ($width -gt $height) {
#             Move-Item -Path $image.FullName -Destination $landscapeDir -Force
#             Write-Host "Moved $($image.Name) to Landscape directory"
#         } elseif ($width -lt $height) {
#             Move-Item -Path $image.FullName -Destination $portraitDir -Force
#             Write-Host "Moved $($image.Name) to Portrait directory"
#         } else {
#             Move-Item -Path $image.FullName -Destination $squareDir -Force
#             Write-Host "Moved $($image.Name) to Square directory"
#         }
#     }
#     catch {
#         Write-Error "Error processing image $($image.Name): $_"
#     }
# }

# Write-Host "Image sorting complete."
