# Build images

# Get Start Time
$startDTM = (Get-Date)

# Variables
$template_file = "./templates/hv_ubuntu2204_g2.pkr.hcl"
$var_file = "C:\git\packer-vars\variables\packer-hyperv\variables_ubuntu2204.pkvars.hcl"
$machine = "Ubuntu 22.04 Gen-2"
$packer_log = 1
$packer_log_path = "packer_log_hv_ubuntu2204_g2.txt"

if ((Test-Path -Path "$template_file") -and (Test-Path -Path "$var_file")) {
  Write-Output "Template and var file found"
  Write-Output "Building: $machine"
  try {
    $env:PACKER_LOG=$packer_log
    $env:PACKER_LOG_PATH=$packer_log_path
    packer validate -var-file="$var_file" "$template_file"
  }
  catch {
    Write-Output "Packer validation failed, exiting."
    exit (-1)
  }
  try {
    $env:PACKER_LOG=$packer_log
    $env:PACKER_LOG_PATH=$packer_log_path
    packer version
    packer build --force -var-file="$var_file" "$template_file"
  }
  catch {
    Write-Output "Packer build failed, exiting."
    exit (-1)
  }
}
else {
  Write-Output "Template or var file not found - exiting"
  exit (-1)
}

$endDTM = (Get-Date)
Write-Host "[INFO]  - Elapsed Time: $(($endDTM-$startDTM).totalseconds) seconds" -ForegroundColor Yellow
