/**
 * Direct Upload list objects DTOs.
 */

export interface DirectUploadRemoteObject {
  objectKey: string;
  size?: number;
  updatedAt?: string;
  contentType?: string;
}

export interface ListDirectUploadObjectsResponse {
  sessionId: string;
  bucket: string;
  objects: DirectUploadRemoteObject[];
}
