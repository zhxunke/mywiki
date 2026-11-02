
## 添加步骤

### 编辑 pacman 配置文件

先用 root 权限打开配置文件：

```bash
sudo nano /etc/pacman.conf
```

> 也可以用 `sudo vim /etc/pacman.conf` 或 `sudo micro /etc/pacman.conf`。

在文件**最末尾**追加以下内容：

```ini
# Arch Linux 中文社区仓库
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
Server = https://mirrors.jlu.edu.cn/archlinuxcn/$arch
Server = https://repo.archlinuxcn.org/$arch
```

说明：

- `[archlinuxcn]` 段名必须顶格写，不能有空格。
- `Server` 可以写多个，pacman 会按顺序尝试，前面的挂了自动切后面的。
- `SigLevel = Optional TrustedOnly` 表示包可以没签名，但有签名时必须验签，是官方推荐写法。

### 步骤 3：安装签名密钥环（最容易漏的一步）

```bash
sudo pacman -S --needed archlinuxcn-keyring
```

这一步会从源里下载 archlinuxcn 用的 GPG 公钥。**必须在装其他包之前做。**

如果此时报 `签名未知/无法验证`，先临时跳过校验装上密钥环：

```bash
sudo pacman -U --noconfirm \
  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/x86_64/archlinuxcn-keyring-*.pkg.tar.zst
```

### 步骤 4：同步数据库

```bash
sudo pacman -Syy
```

`-yy` 是强制完整刷新所有仓库索引，修改过配置后用它最保险。

### 步骤 5：验证


（可选）实际装一个包做端到端验证：

```bash
sudo pacman -S yay
```

---

## 三、国内可用镜像列表

按需替换 `Server` 行即可，格式统一为 `https://<域名>/archlinuxcn/$arch`：

| 镜像 | 地址 |
| --- | --- |
| 清华大学（TUNA） | `https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch` |
| 吉林大学 | `https://mirrors.jlu.edu.cn/archlinuxcn/$arch` |
| 中国科学技术大学 | `https://mirrors.ustc.edu.cn/archlinuxcn/$arch` |
| 阿里云 | `https://mirrors.aliyun.com/archlinuxcn/$arch` |
| 北京外国语大学 | `https://mirrors.bfsu.edu.cn/archlinuxcn/$arch` |
| 官方源（海外） | `https://repo.archlinuxcn.org/$arch` |

推荐配置「国内镜像 + 官方源兜底」，即本文步骤 2 中的写法。

快速测连通性：

```bash
curl -sS -o /dev/null -w "%{http_code}\n" \
  https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/x86_64/archlinuxcn.db
# 期望输出 200
```

---

## 四、本机实际状态

| 检查项 | 结果 |
| --- | --- |
| 系统 | CachyOS（`ID_LIKE=arch`），x86_64 |
| `/etc/pacman.conf` 中的 `[archlinuxcn]` 段 | ✅ 已存在（第 117–120 行） |
| `archlinuxcn-keyring` | ✅ 已安装，版本 `20260505-1` |
| `/var/lib/pacman/sync/archlinuxcn.db` | ✅ 已生成，1.4 MB（2026-11-02 12:25） |
| 清华镜像连通性 | ✅ HTTP 200 |
| 吉大镜像连通性 | ✅ HTTP 200 |

本机配置内容：

```ini
# Arch Linux 中文社区仓库
[archlinuxcn]
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
Server = https://mirrors.jlu.edu.cn/archlinuxcn/$arch
Server = https://repo.archlinuxcn.org/$arch
```

结论：**无需再做任何操作，可直接 `sudo pacman -S <包名>` 使用。**

---

## 五、常见问题

### 1. `错误：非 root (根用户) 无法执行指定操作`

`pacman -Sy`、`-S` 等写操作必须加 `sudo`。只读操作如 `pacman -Ss`、`pacman -Sl` 不需要。

### 2. `invalid or corrupted package (PGP signature)`

密钥环过期或缺失，重新安装即可：

```bash
sudo pacman -S archlinuxcn-keyring
sudo pacman -Syyu
```

若仍失败，强制刷新密钥：

```bash
sudo rm -rf /etc/pacman.d/gnupg
sudo pacman-key --init
sudo pacman-key --populate archlinux cachyos archlinuxcn
sudo pacman -Syy
```

### 3. `failed retrieving file 'archlinuxcn.db' ... 404`

镜像未同步或路径错误，检查：

- `Server` 行结尾必须是 `/$arch`，不是 `/archlinuxcn/x86_64`（写死容易出错）。
- 换一个镜像试试，或临时注释掉出问题的 `Server`。

### 4. 会不会和 CachyOS 自己的仓库冲突？

不会。CachyOS 的 `cachyos-v3`、`cachyos-extra-v3` 等仓库提供的是官方包的指令集优化版本，archlinuxcn 提供的是官方没有的额外包，两者包名不重叠。pacman 按 `pacman.conf` 中从上到下的顺序优先匹配。

### 5. 修改配置后要不要重启？

不需要。配置只影响 pacman 本身，下次执行 pacman 命令即生效。

---

## 六、一键脚本（可选）

如果想在另一台 Arch 机器上快速配置，可保存为 `add-archlinuxcn.sh` 执行：

```bash
#!/usr/bin/env bash
set -euo pipefail

[[ $EUID -eq 0 ]] || { echo "请用 sudo 运行"; exit 1; }

CONF=/etc/pacman.conf

if grep -q '^\[archlinuxcn\]' "$CONF"; then
    echo "==> archlinuxcn 已存在，跳过写入"
else
    cp -a "$CONF" "$CONF.bak.$(date +%Y%m%d%H%M%S)"
    cat >> "$CONF" <<'EOF'

# Arch Linux 中文社区仓库
[archlinuxcn]
SigLevel = Optional TrustedOnly
Server = https://mirrors.tuna.tsinghua.edu.cn/archlinuxcn/$arch
Server = https://mirrors.jlu.edu.cn/archlinuxcn/$arch
Server = https://repo.archlinuxcn.org/$arch
EOF
    echo "==> 已写入 $CONF（原文件已备份）"
fi

echo "==> 安装密钥环"
pacman -S --needed --noconfirm archlinuxcn-keyring

echo "==> 同步数据库"
pacman -Syy

echo "==> 验证"
pacman -Sl archlinuxcn | head
echo "完成。"
```

使用：

```bash
chmod +x add-archlinuxcn.sh
sudo ./add-archlinuxcn.sh
```
