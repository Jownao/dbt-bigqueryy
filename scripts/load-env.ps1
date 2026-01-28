<#
Load environment variables from a .env file into the current PowerShell session.

Usage:
# 1) Para carregar no shell atual (recomendado):
#    . .\scripts\load-env.ps1
#    Observe o ponto e o espaço antes do caminho (dot-source) — isso faz as vars persistirem na sessão atual.
# 2) Para carregar e executar um comando imediatamente:
#    . .\scripts\load-env.ps1 -Run "& \"E:\-Progamacoes\GithubEstudos\dbt-bigqueryy\.venv\Scripts\dbt.exe\" debug"
# 3) Para usar outro arquivo .env:
#    . .\scripts\load-env.ps1 -EnvFile ".env.dev"
#
# Segurança: não comite chaves/credenciais. Este script apenas lê e exporta variáveis para o processo.
#>
param(
    [string]$EnvFile = ".env",
    [string]$Run = ''
)

if (-not (Test-Path $EnvFile)) {
    Write-Error "Arquivo '$EnvFile' não encontrado. Saindo."
    exit 1
}

Get-Content $EnvFile | ForEach-Object {
    $line = $_.Trim()
    if ($line -and ($line -notmatch '^\s*#')) {
        if ($line -match '=') {
            $parts = $line -split '=',2
            $name = $parts[0].Trim()
            $value = $parts[1].Trim()
            if ($value -match '^"(.*)"$') { $value = $matches[1] }
            elseif ($value -match "^'(.*)'$") { $value = $matches[1] }
            Set-Item -Path "Env:$name" -Value $value
        }
    }
}

Write-Output "Variáveis carregadas de '$EnvFile' no processo atual."

if ($Run -and $Run.Trim().Length -gt 0) {
    Write-Output "Executando comando: $Run"
    Invoke-Expression $Run
}
