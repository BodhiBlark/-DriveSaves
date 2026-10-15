# Bodhiblark Saves - servidor local simples
# Mostra o index.html em http://localhost:8080/ (o login do Google nao funciona abrindo o arquivo direto).
# Este arquivo e salvo em UTF-8 com BOM para o PowerShell do Windows mostrar os acentos corretamente.
$ErrorActionPreference = 'Stop'
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$porta = 8080
$pasta = Split-Path -Parent $MyInvocation.MyCommand.Path
$arquivo = Join-Path $pasta "index.html"

if (-not (Test-Path -LiteralPath $arquivo)) {
    Write-Host "Não achei o index.html nesta pasta: $pasta" -ForegroundColor Red
    Write-Host "Deixe o index.html, o servidor.ps1 e o iniciar.bat juntos."
    exit 1
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$porta/")
try {
    $listener.Start()
} catch {
    Write-Host "Não consegui abrir a porta $porta." -ForegroundColor Red
    Write-Host "O programa provavelmente já está aberto em outra janela, ou outro programa usa essa porta."
    Write-Host "Feche a outra janela e tente de novo."
    exit 1
}

$url = "http://localhost:$porta/"
Write-Host "Bodhiblark Saves rodando em $url"
Write-Host "Deixe esta janela aberta enquanto usa o programa. Feche para parar."

# Prefere o Chrome ou o Edge, porque só eles deixam escolher pastas. Se não achar, usa o navegador padrão.
$aberto = $false
$candidatos = @(
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
    "$env:LocalAppData\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
    "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
)
foreach ($exe in $candidatos) {
    if ($exe -and (Test-Path -LiteralPath $exe)) {
        try { Start-Process -FilePath $exe -ArgumentList $url; $aberto = $true; break } catch { }
    }
}
if (-not $aberto) {
    try { Start-Process $url } catch { Write-Host "Abra no Chrome ou no Edge: $url" }
}

$ErrorActionPreference = 'Continue'
while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    try {
        $caminho = $ctx.Request.Url.AbsolutePath
        $resp = $ctx.Response
        $resp.Headers.Add("Cache-Control", "no-store")
        $resp.Headers.Add("X-Content-Type-Options", "nosniff")
        if ($caminho -eq "/" -or $caminho -eq "/index.html") {
            $bytes = [System.IO.File]::ReadAllBytes($arquivo)
            $resp.ContentType = "text/html; charset=utf-8"
            $resp.ContentLength64 = $bytes.Length
            if ($ctx.Request.HttpMethod -ne "HEAD") { $resp.OutputStream.Write($bytes, 0, $bytes.Length) }
        } elseif ($caminho -eq "/favicon.ico") {
            $resp.StatusCode = 204
        } else {
            $resp.StatusCode = 404
        }
    } catch {
        # conexão fechada no meio: ignora
    } finally {
        try { $ctx.Response.Close() } catch { }
    }
}
