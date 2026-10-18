@echo off
REM ============================================================
REM  AMBIANCE INTERIORS - LOCAL WEBSITE PREVIEW
REM  Double-click this file to preview the site in your browser.
REM  A black window will stay open - that is the preview server.
REM  Close that black window when you are done browsing.
REM ============================================================
title Ambiance Interiors - Local Website Preview
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0_preview-server.ps1"
echo.
echo Preview server stopped.
pause
