# 快捷键改动

**修改文件**：`~/.config/niri/cfg/keybinds.kdl`（`binds { }` 内）

**说明**

- 「原配置」一列按 niri 默认配置和你之前的描述填写，以你文件里的实际内容为准。标「无」表示原来没有这个绑定，直接新增。
- 下表里 noctalia 的命令按 v4 写法。如果你用的是 v5，把命令换成：启动器 `noctalia msg panel-toggle launcher`，会话菜单 `noctalia msg panel-toggle session`。
- niri 不允许同一个按键绑定两次，改完旧行要删掉或替换，不要只追加。

## 改动表

| 作用 | 原配置 | 改动后的配置 |
|---|---|---|
| 13打开终端(a1) | 按你原来的绑定（如 `Mod+Return`），或无 | `Mod+T { spawn "alacritty"; }` |
| 浮动/平铺窗口切换(a2) | `Mod+T { toggle-window-floating; }` | `Mod+Shift+T { toggle-window-floating; }` |
| 滚轮切换工作区(b1) | `Mod+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }`<br>`Mod+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }` | `Mod+Shift+WheelScrollDown cooldown-ms=150 { focus-workspace-down; }`<br>`Mod+Shift+WheelScrollUp cooldown-ms=150 { focus-workspace-up; }` |
| 滚轮左右切换列(b2) | `Mod+Shift+WheelScrollDown { focus-column-right; }`<br>`Mod+Shift+WheelScrollUp { focus-column-left; }` | `Mod+WheelScrollDown { focus-column-right; }`<br>`Mod+WheelScrollUp { focus-column-left; }` |
| 应用启动器（noctalia） | 无（niri 默认是 `Mod+D` 打开 fuzzel，以实际为准） | `Mod+Z { spawn-sh "qs -c noctalia-shell ipc call launcher toggle"; }`<br>`Mod+Ctrl+Return { spawn-sh "qs -c noctalia-shell ipc call launcher toggle"; }` |
| 会话菜单（noctalia） | 无（niri 默认 `Mod+Shift+E` 是退出，以实际为准） | `Mod+X { spawn-sh "qs -c noctalia-shell ipc call sessionMenu toggle"; }`<br>`Mod+Shift+Q { spawn-sh "qs -c noctalia-shell ipc call sessionMenu toggle"; }` |
| 截图（选区）(c1) | Ctrl+Shift+1 | `Mod+Shift+S { screenshot; }` |
| 总览 | `Mod+O { toggle-overview; }` | `Mod+G { toggle-overview; }` |
| 中键关闭窗口 | 无（`Mod+Q { close-window; }` 保留） | 在 `Mod+Q` 下面新增一行：<br>`Mod+MouseMiddle { close-window; }` |
| 21应用启动器 | Mod+Ctrl+Return       (rentun就是enter) | Mod+Z { spawn-sh "noctalia msg panel-toggle launcher"; } |
| 24会话菜单 | Mod+Shift+Q | Mod+X { spawn-sh "noctalia msg panel-toggle session"; } |

## 可选：用 Ctrl+Shift+数字截图

| 作用 | 原配置 | 改动后的配置 |
|---|---|---|
| noctalia设置界面(c2) | Mod+Shift+S | `Ctrl+Shift+1 { screenshot; }` |
| 整个屏幕截图 | `Ctrl+Print { screenshot-screen; }` | `Ctrl+Shift+2 { screenshot-screen; }` |
| 当前窗口截图 | `Alt+Print { screenshot-window; }` | `Ctrl+Shift+3 { screenshot-window; }` |

截图保存位置不在 `binds` 里，而是顶层的 `screenshot-path`，通常是 `~/Pictures/Screenshots/`。查找位置：

```bash
grep -rn "screenshot-path" ~/.config/niri/
```

让 niri 的截图（比如按 `Win+Shift+S`）自动存到指定文件夹，把 `misc.kdl` 里的 `null` 改成一个路径：

```
// 修改前：
screenshot-path null
// 修改后：
screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
```

## 注意事项

- `spawn-sh` 需要较新版本的 niri。如果报错，改用 `spawn "qs" "-c" "noctalia-shell" "ipc" "call" "launcher" "toggle";` 这种写法。
- `Mod+MouseMiddle` 需要较新版本的 niri。如果 `niri validate` 报错，先执行 `sudo pacman -Syu` 更新。
- 滚轮那两组是互相对调，改的时候不要让同一个按键同时出现两次。

## 检查与生效

```bash
niri validate
```

niri 保存配置后会自动重载。如果提示按键重复，按报错里的行号找到旧的那一行删除或修改即可。

# 另外的

## Typora 无法输入中文

编辑 `~/.config/niri/cfg/misc.kdl`，在已有的 `environment { ... }` 块中加入：

```kdl
environment {
    // ...原有内容保持不变...
    XMODIFIERS "@im=fcitx"
}
```

见03水杉输入法-fcitx5默认中文配置记录.md
