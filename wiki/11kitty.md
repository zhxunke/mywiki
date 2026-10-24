## 安装

sudo pacman -S kitty

## 查看当前终端

niri msg windows

## 确认 Niri 配置里 spawn 的是 alacritty

```bash
grep -rn "alacritty" ~/.config/niri/ /etc/niri/ 2>/dev/null
```

大概率会看到类似这样的行：

```bash
Mod+T { spawn "alacritty"; }
```

##  修改配置

编辑 `~/.config/niri/cfg/keybinds`（如果上一步发现配置在别处，就改那个文件），把 `spawn "alacritty"` 改成 `spawn "kitty"`。

如果想用单实例模式（启动更快、省内存），写成：

kdl

```
Mod+T { spawn "kitty" "--single-instance"; }
```

注意：Kitty 的单实例参数是 `--single-instance`，但实际推荐用 `kitty --single-instance` 作为启动命令；如果 Niri 的 `spawn` 对参数解析有问题，也可以只写 `spawn "kitty"`，先保证能用。

单实例模式的意思是：你第一次启动 Kitty 后，它会在后台保持一个主进程；之后你每次再按快捷键“打开终端”，Kitty 不会再从头启动一个新程序，而是**直接通知那个已经在运行的主进程，让它新开一个窗口**。

### 这样做的好处

- **启动更快**：省去了重新初始化程序的时间，按快捷键后窗口几乎瞬间弹出。
- **更省内存**：所有窗口共享同一个 GPU 缓存，避免了每个窗口都占用一份资源。

# 使用配置

放在 ~/.config/kitty 下
## 安装字体
yay -S ttf-jetbrains-maple-mono-nf-xx-xx
或：
paru -S ttf-jetbrains-maple-mono-nf-xx-xx
装完刷新字体缓存并确认：
fc-cache -f && fc-match "JetBrains Maple Mono"
输出应显示 JetBrainsMapleMono... 而不是 NotoSansCJK，这样就生效了（kitty 需重开）。

### 注释掉DMS相关
缺的两个 include 不会导致启动失败
实测过，kitty 只是警告 Could not find included config file ... ignoring，照常启动。建议直接注释掉，免得每次开终端刷警告：
```bash
# include dank-tabs.conf

# include dank-theme.conf
```

它们来自 DankMaterialShell，不属于这套 noctalia 配置，功能上没损失。

注意 Noctalia 会接管 current-theme.conf 并随壁纸重新生成颜色，这是设计行为，不是你配置错了。