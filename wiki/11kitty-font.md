# kitty 字体说明：配置、现状、下载与安装

> 环境：CachyOS（Arch 系） · 生成日期：2026-11-02

## 1. kitty 配置里的字体

配置文件里有两处，内容一致：

| 文件 | 行 | 配置 |
|---|---|---|
| `~/.config/kitty/kitty.conf` | 6–7 | `font_family JetBrains Maple Mono ` / `font_size 13.5` |
| `~/.config/kitty/themes/kitty.conf` | 4–5 | 同上（这是主题备份/模板，实际生效的是 `kitty.conf`） |


## 2. 系统当前状态

字体**已经装好了**，而且是系统级安装：

- 目录：`/usr/local/share/fonts/JetBrainsMapleMono/`
- 共 16 个 ttf（Thin → ExtraBold，含对应 Italic）
- fontconfig 已识别：`fc-list | grep -i "JetBrains Maple"` 能列出 `JetBrains Maple Mono`
- 字体版本约 `2.304`
- 目前装的是**非 NF 版**（字符集里只有 powerline 的 `e0a0–e0b7`，没有 Nerd Font 的 `F0000+` 私用区图标）。如果终端里出现方块/豆腐块图标，就需要换成 NF 版。

所以现在 kitty 能正常用这个字体，不需要重装。下面是“以后重装/换机器时”的完整流程。

验证命令：

```bash
fc-list | grep -i "JetBrains Maple"
```

## 3. 下载

这是 `SpaceTimee/Fusion-JetBrainsMapleMono` 项目：JetBrains Mono + Maple Mono 合成字体（中英文 2:1 等宽、带连字、OFL 协议）。

- 仓库：<https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono>
- 发布页：<https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases>

### 方式 A：AUR（CachyOS 上最省事）

```bash
paru -Ss jetbrains-maple-mono
# 例如
paru -S ttf-jetbrains-maple-mono-nf-xx-xx
```

AUR 包名格式是 `ttf-jetbrains-maple-mono-[nf/xx]-[xx/nr/nl/ht]-[xx/...]`，用 `paru -Ss` 看有哪些组合再选。AUR 包会自动装到 `/usr/share/fonts/` 并刷新缓存。

### 方式 B：GitHub Release 手动下载

1. 打开 <https://github.com/SpaceTimee/Fusion-JetBrainsMapleMono/releases>
2. 下载 zip，文件名格式：`JetBrainsMapleMono-[NF/XX]-[NR/XX]-[NL/XX]-[HT/XX].zip`

各段含义：

| 标记 | 含义 | 说明 |
|---|---|---|
| `NF` / `XX` | 是否带 Nerd Font 图标 | `NF` 带图标，**推荐终端使用**；`XX` 不带 |
| `NR` / `XX` | 是否中文窄间距 | `NR` 缩小中日间距，但会破坏中英 2:1 对齐 |
| `NL` / `XX` | 是否禁用连字 | `NL` 禁用；`XX` 保留连字 |
| `HT` / `XX` | 是否 Hinted | `HT` 让低分辨率屏（≤1080P）更均匀，高分屏可能略糊 |

不确定就下 `JetBrainsMapleMono-XX-XX-XX-XX.zip`，或用终端的话建议 `JetBrainsMapleMono-NF-XX-XX-XX.zip`。

```bash
cd ~/Downloads
curl -LO <release zip 的地址>
unzip JetBrainsMapleMono-*.zip -d JetBrainsMapleMono
ls JetBrainsMapleMono
```

## 4. 添加到系统字体

### 用户级（只对当前用户，不需要 sudo，推荐日常使用）

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMapleMono
cp ~/Downloads/JetBrainsMapleMono/*.ttf ~/.local/share/fonts/JetBrainsMapleMono/
fc-cache -fv ~/.local/share/fonts
```

### 系统级（所有用户，当前安装方式就是这种）

```bash
sudo mkdir -p /usr/local/share/fonts/JetBrainsMapleMono
sudo cp ~/Downloads/JetBrainsMapleMono/*.ttf /usr/local/share/fonts/JetBrainsMapleMono/
sudo fc-cache -fv
```

### 验证

```bash
# 能列出说明注册成功
fc-list | grep -i "JetBrains Maple"

# 看具体 family 名和匹配结果
fc-match "JetBrains Maple Mono"
fc-match -f '%{file}\n' "JetBrains Maple Mono"
```

`fc-match` 返回的如果还是 DejaVu 之类，说明缓存没刷新或 family 名写错。

安装完成后，在 kitty 里按 `Ctrl+Shift+F5` 重载配置，或执行：

```bash
kill -SIGUSR1 $(pgrep -x kitty)
```
