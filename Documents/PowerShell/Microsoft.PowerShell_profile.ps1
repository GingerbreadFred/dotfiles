# Stub: PowerShell 7 loads its profile from Documents\PowerShell.
# The real profile lives in the XDG-style location managed by chezmoi.
. (Join-Path $env:USERPROFILE ".config\powershell\profile.ps1")
