#!/bin/bash
# SPDX-License-Identifier: MIT
#
# 默认设置修改
# 参考 OpenWRT-CI Scripts/Settings.sh，按 iStoreOS 源码结构适配

#默认设置（可被工作流环境变量覆盖）
WRT_IP="${WRT_IP:-192.168.100.1}"
WRT_NAME="${WRT_NAME:-EMB3531}"

#iStoreOS 默认IP由 istoreos-files 包的 postinst 脚本改写（192.168.1.1 -> 192.168.100.1），
#因此改这里的 Makefile 才是 iStoreOS 的正确改法
if [ -f "./package/istoreos-files/Makefile" ]; then
	sed -i "s/192\.168\.100\.1/$WRT_IP/g" ./package/istoreos-files/Makefile
	echo "istoreos default ip has been set to $WRT_IP!"
fi

#修改默认主机名
CFG_FILE="./package/base-files/files/bin/config_generate"
if [ -f "$CFG_FILE" ]; then
	sed -i "s/hostname='OpenWrt'/hostname='$WRT_NAME'/g" "$CFG_FILE"
	echo "default hostname has been set to $WRT_NAME!"
fi

#LuCI 地址关联
FLASH_JS="$(find ./feeds/luci -type f -name flash.js -print -quit 2>/dev/null)"
if [ -f "$FLASH_JS" ]; then
	sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" "$FLASH_JS"
	echo "luci flash.js ip has been set to $WRT_IP!"
fi

#引入私有扩展配置（可选）
if [ -f "$GITHUB_WORKSPACE/Config/PRIVATE.txt" ]; then
	echo "Applying private configurations from PRIVATE.txt..."
	cat "$GITHUB_WORKSPACE/Config/PRIVATE.txt" >> ./.config
fi
