const fs = require("fs");
const path = require("path");
const { EdgeTTS } = require("node-edge-tts");

const root = path.resolve(__dirname, "..");
const outputDir = path.join(root, "08_AUDIO", "episode-01", "voices-th");
fs.mkdirSync(outputDir, { recursive: true });

const lines = [
  { id: "001-narrator", voice: "th-TH-PremwadeeNeural", rate: "-5%", pitch: "-3%", text: "ในโลกใบนี้ ผู้คนมักคิดว่า สิ่งที่หายไป คือสิ่งที่ไม่มีวันกลับมา" },
  { id: "002-noah", voice: "th-TH-PremwadeeNeural", rate: "+8%", pitch: "+12%", text: "บางที มันอาจแค่รอเจ้าของกลับมา" },
  { id: "003-narrator", voice: "th-TH-PremwadeeNeural", rate: "-2%", pitch: "-3%", text: "แต่โนอาห์เชื่อว่า ทุกสิ่งที่ถูกลืม ยังคงรอใครบางคนอยู่" },
  { id: "004-noah", voice: "th-TH-PremwadeeNeural", rate: "+10%", pitch: "+12%", text: "เราเคยเจอกันมาก่อนเหรอ" },
  { id: "005-memory", voice: "th-TH-PremwadeeNeural", rate: "-12%", pitch: "-12%", text: "โนอาห์" },
  { id: "006-noah", voice: "th-TH-PremwadeeNeural", rate: "+12%", pitch: "+12%", text: "ใคร" },
  { id: "007-noah", voice: "th-TH-PremwadeeNeural", rate: "+10%", pitch: "+12%", text: "เดี๋ยวนะ หายไปไหน" },
  { id: "008-narrator", voice: "th-TH-PremwadeeNeural", rate: "-3%", pitch: "-3%", text: "บางครั้ง สิ่งที่เราตามหา อาจกำลังตามหาเราอยู่เช่นกัน" },
  { id: "009-noah", voice: "th-TH-PremwadeeNeural", rate: "+10%", pitch: "+12%", text: "เสียงนาฬิกา มาจากทางนี้" },
  { id: "010-noah", voice: "th-TH-PremwadeeNeural", rate: "+8%", pitch: "+12%", text: "นี่มันคืออะไร" },
  { id: "011-door", voice: "th-TH-NiwatNeural", rate: "-12%", pitch: "-10%", text: "เจ้ามาถึงแล้ว" },
  { id: "012-narrator", voice: "th-TH-PremwadeeNeural", rate: "+2%", pitch: "-3%", text: "โนอาห์ก้าวผ่านแสงสว่าง และประตูก็ปิดลงด้านหลัง" },
  { id: "013-narrator", voice: "th-TH-PremwadeeNeural", rate: "-3%", pitch: "-3%", text: "สถานที่แห่งนี้ไม่มีอยู่ในแผนที่ เพราะนี่คือหมู่บ้านของทุกสิ่ง ที่โลกเคยลืม" },
  { id: "014-noah", voice: "th-TH-PremwadeeNeural", rate: "+10%", pitch: "+12%", text: "นี่ คือที่ไหน" },
  { id: "015-noah", voice: "th-TH-PremwadeeNeural", rate: "+10%", pitch: "+12%", text: "ประตู หายไปแล้ว" },
  { id: "016-aster", voice: "th-TH-NiwatNeural", rate: "-8%", pitch: "-8%", text: "เจ้ามาช้ากว่าที่คิด" },
  { id: "017-noah", voice: "th-TH-PremwadeeNeural", rate: "+10%", pitch: "+12%", text: "คุณเป็นใคร" },
  { id: "018-aster", voice: "th-TH-NiwatNeural", rate: "-6%", pitch: "-8%", text: "ข้าคือผู้ดูแลสถานที่แห่งนี้" },
  { id: "019-noah", voice: "th-TH-PremwadeeNeural", rate: "+12%", pitch: "+12%", text: "แล้วคุณรู้จักผมได้ยังไง" },
  { id: "020-aster", voice: "th-TH-NiwatNeural", rate: "-10%", pitch: "-9%", text: "เพราะเจ้า ไม่ใช่ผู้มาเยือน" },
  { id: "021-aster", voice: "th-TH-NiwatNeural", rate: "-10%", pitch: "-9%", text: "ยินดีต้อนรับกลับบ้าน โนอาห์" },
  { id: "022-thief", voice: "th-TH-PremwadeeNeural", rate: "-18%", pitch: "-18%", text: "ของที่ไม่มีใครเก็บ ย่อมไม่มีเจ้าของ" }
];

async function main() {
  for (const line of lines) {
    const file = path.join(outputDir, `${line.id}.mp3`);
    const tts = new EdgeTTS({
      voice: line.voice,
      lang: "th-TH",
      outputFormat: "audio-24khz-96kbitrate-mono-mp3",
      rate: line.rate,
      pitch: line.pitch,
      volume: "default",
      timeout: 30000
    });
    process.stdout.write(`Generating ${line.id}... `);
    await tts.ttsPromise(line.text, file);
    console.log("done");
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
