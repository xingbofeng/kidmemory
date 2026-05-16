export type GenerateImageInput = {
  prompt: string;
  traceId?: string;
  width?: number;
  height?: number;
  seed?: number;
};

export type GenerateImageResult = {
  ok: boolean;
  provider: string;
  prompt: string;
  imageUrl?: string;
  error?: {
    code: string;
    message: string;
    recoverable: boolean;
  };
  privacyBoundary: {
    textOnly: true;
    childPhotoUpload: false;
  };
};

export interface ImageProvider {
  readonly providerName: string;
  generate(input: GenerateImageInput): Promise<GenerateImageResult>;
}
