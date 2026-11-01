# MangoHud 帧率监控不显示 —— 排查记录

- 日期：2026-11-01
- 环境：CachyOS（Arch 系）+ niri 26.04（Wayland）+ Steam / Proton Experimental + AMD Radeon 核显（Lucienne）
- 相关软件：`mangohud 0.8.4`、`lib32-mangohud 0.8.4`、`mangojuice-bin 1.0.0`

## 一、问题现象

Steam 非 Steam 游戏快捷方式（`FeverGames.exe`）的启动项已经填了：

```
mangohud %command%
```

但进入游戏（第五人格 `dwrg.exe`）后，画面上看不到任何帧率 / HUD 信息。

## 二、先确认安装本身没问题

```bash
pacman -Q mangohud lib32-mangohud mangojuice-bin
# mangohud 0.8.4-1.1
# lib32-mangohud 0.8.4-1
# mangojuice-bin 1.0.0-1

ls /usr/share/vulkan/implicit_layer.d/
# MangoHud.x86_64.json  MangoHud.x86.json  ...

ls /usr/lib/mangohud /usr/lib32/mangohud
# libMangoHud.so  libMangoHud_opengl.so  libMangoHud_shim.so
```

64 位 / 32 位库、Vulkan 层、配置文件都在，安装没有问题。

## 三、确认启动项和注入是否生效

查看正在运行的游戏进程：

```bash
pgrep -a -f "FeverGames|dwrg"
```

在游戏进程（`dwrg.exe`，PID 会变）里检查环境变量和已加载的库：

```bash
p=<$游戏进程PID>
tr '\0' '\n' < /proc/$p/environ | grep -iE "MANGOHUD|LD_PRELOAD"
grep -i mangohud /proc/$p/maps
```

结果：

- `MANGOHUD=1` 已设置
- `LD_PRELOAD` 里已加载 `libMangoHud_shim.so`（x86_64 + i386 都有）
- `libMangoHud.so` 已映射进游戏进程
- Steam Linux Runtime（pressure-vessel）的容器里也注册了 MangoHud 的 Vulkan 隐式层

**结论：`mangohud %command%` 已经正确生效，注入、层、32/64 位都没问题。**

## 四、用截图确认 HUD 到底有没有画出来

用 niri 自带截图（不依赖第三方工具）：

```bash
niri msg action screenshot-screen
# 截图默认保存到 ~/Pictures/Screenshots/
```

游戏全屏画面里确实没有 HUD。

再用最简单的程序在桌面单独测试：

```bash
mangohud glxgears
```

同样没有 HUD。说明问题不在游戏、不在 Proton，而在 MangoHud 本身。

## 五、隔离变量：换配置文件测试

用空配置启动：

```bash
printf '' > /tmp/mh_empty.conf
MANGOHUD_CONFIGFILE=/tmp/mh_empty.conf mangohud glxgears
```

HUD 正常显示（GPU / CPU / OpenGL / FPS / Frametime 都有）。

改用用户自己的配置：

```bash
mangohud glxgears     # 读 ~/.config/MangoHud/MangoHud.conf
```

HUD 消失。

**结论：问题由 `~/.config/MangoHud/MangoHud.conf` 的内容导致，不是启动项问题。**

## 六、根本原因

MangoJuice 生成的配置里有这一行：

```ini
legacy_layout=false
```

这是 MangoHud 的「新布局」模式。新布局下 **HUD 不会自动显示任何指标**，必须在配置里显式写出要显示的条目，例如：

```ini
fps
gpu_stats
cpu_stats
gpu_temp
cpu_temp
ram
vram
frametime
```

而 MangoJuice 生成的这份配置只写了颜色、位置、圆角、快捷键等样式项，**一条指标都没写**，所以 HUD 内容为空，看起来就像「完全没有显示」。

并且 MangoHud 日志里没有任何报错（只有正常的 `hwmon` 信息），所以从日志很难直接看出来。

## 七、解决办法

编辑 `~/.config/MangoHud/MangoHud.conf`，删除这一行：

```ini
legacy_layout=false
```

删除后 MangoHud 回到默认布局，会自动显示默认指标，其余颜色 / 位置 / 快捷键等样式配置继续生效。

修改前已备份：

```bash
cp ~/.config/MangoHud/MangoHud.conf \
   ~/.config/MangoHud/MangoHud.conf.bak-214612
```

如果确实想用新布局，就在 `legacy_layout=false` 下面补上需要的指标项（见上一节示例）。

## 八、验证

```bash
mangohud glxgears
```

HUD 正常显示，修复完成。

**注意：游戏是在启动时读取配置的，修改后需要重启一次游戏才会生效**，Steam 启动项 `mangohud %command%` 不需要改动。

## 九、经验总结

1. Steam 启动项加了 `mangohud %command%` 不代表 HUD 一定会显示，要分三层排查：
   - 有没有注入（`MANGOHUD`、`LD_PRELOAD`、`/proc/<pid>/maps`）
   - 有没有画出来（截图验证）
   - 配置有没有内容（换空配置对比）
2. MangoHud 没有任何报错 ≠ 配置正确，`legacy_layout=false` 配空指标就是典型的「静默不显示」。
3. 用 `MANGOHUD_CONFIGFILE=/tmp/xxx.conf` 可以临时指定配置，是快速隔离配置问题的好办法。
4. MangoJuice 保存配置后建议检查一下生成的文件，确认指标条目有没有写进去。
