export interface paths {
    "/health": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Health check endpoint */
        get: operations["HealthController_getHealth"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/health/ready": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Readiness check endpoint */
        get: operations["HealthController_getReadiness"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/config/status": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get configuration status */
        get: operations["ConfigController_getStatus"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/devices/register": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        get?: never;
        put?: never;
        /** Register a device (idempotent by machineId) */
        post: operations["DevicesController_register"];
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/devices/{id}/heartbeat": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        get?: never;
        /** Update device heartbeat */
        put: operations["DevicesController_heartbeat"];
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/devices/{id}": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        /** Get device by ID */
        get: operations["DevicesController_getDevice"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/upload-items/pending-sync": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get pending sync upload items */
        get: operations["UploadItemsController_getPendingSync"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/upload-items/{id}/sync-status": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        get?: never;
        /** Update upload item sync status */
        put: operations["UploadItemsController_updateSyncStatus"];
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/jobs/pending": {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        /** Get pending jobs for device */
        get: operations["JobsController_getPendingJobs"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/jobs/{id}/status": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        get?: never;
        /** Update job status */
        put: operations["JobsController_updateStatus"];
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/web-companion/direct-upload/sessions/{sessionId}/config": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
            };
            cookie?: never;
        };
        /** Get direct upload config for trusted upload session */
        get: operations["WebCompanionController_getDirectUploadConfig"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/web-companion/sessions/{sessionId}": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
            };
            cookie?: never;
        };
        /** Get trusted upload session summary */
        get: operations["WebCompanionController_getSessionSummary"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/web-companion/sessions/{sessionId}/items": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
            };
            cookie?: never;
        };
        get?: never;
        put?: never;
        /** Create upload items for trusted upload session */
        post: operations["WebCompanionController_createUploadItems"];
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/web-companion/sessions/{sessionId}/items/{uploadItemId}/commit": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
                uploadItemId: string;
            };
            cookie?: never;
        };
        get?: never;
        /** Commit upload item */
        put: operations["WebCompanionController_commitUploadItem"];
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/web-companion/share/{shareToken}/access": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                shareToken: string;
            };
            cookie?: never;
        };
        /** Validate public share token */
        get: operations["WebCompanionController_validateShareToken"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/web-companion/share/{shareToken}/assets": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                shareToken: string;
            };
            cookie?: never;
        };
        /** Get public shared assets */
        get: operations["WebCompanionController_getSharedAssets"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
    "/api/web-companion/share/{shareToken}/book": {
        parameters: {
            query?: never;
            header?: never;
            path: {
                shareToken: string;
            };
            cookie?: never;
        };
        /** Get public shared book metadata */
        get: operations["WebCompanionController_getSharedBook"];
        put?: never;
        post?: never;
        delete?: never;
        options?: never;
        head?: never;
        patch?: never;
        trace?: never;
    };
}
export type webhooks = Record<string, never>;
export interface components {
    schemas: Record<string, any>;
    responses: Record<string, unknown>;
    parameters: Record<string, unknown>;
    requestBodies: Record<string, unknown>;
    headers: Record<string, unknown>;
    pathItems: Record<string, unknown>;
}
export type $defs = Record<string, never>;
export interface operations {
    HealthController_getHealth: {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Service is healthy */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    HealthController_getReadiness: {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Service is ready */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    ConfigController_getStatus: {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Configuration status */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    DevicesController_register: {
        parameters: {
            query?: never;
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Device registered successfully */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Invalid request */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    DevicesController_heartbeat: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Heartbeat updated */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Device not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    DevicesController_getDevice: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Device found */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Device not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    UploadItemsController_getPendingSync: {
        parameters: {
            query?: {
                /** @description Number of items to skip */
                offset?: number;
                /** @description Maximum items to return */
                limit?: number;
                /** @description Filter by device ID */
                deviceId?: unknown;
            };
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Pending items retrieved */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    UploadItemsController_updateSyncStatus: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Status updated */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Invalid status transition */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Item not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    JobsController_getPendingJobs: {
        parameters: {
            query?: {
                /** @description Maximum jobs to return */
                limit?: number;
                /** @description Filter by device ID (null = unassigned) */
                deviceId?: unknown;
            };
            header?: never;
            path?: never;
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Pending jobs retrieved */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    JobsController_updateStatus: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                id: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            /** @description Status updated */
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Invalid status transition */
            400: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
            /** @description Job not found */
            404: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    WebCompanionController_getDirectUploadConfig: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    WebCompanionController_getSessionSummary: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    WebCompanionController_createUploadItems: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
            };
            cookie?: never;
        };
        requestBody: {
            content: {
                "application/json": components["schemas"]["CreateUploadItemsRequestDto"];
            };
        };
        responses: {
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    WebCompanionController_commitUploadItem: {
        parameters: {
            query?: never;
            header?: never;
            path: {
                sessionId: string;
                uploadItemId: string;
            };
            cookie?: never;
        };
        requestBody: {
            content: {
                "application/json": components["schemas"]["CommitUploadItemRequestDto"];
            };
        };
        responses: {
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    WebCompanionController_validateShareToken: {
        parameters: {
            query?: {
                userAgent?: unknown;
                clientIp?: unknown;
            };
            header?: never;
            path: {
                shareToken: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    WebCompanionController_getSharedAssets: {
        parameters: {
            query?: {
                limit?: number;
            };
            header?: never;
            path: {
                shareToken: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
    WebCompanionController_getSharedBook: {
        parameters: {
            query?: {
                bookId?: string;
            };
            header?: never;
            path: {
                shareToken: string;
            };
            cookie?: never;
        };
        requestBody?: never;
        responses: {
            200: {
                headers: {
                    [name: string]: unknown;
                };
                content?: never;
            };
        };
    };
}
