Param(
    [int]$Count = 10,
    [string]$Date = "2026-08-07",
    [string]$Message = "Backdated commit",
    [string]$AuthorName = "",
    [string]$AuthorEmail = ""
)

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error "Git is not available in PATH. Install Git or run this from a Git-enabled shell."
    exit 1
}

$file = ".backdated_commits.txt"
if (-not (Test-Path $file)) { New-Item -Path $file -ItemType File -Force | Out-Null }

Write-Host "Creating $Count backdated commits on $Date..."

for ($i = 0; $i -lt $Count; $i++) {
    # Spread commits across seconds to avoid identical timestamps
    $time = (Get-Date "$Date 12:00:00").AddSeconds($i)
    $timestamp = $time.ToString('yyyy-MM-ddTHH:mm:ss')

    if ($AuthorName -ne "") { $env:GIT_AUTHOR_NAME = $AuthorName; $env:GIT_COMMITTER_NAME = $AuthorName }
    if ($AuthorEmail -ne "") { $env:GIT_AUTHOR_EMAIL = $AuthorEmail; $env:GIT_COMMITTER_EMAIL = $AuthorEmail }

    $env:GIT_AUTHOR_DATE = $timestamp
    $env:GIT_COMMITTER_DATE = $timestamp

    Add-Content -Path $file -Value "$timestamp - $Message #$($i+1)"
    git add $file
    git commit -m "$Message #$($i+1)"

    Remove-Item env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
    Remove-Item env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
}

# Clean up optional env vars set for author identity
if ($AuthorName -ne "") { Remove-Item env:GIT_AUTHOR_NAME -ErrorAction SilentlyContinue; Remove-Item env:GIT_COMMITTER_NAME -ErrorAction SilentlyContinue }
if ($AuthorEmail -ne "") { Remove-Item env:GIT_AUTHOR_EMAIL -ErrorAction SilentlyContinue; Remove-Item env:GIT_COMMITTER_EMAIL -ErrorAction SilentlyContinue }

Write-Host "Done. Review commits with 'git log --decorate --oneline' and push when ready."
