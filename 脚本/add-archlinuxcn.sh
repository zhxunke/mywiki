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