import crypto from 'node:crypto';

export interface EncryptionResult {
  encrypted: string;
  iv: string;
  tag: string;
}

export interface DecryptionInput {
  encrypted: string;
  iv: string;
  tag: string;
}

export class EncryptionService {
  private readonly algorithm = 'aes-256-gcm';
  private readonly keyLength = 32; // 256 bits
  private readonly ivLength = 12; // 96 bits for GCM
  private readonly tagLength = 16; // 128 bits

  private encryptionKey: Buffer | null = null;

  constructor(encryptionKey?: string) {
    if (encryptionKey) {
      this.setEncryptionKey(encryptionKey);
    }
  }

  /**
   * Set the encryption key from a hex string or base64 string
   */
  setEncryptionKey(key: string): void {
    try {
      // Try to parse as hex first
      if (key.length === this.keyLength * 2 && /^[0-9a-fA-F]+$/.test(key)) {
        this.encryptionKey = Buffer.from(key, 'hex');
      } else {
        // Try as base64
        this.encryptionKey = Buffer.from(key, 'base64');
      }

      if (this.encryptionKey.length !== this.keyLength) {
        throw new Error(`Encryption key must be ${this.keyLength} bytes (${this.keyLength * 2} hex chars or ${Math.ceil(this.keyLength * 4 / 3)} base64 chars)`);
      }
    } catch (error) {
      throw new Error(`Invalid encryption key format: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Generate a new random encryption key
   */
  generateKey(): string {
    return crypto.randomBytes(this.keyLength).toString('hex');
  }

  /**
   * Encrypt a plaintext string using AES-256-GCM
   */
  encrypt(plaintext: string): EncryptionResult {
    if (!this.encryptionKey) {
      throw new Error('Encryption key not set. Cannot perform encryption operations.');
    }

    const iv = crypto.randomBytes(this.ivLength);
    const cipher = crypto.createCipheriv(this.algorithm, this.encryptionKey, iv, {
      authTagLength: this.tagLength,
    });

    let encrypted = cipher.update(plaintext, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    const tag = cipher.getAuthTag();

    return {
      encrypted,
      iv: iv.toString('hex'),
      tag: tag.toString('hex')
    };
  }

  /**
   * Decrypt an encrypted string using AES-256-GCM
   */
  decrypt(input: DecryptionInput): string {
    if (!this.encryptionKey) {
      throw new Error('Encryption key not set. Cannot perform decryption operations.');
    }

    const iv = Buffer.from(input.iv, 'hex');
    const decipher = crypto.createDecipheriv(this.algorithm, this.encryptionKey, iv, {
      authTagLength: this.tagLength,
    });
    decipher.setAuthTag(Buffer.from(input.tag, 'hex'));

    let decrypted = decipher.update(input.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  }

  /**
   * Encrypt and encode as a single string for database storage
   */
  encryptForStorage(plaintext: string): string {
    const result = this.encrypt(plaintext);
    return JSON.stringify(result);
  }

  /**
   * Decrypt from database storage format
   */
  decryptFromStorage(encryptedData: string): string {
    try {
      const parsed = JSON.parse(encryptedData) as DecryptionInput;
      return this.decrypt(parsed);
    } catch (error) {
      throw new Error(`Failed to decrypt data: ${error instanceof Error ? error.message : 'Unknown error'}`);
    }
  }

  /**
   * Check if encryption is available (key is set)
   */
  isEncryptionAvailable(): boolean {
    return this.encryptionKey !== null;
  }

  /**
   * Securely clear the encryption key from memory
   */
  clearKey(): void {
    if (this.encryptionKey) {
      this.encryptionKey.fill(0);
      this.encryptionKey = null;
    }
  }
}
