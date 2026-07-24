const fs = require("fs");
const path = require("path");
const { EdgeTTS } = require("node-edge-tts");

const root = path.resolve(__dirname, "..");
const outputDir = path.join(root, "08_AUDIO", "lost-heart-song", "vocals");
fs.mkdirSync(outputDir, { recursive: true });

const lines = [
  ["01", "เฮ้ พร้อมไหม ไปตามหากัน"],
  ["02", "กุญแจอยู่ไหน ถุงเท้าหายไป"],
  ["03", "จดหมายของใคร ปลิวตามสายลม"],
  ["04", "เดินเข้าหมู่บ้าน เรื่องราวซ่อนอยู่"],
  ["05", "เปิดทุกประตู แล้วตามมันไป"],
  ["06", "ติ๊กต่อก ติ๊กต่อก อย่ามัวรอ"],
  ["07", "หัวใจบอก มันอยู่ไม่ไกล"],
  ["08", "ของหาย ของหาย แต่ใจไม่หาย"],
  ["09", "วิ่งไป วิ่งไป ให้ทันก่อนสาย"],
  ["10", "เก็บฝันชิ้นเล็ก กลับคืนมาใหม่"],
  ["11", "ในหมู่บ้านนี้ ไม่มีใครเดียวดาย"],
  ["12", "หาให้เจอ แล้วพากลับบ้าน"],
  ["13", "ทุกสิ่งที่หาย ยังมีความหมาย"],
  ["14", "ของหาย แต่ใจไม่หาย"]
];

async function main() {
  for (const [id, text] of lines) {
    const file = path.join(outputDir, `${id}.mp3`);
    const tts = new EdgeTTS({
      voice: "th-TH-PremwadeeNeural",
      lang: "th-TH",
      outputFormat: "audio-24khz-96kbitrate-mono-mp3",
      rate: "+18%",
      pitch: "+12%",
      volume: "+8%",
      timeout: 30000
    });
    process.stdout.write(`Generating vocal ${id}... `);
    await tts.ttsPromise(text, file);
    console.log("done");
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
