---
name: pwsh std
description: PowerShell coding conventions
applyTo: '**/*.ps1'
---
- Assume Powershell 7 on Windows 11.
- Prefer the `foreach ($i in 0..$n)` style for readability.
- Prefer `$null = ...` style for discarding output.
- Use `[Parameter(Mandatory)]` for required parameters.
- Prefer the ternary operator `? :`.
- Use `Write-Error` for error messages.
- For normal message output, use `'msg'` instead of `Write-Output 'msg'` for brevity.
- Use single quotes for string that doesn't require interpolation.
