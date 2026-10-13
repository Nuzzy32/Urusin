// AI diagnose: foto/teks masalah rumah → analisis terstruktur via Gemini.
// Kontrak response mengikuti AiDiagnosisService (lib/services/ai_diagnosis_service.dart):
//   { analysis, summary, min_price, max_price, tips }  (+ detail untuk UI lanjutan)
// Secrets: GEMINI_API_KEY (wajib), GEMINI_MODEL (opsional).

const GEMINI_KEY = Deno.env.get("GEMINI_API_KEY");
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.8-flash";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
// Hanya ambil gambar dari bucket publik kita sendiri (cegah SSRF).
const IMAGE_PREFIX = `${SUPABASE_URL}/storage/v1/object/public/diagnoses/`;
const MAX_IMAGE_BYTES = 5 * 1024 * 1024;

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

const SYSTEM_PROMPT = `Kamu adalah Beresin AI, asisten perbaikan rumah untuk pengguna di Indonesia.
Aturan:
- Jangan mengklaim pasti. Gunakan bahasa "kemungkinan".
- Jangan beri instruksi perbaikan berbahaya (listrik, gas, alat berisiko, struktur bangunan).
- Jangan berpura-pura menjadi teknisi bersertifikat.
- Rekomendasikan jenis tukang lokal yang tepat.
- Estimasi kisaran harga jasa wajar dalam Rupiah untuk area perkotaan Indonesia (belum termasuk sparepart besar).
- Semua teks untuk user dalam Bahasa Indonesia yang ramah dan jelas.
- Jika foto/teks tidak berkaitan dengan masalah rumah, isi confidence rendah dan jelaskan di explanation.`;

const schema = {
  type: "OBJECT",
  properties: {
    problem_title: { type: "STRING" },
    category: { type: "STRING" },
    recommended_worker_type: { type: "STRING" },
    severity: { type: "STRING", enum: ["low", "medium", "high"] },
    urgency: { type: "STRING", enum: ["normal", "soon", "emergency"] },
    confidence: { type: "NUMBER" },
    likely_causes: { type: "ARRAY", items: { type: "STRING" } },
    explanation: { type: "STRING" },
    price_min: { type: "INTEGER" },
    price_max: { type: "INTEGER" },
    duration_minutes_min: { type: "INTEGER" },
    duration_minutes_max: { type: "INTEGER" },
    recommended_next_step: { type: "STRING" },
    safety_note: { type: "STRING" },
    preventive_tip: { type: "STRING" },
    whatsapp_message: { type: "STRING" },
  },
  required: [
    "problem_title", "category", "recommended_worker_type", "severity",
    "urgency", "confidence", "likely_causes", "explanation", "price_min",
    "price_max", "duration_minutes_min", "duration_minutes_max",
    "recommended_next_step", "safety_note", "preventive_tip", "whatsapp_message",
  ],
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...cors, "Content-Type": "application/json" },
  });

const str = (v: unknown, max = 1000) =>
  typeof v === "string" ? v.trim().slice(0, max) : "";

async function loadImage(url: string) {
  if (!url || !url.startsWith(IMAGE_PREFIX)) return null;
  const res = await fetch(url);
  if (!res.ok) return null;
  const mime = res.headers.get("content-type") ?? "";
  if (!mime.startsWith("image/")) return null;
  const bytes = new Uint8Array(await res.arrayBuffer());
  if (bytes.byteLength > MAX_IMAGE_BYTES) return null;
  let bin = "";
  for (let i = 0; i < bytes.length; i += 0x8000) {
    bin += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
  }
  return { mime_type: mime.split(";")[0], data: btoa(bin) };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);
  if (!GEMINI_KEY) return json({ error: "gemini_not_configured" }, 500);

  let body: Record<string, unknown>;
  try {
    body = await req.json();
  } catch {
    return json({ error: "invalid_json" }, 400);
  }

  const category = str(body.category_label, 60);
  const problem = str(body.problem, 200);
  const description = str(body.description, 2000);
  const urgency = str(body.urgency, 30);
  if (!problem && !description) return json({ error: "empty_problem" }, 400);

  const image = await loadImage(str(body.image_url, 500)).catch(() => null);

  const userText = `Kategori pilihan user: ${category || "-"}
Urgensi menurut user: ${urgency || "-"}
Masalah: ${problem || "-"}
Deskripsi: ${description || "-"}
${image ? "Foto kerusakan terlampir." : "Tidak ada foto."}`;

  const parts: unknown[] = [{ text: userText }];
  if (image) parts.push({ inline_data: image });

  const res = await fetch(
    `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent`,
    {
      method: "POST",
      headers: { "Content-Type": "application/json", "x-goog-api-key": GEMINI_KEY },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
        contents: [{ role: "user", parts }],
        generationConfig: {
          responseMimeType: "application/json",
          responseSchema: schema,
          temperature: 0.2,
        },
      }),
    },
  );
  if (!res.ok) {
    console.error("gemini_error", res.status, await res.text());
    return json({ error: "gemini_failed" }, 502);
  }

  let d: Record<string, any>;
  try {
    const out = await res.json();
    d = JSON.parse(out.candidates?.[0]?.content?.parts?.[0]?.text ?? "");
  } catch (e) {
    console.error("gemini_parse_error", e);
    return json({ error: "gemini_bad_output" }, 502);
  }

  const lo = Math.max(0, Math.round(Number(d.price_min) || 0));
  const hi = Math.max(lo, Math.round(Number(d.price_max) || 0));
  const causes = Array.isArray(d.likely_causes) ? d.likely_causes : [];

  // `analysis` = teks ringkas untuk kolom ai_analysis_result yang sudah ada.
  const analysis = [
    d.explanation,
    causes.length ? `Kemungkinan penyebab: ${causes.join("; ")}.` : "",
    d.recommended_next_step,
    `Catatan keamanan: ${d.safety_note}`,
    "Harga dapat berubah setelah pengecekan langsung.",
  ].filter(Boolean).join("\n\n");

  return json({
    analysis,
    summary: d.problem_title,
    min_price: lo,
    max_price: hi,
    tips: d.preventive_tip,
    detail: { ...d, price_min: lo, price_max: hi, model: GEMINI_MODEL },
  });
});
