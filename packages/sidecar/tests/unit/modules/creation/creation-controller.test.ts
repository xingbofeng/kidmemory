import "reflect-metadata";

import assert from "node:assert/strict";
import { test } from "node:test";

import { CreationController } from "../../../../src/modules/creation/creation.controller.ts";

test("creation controller class should be defined", () => {
  assert.ok(CreationController, "CreationController class should be importable");
  assert.equal(typeof CreationController.prototype.createTask, "function", "createTask method should exist");
  assert.equal(typeof CreationController.prototype.generateTask, "function", "generateTask method should exist");
  assert.equal(typeof CreationController.prototype.getTask, "function", "getTask method should exist");
  assert.equal(typeof CreationController.prototype.getEvents, "function", "getEvents method should exist");
  assert.equal(typeof CreationController.prototype.preview, "function", "preview method should exist");
  assert.equal(typeof CreationController.prototype.exportTask, "function", "exportTask method should exist");
  assert.equal(typeof CreationController.prototype.shareTask, "function", "shareTask method should exist");
});

test("creation controller does not reference job-based endpoints", () => {
  const source = CreationController.toString();
  assert.ok(!source.includes("jobId"), "Controller should not reference jobId");
  assert.ok(!source.includes("createJob"), "Controller should not reference createJob");
  assert.ok(!source.includes("createPlan"), "Controller should not reference createPlan");
  assert.ok(!source.includes("getJob"), "Controller should not reference getJob");
});
