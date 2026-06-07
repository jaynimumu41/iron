# IRON 鐵血訓練 — 本機伺服器
# 用法： 在此資料夾按右鍵「用 PowerShell 執行」，或： powershell -ExecutionPolicy Bypass -File server.ps1
$port = 8770
$root = $PSScriptRoot
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Host ""
Write-Host "  🔥 IRON 鐵血訓練 已啟動" -ForegroundColor Red
Write-Host "  ➜  http://localhost:$port" -ForegroundColor Yellow
Write-Host "  (按 Ctrl+C 關閉)" -ForegroundColor DarkGray
Write-Host ""
Start-Process "http://localhost:$port"
$mime = @{ ".html"="text/html; charset=utf-8"; ".js"="application/javascript"; ".css"="text/css" }
try {
  while ($listener.IsListening) {
    $ctx = $listener.GetContext()
    $path = $ctx.Request.Url.LocalPath.TrimStart("/")
    if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
    $file = Join-Path $root $path
    if (Test-Path $file -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($file)
      $ctx.Response.ContentType = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($file)
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
    }
    $ctx.Response.Close()
  }
} finally { $listener.Stop() }
