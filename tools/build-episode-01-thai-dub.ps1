param(
    [string]$InputVideo = "09_EXPORT\episode-01\episode-01-animatic-v2-sound.mp4",
    [string]$OutputVideo = "09_EXPORT\episode-01\episode-01-animatic-v3-thai-dub.mp4"
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

$voiceDir = "08_AUDIO\episode-01\voices-th"
$voiceFiles = @(
    "001-narrator.mp3", "002-noah.mp3", "003-narrator.mp3", "004-noah.mp3",
    "005-memory.mp3", "006-noah.mp3", "007-noah.mp3", "008-narrator.mp3",
    "009-noah.mp3", "010-noah.mp3", "011-door.mp3", "012-narrator.mp3",
    "013-narrator.mp3", "014-noah.mp3", "015-noah.mp3", "016-aster.mp3",
    "017-noah.mp3", "018-aster.mp3", "019-noah.mp3", "020-aster.mp3",
    "021-aster.mp3", "022-thief.mp3"
)

$startsMs = @(
    500, 8000, 11500, 16000, 18400, 20600, 25000, 32200, 37000, 44500,
    48000, 56000, 64500, 71500, 75500, 80000, 82000, 83700, 86400,
    88600, 90300, 93000
)

$arguments = @("-hide_banner", "-y", "-i", $InputVideo)
foreach ($file in $voiceFiles) {
    $arguments += @("-i", (Join-Path $voiceDir $file))
}

$filters = @("[0:a]volume=0.40[bg]")
for ($i = 0; $i -lt $voiceFiles.Count; $i++) {
    $inputIndex = $i + 1
    $delay = $startsMs[$i]
    $label = "v$inputIndex"
    if ($i -eq 21) {
        $filters += "[$inputIndex`:a]atempo=1.35,highpass=f=170,volume=1.12,aecho=0.8:0.45:55:0.18,adelay=$delay|$delay[$label]"
    } elseif ($i -eq 4 -or $i -eq 10) {
        $filters += "[$inputIndex`:a]atempo=1.12,volume=1.05,aecho=0.8:0.3:45:0.10,adelay=$delay|$delay[$label]"
    } else {
        $filters += "[$inputIndex`:a]atempo=1.12,volume=1.18,adelay=$delay|$delay[$label]"
    }
}

$mixInputs = "[bg]" + ((1..$voiceFiles.Count | ForEach-Object { "[v$_]" }) -join "")
$filters += "$mixInputs" + "amix=inputs=23:normalize=0:duration=first,acompressor=threshold=0.12:ratio=2.5:attack=15:release=180,alimiter=limit=0.90[aout]"
$arguments += @(
    "-filter_complex", ($filters -join ";"),
    "-map", "0:v:0", "-map", "[aout]",
    "-c:v", "copy", "-c:a", "aac", "-b:a", "224k", "-ar", "48000", "-ac", "2",
    "-movflags", "+faststart", "-shortest", $OutputVideo
)

& $ffmpeg @arguments
if ($LASTEXITCODE -ne 0) { throw "Thai dub mix failed." }

& $ffmpeg -hide_banner -v error -i $OutputVideo -f null NUL
if ($LASTEXITCODE -ne 0) { throw "Output verification failed." }

& $ffprobe -v error `
    -show_entries format=duration,size `
    -show_entries stream=index,codec_name,codec_type,width,height,r_frame_rate,sample_rate,channels `
    -of json $OutputVideo
