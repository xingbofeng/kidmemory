import { Inject, Injectable } from "@nestjs/common";

export function registerInjectable(target: Function, dependencies: Function[]) {
  for (const [index, dependency] of dependencies.entries()) {
    Inject(dependency)(target, undefined, index);
  }
  Injectable()(target);
}
