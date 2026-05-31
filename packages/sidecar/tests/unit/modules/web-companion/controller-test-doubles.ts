import type { WebCompanionController } from "../../../../src/modules/web-companion/web-companion.controller.ts";

type ControllerArgs = ConstructorParameters<typeof WebCompanionController>;

export function createUnusedWebCompanionService(): ControllerArgs[0] {
  return {
    createSession: async () => { throw new Error("unused web companion service"); },
    getSessionSummary: async () => { throw new Error("unused web companion service"); },
    getSessionDetail: async () => { throw new Error("unused web companion service"); },
    createUploadItems: async () => { throw new Error("unused web companion service"); },
    commitUploadItem: async () => { throw new Error("unused web companion service"); },
    retryUploadItem: async () => { throw new Error("unused web companion service"); },
    closeSession: async () => { throw new Error("unused web companion service"); },
  };
}

export function createUnusedBrowseService(): ControllerArgs[1] {
  return {
    getRecentUploads: async () => { throw new Error("unused browse service"); },
    getAssetDetails: async () => { throw new Error("unused browse service"); },
    getBooksList: async () => { throw new Error("unused browse service"); },
    getBookDetails: async () => { throw new Error("unused browse service"); },
    getSharedAssets: async () => { throw new Error("unused browse service"); },
    getSharedBook: async () => { throw new Error("unused browse service"); },
  };
}

export function createUnusedShareTokenService(): ControllerArgs[2] {
  return {
    createShareToken: async () => { throw new Error("unused share token service"); },
    revokeShareToken: async () => { throw new Error("unused share token service"); },
    validateShareToken: async () => { throw new Error("unused share token service"); },
  };
}
