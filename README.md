# TomiSoft PowerShell Tools
Néhány PowerShell szkript

Split-Audio.ps1
---------------
Hosszabb hangfájlok, pl. mixek különálló fájlokba való darabolására.

Használati előfeltételek:
- ffprobe.exe fájlt tartalmazó könyvtár elérési útvonalának regisztrálása a PATH környezeti változóba
- ffmpeg.exe fájlt tartalmazó könyvtár elérési útvonalának regisztrálása a PATH környezeti változóba

Használat:
Kell egy szöveges fájl, ami a zenék információit tartalmazza. Ennek a felépítése:
```
sorszám;előadó;cím;kezdeti_idő(óra:perc:másodperc formátumban)
```
Példa:
```
01;Próba előadó;Próba cím;00:01:15
```

Példa:
```
Windows PowerShell
Copyright (C) 2015 Microsoft Corporation. All rights reserved.

PS C:\Zenék> Import-Module .\Split-Audio.ps1
PS C:\Zenék> $TrackInfo = Parse-AudioTrackInfo -Filename .\tracklist.txt
PS C:\Zenék> Split-Audio -Filename .\retro-mix.mp3 -AudioTrackInfo $TrackInfo
```
