param(
    [string]$InputVideo = "09_EXPORT\episode-01\episode-01-animatic-v1.mp4",
    [string]$OutputVideo = "09_EXPORT\episode-01\episode-01-animatic-v2-sound.mp4"
)

$ErrorActionPreference = "Stop"

$ffmpeg = (Get-Command ffmpeg -ErrorAction SilentlyContinue).Source
$ffprobe = (Get-Command ffprobe -ErrorAction SilentlyContinue).Source

if (-not $ffmpeg -or -not $ffprobe) {
    $wingetRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
    $ffmpeg = Get-ChildItem -LiteralPath $wingetRoot -Filter ffmpeg.exe -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
    $ffprobe = Get-ChildItem -LiteralPath $wingetRoot -Filter ffprobe.exe -Recurse -ErrorAction SilentlyContinue |
        Select-Object -First 1 -ExpandProperty FullName
}

if (-not $ffmpeg -or -not $ffprobe) {
    throw "FFmpeg or FFprobe could not be found."
}

$filter = @"
aevalsrc='0.038*sin(2*PI*(220+8*sin(2*PI*0.035*t))*t)+0.025*sin(2*PI*329.63*t)+0.018*sin(2*PI*440*t)':s=48000:d=96[bed];
anoisesrc=color=pink:amplitude=0.010:s=48000:d=96,lowpass=f=1200,highpass=f=120[air];
sine=f=1250:r=48000:d=0.055,afade=t=out:st=0:d=0.055,adelay=24500|24500[t1];
sine=f=1250:r=48000:d=0.055,afade=t=out:st=0:d=0.055,adelay=25250|25250[t2];
sine=f=1250:r=48000:d=0.055,afade=t=out:st=0:d=0.055,adelay=26000|26000[t3];
sine=f=1250:r=48000:d=0.055,afade=t=out:st=0:d=0.055,adelay=33700|33700[t4];
sine=f=1250:r=48000:d=0.055,afade=t=out:st=0:d=0.055,adelay=35000|35000[t5];
sine=f=1250:r=48000:d=0.055,afade=t=out:st=0:d=0.055,adelay=36300|36300[t6];
sine=f=92:r=48000:d=2.8,volume=0.15,afade=t=in:st=0:d=1.2,afade=t=out:st=1.7:d=1.1,adelay=20500|20500[rift1];
sine=f=660:r=48000:d=3.2,volume=0.08,tremolo=f=5:d=0.65,afade=t=in:st=0:d=1,afade=t=out:st=2.2:d=1,adelay=49000|49000[doorlight];
sine=f=110:r=48000:d=4.5,volume=0.11,afade=t=in:st=0:d=2.5,afade=t=out:st=3.3:d=1.2,adelay=56000|56000[portal];
anoisesrc=color=brown:amplitude=0.14:s=48000:d=0.45,lowpass=f=300,afade=t=out:st=0.05:d=0.4,adelay=63500|63500[slam];
sine=f=523.25:r=48000:d=1.8,volume=0.08,afade=t=out:st=0.4:d=1.4,adelay=66000|66000[chime1];
sine=f=659.25:r=48000:d=1.8,volume=0.07,afade=t=out:st=0.4:d=1.4,adelay=66800|66800[chime2];
sine=f=78:r=48000:d=3.8,volume=0.16,tremolo=f=7:d=0.8,afade=t=in:st=0:d=1.4,afade=t=out:st=2.7:d=1.1,adelay=92000|92000[rift2];
sine=f=1250:r=48000:d=0.07,afade=t=out:st=0:d=0.07,adelay=94400|94400[t7];
sine=f=1250:r=48000:d=0.07,afade=t=out:st=0:d=0.07,adelay=95200|95200[t8];
[bed][air][t1][t2][t3][t4][t5][t6][rift1][doorlight][portal][slam][chime1][chime2][rift2][t7][t8]amix=inputs=17:normalize=0,alimiter=limit=0.82,afade=t=in:st=0:d=1.5,afade=t=out:st=94:d=2[aout]
"@

& $ffmpeg -hide_banner -y `
    -i $InputVideo `
    -filter_complex $filter `
    -map 0:v:0 -map "[aout]" `
    -c:v copy -c:a aac -b:a 192k -ar 48000 -ac 2 `
    -movflags +faststart `
    -shortest $OutputVideo

if ($LASTEXITCODE -ne 0) {
    throw "FFmpeg build failed with exit code $LASTEXITCODE"
}

& $ffmpeg -hide_banner -v error -i $OutputVideo -f null NUL
if ($LASTEXITCODE -ne 0) {
    throw "Output verification failed with exit code $LASTEXITCODE"
}

& $ffprobe -v error -show_entries format=duration,size -show_entries stream=index,codec_name,codec_type,width,height,r_frame_rate,sample_rate,channels -of json $OutputVideo
