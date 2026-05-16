const POLLINATIONS_BASE_URL = "https://image.pollinations.ai/prompt";

export function validatePromptOnlyPayload(payload) {
  if (!payload || typeof payload.prompt !== "string" || payload.prompt.trim() === "") {
    throw new Error("prompt is required");
  }

  if (payload.imagePath || payload.imageUrl || payload.image || payload.file) {
    throw new Error("Pollinations extension is prompt-only and does not accept photo inputs");
  }
}

export function buildPollinationsPromptUrl(prompt) {
  return `${POLLINATIONS_BASE_URL}/${encodeURIComponent(prompt)}`;
}

export async function generatePollinationsImage(payload, fetchImpl = fetch) {
  validatePromptOnlyPayload(payload);

  const url = buildPollinationsPromptUrl(payload.prompt.trim());
  const response = await fetchImpl(url, { method: "GET" });
  if (!response.ok) {
    throw new Error(`pollinations request failed: ${response.status}`);
  }
  const arrayBuffer = await response.arrayBuffer();
  return {
    provider: "pollinations",
    model: "pollinations",
    prompt: payload.prompt.trim(),
    contentType: response.headers.get("content-type") || "image/jpeg",
    bytes: Buffer.from(arrayBuffer),
    sourceUrl: url,
  };
}
