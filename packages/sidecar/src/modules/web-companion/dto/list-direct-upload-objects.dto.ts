/**
 * Direct Upload list objects DTOs.
 */

export interface DirectUploadRemoteObject {
  objectKey: string;
  size: number;
  contentType: string;
  /** ISO 8601 timestamp. */
  lastModified: string;
}

export interface ListDirectUploadObjectsResponse {
  sessionId: string;
  bucket: string;
  objects: DirectUploadRemoteObject[];
}
