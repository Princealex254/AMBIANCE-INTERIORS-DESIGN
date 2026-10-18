# ============================================================
#  LOCAL PREVIEW SERVER - Ambiance Interiors website
#  Do not run this file directly. Double-click instead:
#      "Start Website Preview.bat"
#
#  WHY THIS EXISTS
#  The site uses clean URLs such as /contact/ and /about/.
#  Those only work when the pages are served by a web server.
#  Opening index.html directly from your computer (file://)
#  makes /contact/ point at a folder, so the browser shows a
#  file listing instead of the Contact page.
#  This tiny server reproduces real hosting locally, so what
#  you see here is exactly what visitors see online.
# ============================================================

param(
    [switch]$NoBrowser,
    [int]$Port = 8080
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$port = $Port

$mime = @{
    '.html'  = 'text/html; charset=utf-8'
    '.css'   = 'text/css; charset=utf-8'
    '.js'    = 'application/javascript; charset=utf-8'
    '.json'  = 'application/json; charset=utf-8'
    '.png'   = 'image/png'
    '.jpg'   = 'image/jpeg'
    '.jpeg'  = 'image/jpeg'
    '.gif'   = 'image/gif'
    '.webp'  = 'image/webp'
    '.svg'   = 'image/svg+xml'
    '.ico'   = 'image/x-icon'
    '.woff'  = 'font/woff'
    '.woff2' = 'font/woff2'
    '.txt'   = 'text/plain; charset=utf-8'
    '.xml'   = 'application/xml'
    '.pdf'   = 'application/pdf'
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Prefixes.Add("http://127.0.0.1:$port/")

try {
    $listener.Start()
}
catch {
    Write-Host ''
    Write-Host '   COULD NOT START THE PREVIEW SERVER' -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host ''
    Write-Host "   Port $port is probably already in use." -ForegroundColor Yellow
    Write-Host '   Close any other preview window, or change $port' -ForegroundColor Yellow
    Write-Host '   near the top of this file to a free port.' -ForegroundColor Yellow
    Write-Host ''
    Read-Host '   Press Enter to close'
    exit 1
}

Write-Host ''
Write-Host '   ============================================================' -ForegroundColor Cyan
Write-Host '    AMBIANCE INTERIORS  -  LOCAL WEBSITE PREVIEW' -ForegroundColor Cyan
Write-Host '   ============================================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "   Site folder : $root"
Write-Host "   Preview at  : http://localhost:$port/" -ForegroundColor Green
Write-Host ''
Write-Host '   Opening your browser automatically...' -ForegroundColor Gray
Write-Host ''
Write-Host '   HOW TO USE' -ForegroundColor Yellow
Write-Host '   * Keep this window OPEN while you browse.' -ForegroundColor Yellow
Write-Host '   * Close this window (or press Ctrl+C) to stop.' -ForegroundColor Yellow
Write-Host '   * Type a page address directly, e.g.' -ForegroundColor Yellow
Write-Host "       http://localhost:$port/contact/" -ForegroundColor DarkGray
Write-Host ''
Write-Host '   NOTE' -ForegroundColor Cyan
Write-Host '   Do not double-click the .html files to preview the site -' -ForegroundColor DarkGray
Write-Host '   links like /contact/ need a server. This window IS that server.' -ForegroundColor DarkGray
Write-Host ''
Write-Host '   ------------------------------------------------------------' -ForegroundColor DarkGray
Write-Host ''

if (-not $NoBrowser) {
    Start-Process "http://localhost:$port/"
}

while ($listener.IsListening) {
    $ctx = $null
    try { $ctx = $listener.GetContext() } catch { break }
    if ($null -eq $ctx) { continue }

    $path = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath)
    $rel = $path.TrimStart('/') -replace '/', '\'

    if ($rel -eq '') {
        $full = Join-Path $root 'index.html'
    }
    else {
        $full = Join-Path $root $rel
        if (Test-Path -LiteralPath $full -PathType Container) {
            $full = Join-Path $full 'index.html'
        }
    }

    try {
        if (Test-Path -LiteralPath $full -PathType Leaf) {
            $ext = [System.IO.Path]::GetExtension($full).ToLower()
            $type = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
            $bytes = [System.IO.File]::ReadAllBytes($full)
            $ctx.Response.StatusCode = 200
            $ctx.Response.ContentType = $type
            $ctx.Response.ContentLength64 = $bytes.Length
            $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
            Write-Host ('   {0,-4} {1}' -f 200, $path) -ForegroundColor DarkGray
        }
        else {
            $ctx.Response.StatusCode = 404
            Write-Host ('   {0,-4} {1}   <- not found' -f 404, $path) -ForegroundColor Red
        }
    }
    catch {
        Write-Host ('   ERR  {0}   (browser closed the connection)' -f $path) -ForegroundColor DarkYellow
    }

    try { $ctx.Response.Close() } catch { }
}

$listener.Stop()
$listener.Close()
