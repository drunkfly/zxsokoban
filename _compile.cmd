@echo off

cd %~dp0
if errorlevel 1 exit /B 1

tools\sjasmplus\sjasmplus --sld=game.sld --syntax=af --lst=game.lst --dirbol --fullpath game.asm
if errorlevel 1 exit /B 1
