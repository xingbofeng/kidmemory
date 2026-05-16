import { createHash } from 'node:crypto';
import { networkInterfaces, hostname, platform } from 'node:os';
import { Injectable } from '@nestjs/common';

/**
 * MachineIdService 生成稳定的机器标识符。
 *
 * 生成规则：
 * - 使用 OS 主机名 + 网络接口 MAC 地址
 * - 通过 SHA-256 哈希生成稳定 ID
 * - 格式：`{platform}-{hash前8位}`
 * - 示例：`macos-a1b2c3d4`
 */
@Injectable()
export class MachineIdService {
  private cachedMachineId: string | null = null;

  /**
   * 获取机器 ID。首次调用时生成并缓存，后续调用返回缓存值。
   */
  getMachineId(): string {
    if (this.cachedMachineId) {
      return this.cachedMachineId;
    }

    const machineId = this.generateMachineId();
    this.cachedMachineId = machineId;
    return machineId;
  }

  /**
   * 生成机器 ID。
   */
  private generateMachineId(): string {
    const hostName = hostname();
    const macAddresses = this.getMacAddresses();
    const platformName = platform();

    // 组合主机名和 MAC 地址作为唯一标识
    const uniqueString = `${hostName}-${macAddresses.join('-')}`;

    // 使用 SHA-256 生成哈希
    const hash = createHash('sha256').update(uniqueString).digest('hex');

    // 取前 8 位哈希值
    const shortHash = hash.substring(0, 8);

    // 格式：{platform}-{hash前8位}
    return `${platformName}-${shortHash}`;
  }

  /**
   * 获取所有网络接口的 MAC 地址。
   * 过滤掉内部接口和无效地址。
   */
  private getMacAddresses(): string[] {
    const interfaces = networkInterfaces();
    const macAddresses: string[] = [];

    for (const [_name, addresses] of Object.entries(interfaces)) {
      if (!addresses) continue;

      for (const addr of addresses) {
        // 跳过内部接口和无 MAC 地址的接口
        if (addr.internal || !addr.mac || addr.mac === '00:00:00:00:00:00') {
          continue;
        }

        macAddresses.push(addr.mac);
      }
    }

    // 排序以确保稳定性
    return macAddresses.sort();
  }
}
