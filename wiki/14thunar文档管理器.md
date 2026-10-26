## 安装

```bash
sudo pacman -S --needed xdg-desktop-portal-gtk thunar tumbler ffmpegthumbnailer poppler-glib gvfs-smb file-roller thunar-archive-plugin gnome-keyring thunar-volman gvfs-mtp gvfs-gphoto2 webp-pixbuf-loader icoextract python-pillow
```



>`xdg-desktop-portal-gtk` 是 GTK 的 xdg 桌面门户。

>`tumbler` 提供图片预览功能。

>`ffmpegthumbnailer` 视频预览。

>`poppler-glib` PDF 预览。

>`gvfs-smb` 检查可挂载的外部设备，访问 smb 分享等功能。

>`file-roller` 提供压缩解压缩功能。

>`thunar-archive-plugin` 在 Thunar 的右键菜单添加压缩解压缩选项。

>`gnome-keyring` 提供密码保存功能。第一次保存密码会让你设置 keyring 的密码，可以空着。

>`thunar-volman` 自动管理移动硬盘等设备。

>`gvfs-mtp` 连接手机。

>`gvfs-gphoto2` 连相机。

>`webp-pixbuf-loader` webp 缩略图。

>`icoextract` `python-pillow` exe 缩略图。

## 设为默认文件管理器

xdg-mime default thunar.desktop inode/directory

改键位

文件：~/.config/niri/cfg/keybinds.kdl 第 31 行

- Mod+E  hotkey-overlay-title="File Manager: Nautilus" { spawn "nautilus"; }

+ Mod+E  hotkey-overlay-title="File Manager: Thunar"   { spawn "thunar"; }

## 右键从此处打开终端

Thunar 提供了强大的自定义右键功能。点击左上角 `编辑` > `配置自定义动作` > 选中 `open in terminal here` > 点击小齿轮 > 命令改成 `kitty`。



**浏览器里点"上传文件"、程序里点"另存为"时弹出的那个选文件窗口**，用哪个 portal 来提供。

- 不打算装 Nautilus（或准备卸载它）：**需要做**，否则文件选择弹窗会出问题。
- 打算保留 Nautilus：不用做，默认就能工作，只是弹窗界面是 Nautilus 风格，且系统里多一个你不用的文件管理器。

配置使用 Thunar 进行文件选取

Niri 默认使用 GNOME 的桌面门户进行文件选取，需要调整为 GTK 配合 Thunar 使用：

```bash
mkdir -p ~/.config/xdg-desktop-portal/
```

```bash
sudo pacman -S xdg-desktop-portal-gtk
mkdir -p ~/.config/xdg-desktop-portal
```

把三行配置写进 `~/.config/xdg-desktop-portal/niri-portals.conf`，

```bash
[preferred]
default=gnome;gtk;
org.freedesktop.impl.portal.FileChooser=gtk
```

然后：

```bash
systemctl --user restart xdg-desktop-portal
```

注意必须装 `xdg-desktop-portal-gtk`，否则配置指向的 portal 不存在。

如果你想让"打开所在文件夹"这类操作用 Thunar，还要另外执行：

bash

```bash
xdg-mime default thunar.desktop inode/directory
```

>`default=gnome;gtk;` 设置默认门户是 GNOME，回退门户是 GTK。这会让除文件选取以外的功能都使用 GNOME 门户，如 `屏幕分享`。

>`org.freedesktop.impl.portal.FileChooser=gtk` 设置文件选择用 GTK。