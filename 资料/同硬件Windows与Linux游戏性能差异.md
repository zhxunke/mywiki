# 同样硬件，为什么这游戏在 Windows 上不卡、Linux 上玩久了掉帧

- 日期：2026-11-02
- 机器：Lenovo V15 G2 ALC / AMD Ryzen 5 5500U（15W APU，Radeon 核显）
- 游戏：第五人格 PC 客户端（NeoX 引擎，D3D11）
- Linux 环境：CachyOS + niri 26.04（Wayland）+ Steam / Proton Experimental + DXVK
- Windows：同机另一分区（NTFS，301GB）

## 一、结论

**同样硬件 ≠ 同样运行路径。**

Windows 上游戏跑的是原生 D3D11 + AMD 官方驱动；Linux 上多了一层翻译：

```
游戏（Windows 程序）
  → Wine / Proton（翻译 Win32 API）
  → DXVK（D3D11 → Vulkan）
  → Mesa RADV（开源 AMD 驱动）
  → 内核 amdgpu
  → XWayland + niri 合成
```

每多一层都会多花 CPU、内存和延迟。Windows 不是"不热"，而是每帧干活更少、风扇和功耗策略不同，没有越过你能感知的阈值；Linux 的额外开销让它更早撞到散热/功耗墙。

## 二、具体差异

### 1. D3D11 → Vulkan 翻译开销

游戏日志：

```
render_device: d3d11
gpu: AMD Radeon Graphics (RADV RENOIR)
```

- Windows：游戏直接调用 AMD 驱动
- Linux：DXVK 把每个 D3D11 调用翻译成 Vulkan

这游戏本身 CPU 侧就重（日志里 `SCRIPT` 约 6ms/帧），DXVK 的额外开销让 16.7ms 的帧预算更容易爆掉。

### 2. 显卡驱动不同

- Windows：AMD Adrenalin 驱动，有针对具体游戏的优化配置和驱动级着色器缓存
- Linux：Mesa RADV，整体很强，但个别 Windows 游戏（尤其带虚拟纹理/流式加载的）优化不如官方驱动

### 3. 显存只有 2GB

```
VRAM : 2048 MB
GTT  : 7240 MB
```

核显专用显存只有 2GB。DXVK/RADV 的显存分配、回收策略与 Windows 驱动不同，画质开高、场景切换多了以后更容易卡顿。

### 4. 文件 I/O 和全屏方式

- 游戏在 btrfs 上，资源加载经过 Wine 文件层；Windows 是 NTFS 原生 I/O
- Windows 全屏独占可以绕过 DWM；Linux 下是 XWayland 窗口由 niri 合成，多一层合成和帧调度
- 结果：同样的卡顿，在 Linux 上更容易被感知

### 5. 风扇和功耗策略

- Windows 有 Lenovo Vantage，可切性能模式，风扇策略更激进
- Linux 没有 Vantage，风扇走 EC 默认曲线，这台机器连 `platform_profile` 都不支持
- CPU 是 `acpi-cpufreq`（BIOS 未暴露 CPPC，`amd_pstate` 用不了），能效和 boost 策略与 Windows 驱动不同

## 三、实测数据

### 散热（Linux，CPU 12 线程满载 80 秒）

```
10s  Tctl=82°C  CPU≈3.6GHz
30s  Tctl=91°C  CPU≈3.6GHz
40s  Tctl=92°C  CPU≈3.5GHz
70s  Tctl=89°C  CPU≈3.4GHz
```

空闲 44°C，满载 30 秒就到 91～92°C，散热余量很小。游戏是 CPU+GPU 同时发热，跑一小时后散热器饱和，触发温度/功耗限制。

### 游戏日志（2026-11-01 21:34～23:50 同一局游戏）

| 时间 | 战斗平均帧 | 严重卡顿/分钟 | 单帧最长 |
|---|---|---|---|
| 22:09 | 59.8 | 0.19 | 277ms |
| 22:34 | 58.4 | 0.12 | 150ms |
| 23:14 | 56.1 | 1.42 | 224ms |
| 23:31 | 55.4 | **5.11** | **587ms** |
| 23:49 | 56.5 | **3.61** | 396ms |

同时：

- 游戏内存 1.2GB → 4.4GB（约 1.5GB/小时）
- `WAIT_GPU` 只有 0.01～0.05ms，瓶颈不在显卡
- `FRAME_UPDATE` 从 10.5ms 涨到 13.4ms，是 CPU 侧变慢
- 无 OOM、无 amdgpu 报错、电源已接（电池 100%）

### 当前画面配置（Linux）

```
graph = high
shadow = high
particle = low
resolution = 1366x768
home_hall_graph = high
home_hall_shadowmap = on
home_hall_pcf = on
home_hall_fxaa = on
home_hall_gtao = on
high_fps = on
high_fps_out_battle = off   # 大厅限制 30fps，仅影响非战斗场景
```

## 四、在 Linux 上的建议

按效果排序：

1. **改善散热**
   - 清灰、换硅脂（用了一两年的话效果明显）
   - 垫高机身/散热底座，别挡住底部进风
2. **降画质**
   - high → medium
   - 关 GTAO、PCF、阴影、FXAA
   - 分辨率降到 1600×900 或 1280×720
3. **锁帧 60**，减少发热
4. **玩 1.5～2 小时重启一次游戏**，释放增长的内存
5. 关掉后台不用的大厅/浏览器窗口，减少内存和 CPU 占用
6. 可尝试换 Proton 版本（Proton-GE / 旧版 Experimental），个别版本 DXVK 表现不同

**不要指望 Linux 追平 Windows 原生性能**，这台 15W 核显本尤其难。

## 五、如何确认

监控脚本：`/home/xunke/dowm/game-monitor.sh`

```bash
~/dowm/game-monitor.sh
```

每 5 秒记录温度、CPU/GPU 频率、显存、内存到 CSV。卡的时候看：

- `tctl_c` 是否 90°C 以上
- `sclk_mhz` 是否从 1800 掉下来
- `vram_used_mb` 是否接近 2048

如果温度和掉帧对得上，就是散热问题，清灰/降画质即可明显改善。
