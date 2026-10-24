# niri 配置修改说明

记录本次对 niri 配置所做的修改：每一项的作用、修改的文件、原配置和改动后的配置。

## 配置文件结构

主配置文件是 `~/.config/niri/config.kdl`，它本身只有 `include`，实际设置分散在 `cfg/` 目录下：

```kdl
include "./cfg/animation.kdl"
include "./cfg/autostart.kdl"
include "./cfg/keybinds.kdl"
include "./cfg/input.kdl"
include "./cfg/display.kdl"
include "./cfg/layout.kdl"
include "./cfg/rules.kdl"
include "./cfg/misc.kdl"
```

| 文件 | 内容 |
|---|---|
| `cfg/input.kdl` | 键盘、鼠标、焦点行为 |
| `cfg/rules.kdl` | 窗口规则（window-rule） |
| `cfg/misc.kdl` | 光标、模糊、环境变量等杂项 |

修改后 niri 会自动重新加载配置。如有疑问，用 `niri validate` 检查语法。

## 改动总表

| 作用 | 更改的文件 | 原配置 | 改动后的配置 |
|---|---|---|---|
| 关闭「鼠标划到左右边缘就切换窗口」保留焦点跟随但不自动滚动） | `~/.config/niri/cfg/input.kdl` | `focus-follows-mouse` | `focus-follows-mouse max-scroll-amount="0%"` |
| Firefox / Steam / VS Code 打开时默认全屏 | `~/.config/niri/config.kdl` | 无 | 新增一个 `window-rule` 块，见下方「全屏规则」 |
| Steam 改为最大化（嫌弹窗被全屏时用） | `~/.config/niri/config.kdl` | 全屏规则里包含 `match app-id="^steam$"` | 删掉全屏规则里的 Steam 那一行，另加：<br>`window-rule { match app-id="^steam$"; open-maximized true }` |
| Firefox 全屏不生效时改为最大化 | `~/.config/niri/config.kdl` | 全屏规则里包含 `match app-id="^firefox$"` | 删掉全屏规则里的 Firefox 那一行，另加：<br>`window-rule { match app-id="^firefox$"; open-maximized true }` |
| 调大鼠标光标 | `~/.config/niri/cfg/misc.kdl`（第 13 到 16 行的 `cursor` 区块） | `xcursor-size 24`（默认值） | `xcursor-size 36`（先试 32 或 36，不够再加） |

## 1. 关闭「鼠标划到左右边缘就切换窗口」

**原因**：`input.kdl` 里开启了 `focus-follows-mouse`（焦点跟随鼠标）。聚焦到屏幕边缘露出一部分的窗口时，niri 会自动滚动画面，看起来就像「划到边缘就切换」。

- 方法一：删除或注释掉 `focus-follows-mouse`，之后只有点击窗口才会切换焦点。
- 方法二：写成 `focus-follows-mouse max-scroll-amount="0%"`，只有已经完整显示在屏幕内的窗口才会被聚焦，不会触发滚动。

## 2. 指定程序打开时默认全屏

### 2.1 查询程序的 App ID

先打开目标程序，然后运行：

```
niri msg windows
```

也可以用 `niri msg pick-window`，再用鼠标点选某个窗口，只显示那一个窗口的信息。

本次查到的 App ID：

| 程序 | App ID |
|---|---|
| Firefox | `firefox` |
| Steam | `steam` |
| VS Code | `com.microsoft.VSCode` |

### 2.2 全屏规则

```kdl
// 打开时默认全屏的程序（Firefox / Steam / VS Code）
window-rule {
    match app-id="^firefox$"
    match app-id="^steam$"
    match app-id="^com\\.microsoft\\.VSCode$"
    open-fullscreen true
}
```

说明：

- 多个 `match` 之间是「或」的关系，符合任意一条就会应用规则。
- `^` 和 `$` 表示完全匹配，避免误匹配其他程序。
- App ID 里的 `.` 在正则中代表任意字符，所以写成 `\\.`（KDL 字符串里反斜杠要写两个）。

### 2.3 注意事项

- 规则只对新打开的窗口生效，已经开着的程序要关掉重开。
- Steam 的好友列表、设置等弹窗也使用 `steam` 这个 App ID，会一起被全屏。嫌干扰的话，可以把 Steam 改成最大化：

  ```kdl
  window-rule {
      match app-id="^steam$"
      open-maximized true
  }
  ```

  同时把上面全屏规则里的 Steam 那一行删掉。
- `open-maximized` 是占满屏幕宽度并保留状态栏、间隙；`open-fullscreen` 是完全全屏。

### 2.4 Firefox 没生效时的排查

规则对 Firefox 的写法没有问题，若不生效可以依次检查：

1. 彻底关闭 Firefox 后再启动。Firefox 关窗口后后台进程可能还在，新窗口会沿用旧状态：

   ```
   pkill firefox
   ```

2. 检查其他规则文件里有没有针对 Firefox 的规则（后面的规则会覆盖前面的）：

   ```
   grep -n -i "firefox" ~/.config/niri/cfg/*.kdl
   ```

3. 改用最大化代替全屏：

   ```kdl
   window-rule {
       match app-id="^firefox$"
       open-maximized true
   }
   ```

   同时把全屏规则里的 Firefox 那一行删掉，避免两条规则冲突。

## 3. 调大鼠标光标

在 `cfg/misc.kdl` 的 `cursor` 区块里，只改 `xcursor-size` 后面的数字：

```kdl
cursor {
    xcursor-theme "capitaine-cursors"
    xcursor-size 36
}
```

说明：

- `xcursor-theme` 是光标主题名称，按实际安装的主题填写，已有的设置不用改。可用 `ls /usr/share/icons ~/.icons ~/.local/share/icons` 查看已安装的主题。
- 保存后新打开的程序会使用新大小；已经开着的程序（特别是 Electron、XWayland 程序）需要关掉重开才会变。

## 附：常用命令速查

| 命令 | 作用 |
|---|---|
| `niri validate` | 检查配置文件语法 |
| `niri msg windows` | 列出所有窗口及其 App ID |
| `niri msg pick-window` | 用鼠标点选窗口并显示其信息 |
| `pkill firefox` | 彻底结束 Firefox 的所有进程 |
