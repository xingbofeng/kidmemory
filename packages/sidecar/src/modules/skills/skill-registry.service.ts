import { Inject, Injectable } from "@nestjs/common";

import { SkillLoaderService, type LoadedSkill, type SkillRegistryEntry } from "./skill-loader.service.ts";

@Injectable()
export class SkillRegistryService {
  private registryPromise?: Promise<SkillRegistryEntry[]>;

  constructor(@Inject(SkillLoaderService) private readonly loader: SkillLoaderService) {}

  async listSkills() {
    return this.getRegistry();
  }

  async getSkill(skillId: string) {
    const registry = await this.getRegistry();
    return registry.find((item) => item.id === skillId);
  }

  async getSkillOrThrow(skillId: string) {
    const skill = await this.getSkill(skillId);
    if (!skill) {
      throw new Error(`Skill not found: ${skillId}`);
    }
    return skill;
  }

  async loadSkill(skillId: string): Promise<LoadedSkill> {
    const skill = await this.getSkillOrThrow(skillId);
    return this.loader.loadSkill(skill);
  }

  async refresh() {
    this.registryPromise = undefined;
    return this.getRegistry();
  }

  private async getRegistry() {
    this.registryPromise ??= this.loader.loadRegistry().then((registry) => registry.skills);
    return this.registryPromise;
  }
}
