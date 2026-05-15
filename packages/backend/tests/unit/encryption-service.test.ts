import assert from "node:assert/strict";
import test from "node:test";

import { EncryptionService } from "../../src/modules/security/encryption.service.ts";

test("EncryptionService round-trips API keys with authenticated AES-GCM", () => {
  const service = new EncryptionService(new EncryptionService().generateKey());

  const encrypted = service.encryptForStorage("sk-test-secret");
  const parsed = JSON.parse(encrypted) as { encrypted: string; iv: string; tag: string };

  assert.equal(parsed.tag.length, 32);
  assert.equal(service.decryptFromStorage(encrypted), "sk-test-secret");
});

test("EncryptionService rejects tampered ciphertext or auth tags", () => {
  const service = new EncryptionService(new EncryptionService().generateKey());
  const encrypted = JSON.parse(service.encryptForStorage("sk-test-secret")) as { encrypted: string; iv: string; tag: string };

  assert.throws(
    () => service.decryptFromStorage(JSON.stringify({ ...encrypted, tag: "0".repeat(32) })),
    /Failed to decrypt data/,
  );
});
