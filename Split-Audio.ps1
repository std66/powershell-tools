Function Split-Audio([string] $Filename, $AudioTrackInfo) {
    $Activity = [String]::Format("Hangfájl darabolása: {0}", $Filename);
    Write-Progress -Activity $Activity -Status "Hangfájl hosszának meghatározása...";

    #Hangfájl teljes hosszának meghatározása
    $TotalLength = & ffprobe -i $Filename -show_entries format=duration -v quiet -of csv="p=0" -sexagesimal;
    
    #Sorra vesszük a zeneinformációkat tartalmazó tömböt
    for ($i = 0; $i -lt $AudioTrackInfo.Count; $i++) {
        #Állapotjelentés szövege
        $Status = [String]::Format(
            "[{0}/{1}] {2} - {3}",
            @(
                ($i + 1),
                $AudioTrackInfo.Count,
                $AudioTrackInfo[$i].Artist,
                $AudioTrackInfo[$i].Title
            )
        );

        #Folyamat százalékban kifejezve
        $Percent = $i / $AudioTrackInfo.Count * 100;

        Write-Progress -Activity $Activity -Status $Status -PercentComplete $Percent;

        #Az aktuális zeneszám végének meghatározása
        $NextTrackStart = 0;
        if ($i -lt $AudioTrackInfo.Count - 1) {
            $NextTrackStart = $AudioTrackInfo[$i + 1].StartTime;
        }
        else {
            $NextTrackStart = $TotalLength;
        }

        #A zeneszám hosszának meghatározása
        $StartTimeInSeconds = Convert-TimeToSeconds -Time $AudioTrackInfo[$i].StartTime;
        $EndTimeInSeconds = Convert-TimeToSeconds -Time $NextTrackStart;

        $LengthInSeconds = $EndTimeInSeconds - $StartTimeInSeconds;
        $Length = Convert-SecondsToTime -Seconds $LengthInSeconds;

        #Az aktuális zeneszám fájlnevének meghatározása
        $TrackFilename = [String]::Format(
            "`"{0} - {1} - {2}.mp3`"",
            $AudioTrackInfo[$i].TrackNo,
            $AudioTrackInfo[$i].Artist,
            $AudioTrackInfo[$i].Title
        );

        #Metaadatok kapcsolói
        $FFMetaData = [String]::Format(
            "-metadata title=`"{0}`" -metadata artist=`"{1}`" -metadata track=`"{2}/{3}`"",
            @(
                $AudioTrackInfo[$i].Title,
                $AudioTrackInfo[$i].Artist,
                $AudioTrackInfo[$i].TrackNo,
                $AudioTrackInfo.Count
            )
        );

        #Levágás
        & ffmpeg `
            -i $Filename `
            -ss $AudioTrackInfo[$i].StartTime `
            -t $Length $TrackFilename `
            2>&1 | Out-Null;
    }
}

Function Parse-AudioTrackInfo([string] $Filename) {
    $Result = @();

    $FileContents = Get-Content $Filename;
    foreach ($TrackData in $FileContents) {
        $Data = $TrackData.Split(';');

        $CurrentTrack = @{};
        $CurrentTrack.TrackNo = [Convert]::ToInt32($Data[0]).ToString("D2");
        $CurrentTrack.Artist = $Data[1];
        $CurrentTrack.Title = $Data[2];
        $CurrentTrack.StartTime = $Data[3];

        $Result += New-Object -TypeName PSObject -Property $CurrentTrack;
    }

    return $Result;
}

Function Convert-TimeToSeconds($Time) {
    return [TimeSpan]::Parse($Time).TotalSeconds;
}

Function Convert-SecondsToTime($Seconds) {
    return [TimeSpan]::FromSeconds($Seconds).ToString();
}
