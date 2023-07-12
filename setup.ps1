# Set the remote repository URL and folders to monitor for changes
$foldersToMonitor = @(
    "folder1",
    "folder2",
    "folder3"
)

# Get the script's directory path
$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get the latest commit hash of the remote "master" branch
$remoteCommitHash = git -C $scriptDirectory ls-remote origin "refs/heads/master" | ForEach-Object { $_.Split()[0] }

# Check if there are changes in the remote "master" branch for the specified folders
$hasRemoteChanges = $false
foreach ($folder in $foldersToMonitor) {
    $localCommitHash = git -C (Join-Path $scriptDirectory $folder) rev-parse master
    if ($localCommitHash -ne $remoteCommitHash) {
        Write-Host "There are changes in remote 'master' branch for folder '$folder'."
        $hasRemoteChanges = $true
    }
}

# If there are remote changes, urge a pull first
if ($hasRemoteChanges) {
    Write-Host "Please pull the latest changes before continuing."
    return
}

# Check for conflicting changes
$hasConflictingChanges = $false
foreach ($folder in $foldersToMonitor) {
    $pullStatus = git -C (Join-Path $scriptDirectory $folder) pull --dry-run
    if ($pullStatus -like "*CONFLICT*") {
        Write-Host "There are conflicting changes in remote 'master' branch for folder '$folder'."
        $hasConflictingChanges = $true
    }
}

# If there are conflicting changes, warn and abort
if ($hasConflictingChanges) {
    Write-Host "There are conflicting changes. Please resolve conflicts before continuing."
    return
}

# If no remote changes or conflicting changes, proceed with the rest of the script
Write-Host "No remote changes or conflicting changes found. Continuing..."
# Rest of your script goes here
