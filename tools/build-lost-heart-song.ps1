param(
    [string]$OutputFile = "08_AUDIO\lost-heart-song\khong-hai-jai-mai-hai-demo.mp3"
)

$ErrorActionPreference = "Stop"
$wingetRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
$ffmpeg = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source
$ffprobe = (Get-Command ffprobe -ErrorAction SilentlyContinue).Source
if (-not $ffmpeg) {
    $ffmpeg = Get-ChildItem -LiteralPath $wingetRoot -Filter ffmpeg.exe -Recurse |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $ffprobe) {
    $ffprobe = Get-ChildItem -LiteralPath $wingetRoot -Filter ffprobe.exe -Recurse |
        Select-Object -First 1 -ExpandProperty FullName
}
if (-not $ffmpeg -or -not $ffprobe) { throw "FFmpeg or FFprobe could not be found." }

$voiceDir = "08_AUDIO\lost-heart-song\vocals"
$startsMs = @(900, 7000, 11000, 15000, 19000, 23000, 27000, 31000, 35000, 39000, 43000, 48000, 52000, 56500)
$argsList = @("-hide_banner", "-y")
1..14 | ForEach-Object {
    $argsList += @("-i", (Join-Path $voiceDir ("{0:D2}.mp3" -f $_)))
}

# 140 BPM: kick on each beat, snare on beats 2/4, bright off-beat hats, and an Am-F-C-G synth bed.
$filter = @(
    "aevalsrc='0.14*sin(2*PI*55*t)*exp(-18*mod(t,60/140))+0.06*sin(2*PI*110*t)*exp(-25*mod(t,60/140))':s=48000:d=60[kick]",
    "anoisesrc=color=white:amplitude=0.16:s=48000:d=60,highpass=f=1800,lowpass=f=9000,agate=threshold=0.08:ratio=10:attack=1:release=55,tremolo=f=2.333333:d=0.92[hat]",
    "aevalsrc='0.055*(sin(2*PI*220*t)+sin(2*PI*261.63*t)+sin(2*PI*329.63*t))*if(lt(mod(t,6.857),1.714),1,if(lt(mod(t,6.857),3.428),0.82,if(lt(mod(t,6.857),5.142),0.92,0.78)))':s=48000:d=60,lowpass=f=1800,tremolo=f=4.666667:d=0.18[pad]",
    "[kick][hat][pad]amix=inputs=3:normalize=0,volume=0.72,afade=t=in:st=0:d=1,afade=t=out:st=58:d=2[beat]"
)

for ($i = 0; $i -lt 14; $i++) {
    $inputIndex = $i
    $delay = $startsMs[$i]
    $filter += "[$inputIndex`:a]atempo=1.10,highpass=f=120,volume=1.45,aecho=0.8:0.35:90:0.10,adelay=$delay|$delay[v$i]"
}
$mix = "[beat]" + ((0..13 | ForEach-Object { "[v$_]" }) -join "")
$filter += "$mix" + "amix=inputs=15:normalize=0:duration=longest,acompressor=threshold=0.15:ratio=3:attack=8:release=120,loudnorm=I=-16:LRA=9:TP=-1.5,alimiter=limit=0.92[out]"

$argsList += @(
    "-filter_complex", ($filter -join ";"),
    "-map", "[out]", "-t", "60", "-ar", "48000", "-ac", "2",
    "-c:a", "libmp3lame", "-b:a", "192k", $OutputFile
)

& $ffmpeg @argsList
if ($LASTEXITCODE -ne 0) { throw "Song mix failed." }
& $ffprobe -v error -show_entries format=duration,size,bit_rate -of json $OutputFile
