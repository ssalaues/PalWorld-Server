@echo off
set servername="PalWorld Server"
set port=8211
set players=32
set user=$Env:UserDomain + "\" + $Env:UserName
set steamcmdurl="https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"

mkdir server
cd .\server
set workdir=%cd%
mkdir steam

:: download SteamCMD
echo %workdir%
bitsadmin /transfer "SteamCMD Download" /download /priority normal %steamcmdurl% %workdir%\steamcmd.zip
tar -xf steamcmd.zip -C .\steam

:: save update/install script
set installscript=%workdir%\palworld-update-steamcmd.txt
echo @ShutdownOnfailedCommand 1 > %installscript%
echo @NoPromptForPassword 1  >> %installscript%
echo force_install_dir %workdir%\PalServer  >> %installscript%
echo login anonymous >> %installscript%
echo app_update 2394010 validate  >> %installscript%
echo quit >> %installscript%


:: install palworld
.\steam\steamcmd +runscript %installscript%

:: update/restart script
set dailyscript=%workdir%\update-server.bat
echo @echo off > %dailyscript%
echo :: script to stop the pal server service >> %dailyscript%
echo sc stop "Pal Server" >> %dailyscript%
echo %workdir%\steam\steamcmd.exe +runscript %installscript% >> %dailyscript%
echo sc start "Pal Server" >> %dailyscript%

:: startup script
set startupscript=%workdir%/start-server.bat
echo @echo off > %startupscript%
echo C:\Users\pal\server\steamapps\common\PalServer\PalServer.exe -ServerName=%servername% -port=%port%% -players=%players% -ip="" -log -nosteam -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS  > %startupscript%

:: setup scheduled task to update and restart the server
schtasks /create /sc DAILY /st 03:00 /tn "Update and Restart Pal World Server" /tr %workdir%\ /ru "palworld\pal" /rp