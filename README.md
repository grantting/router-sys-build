# Router Sys Build

基于 GitHub Actions 的 ImmortalWrt 固件自动化构建项目。

## 支持的设备

| 设备型号 | 设备ID |
|---------|--------|
| Redmi AX6 (原厂固件) | `redmi_ax6-stock` |
| 360T7 | `qihoo_360t7` |
| 小米路由器 3G | `xiaomi_mi-router-3g` |

## 使用方法

1. 进入仓库的 **Actions** 页面
2. 选择 **Build Xwrt** 工作流
3. 点击 **Run workflow**，填写以下参数：
   - **version**: 目标版本号（默认 `24.10.3`）
   - **model_id**: 选择设备型号
   - **packages**: 要安装的软件包（空格分隔，可用 `-包名` 排除）
   - **rootfs_size**: RootFS 分区大小（MB，默认 `300`）
4. 等待构建完成，在 Artifacts 中下载固件

## 参数说明

### version - 目标版本号

指定要编译的 ImmortalWrt 版本。版本号可在 [ImmortalWrt 下载页面](https://downloads.immortalwrt.org/releases/) 查看。

| 参数值 | 说明 |
|--------|------|
| `24.10.3` | 最新稳定版（默认） |
| `24.10.0` | 较旧稳定版 |
| `snapshot` | 开发快照版 |

> **注意**：使用 snapshot 版本时，软件包可能不稳定。

### model_id - 设备型号

选择要编译固件的目标设备。不同设备的 CPU 架构、网络接口、WiFi 芯片各不相同，必须选择正确的型号否则固件无法启动。

| 设备ID | CPU | 内存 | Flash | 无线 |
|--------|-----|------|-------|------|
| `redmi_ax6-stock` | IPQ807x (ARM Cortex-A53) | 512MB | 256MB | WiFi 6 |
| `qihoo_360t7` | MT7981 (ARM Cortex-A53) | 256MB | 128MB | WiFi 6 |
| `xiaomi_mi-router-3g` | MT7621 (MIPS 1004Kc) | 256MB | 128MB | WiFi 5 |

### packages - 软件包列表

指定要预装在固件中的软件包。多个包名用空格分隔。

**添加包**：直接写包名
```
luci-app-passwall luci-app-ssr-plus
```

**排除包**：在包名前加 `-`
```
luci-i18n-base-zh-cn -ppp -ppp-mod-pppoe
```

**常用软件包**：

| 包名 | 功能 |
|------|------|
| `luci-app-passwall` | 代理工具 |
| `luci-app-ssr-plus` | SSR 代理 |
| `luci-app-diskman` | 磁盘管理 |
| `luci-app-upnp` | UPnP 服务 |
| `luci-app-vlmcsd` | KMS 激活服务 |
| `luci-theme-argon` | Argon 主题 |
| `kmod-fs-ext4` | ext4 文件系统支持 |
| `kmod-usb3` | USB 3.0 支持 |
| `kmod-tcp-bbr` | BBR 拥塞控制 |

> **提示**：软件包越多，固件越大，需要的 Flash 空间越多。

### rootfs_size - RootFS 分区大小

设置固件中 RootFS 分区的大小（单位：MB）。RootFS 是存放系统文件和已安装软件包的分区。

**根据设备 Flash 大小选择**：

| Flash 大小 | 建议 RootFS | 说明 |
|-----------|-------------|------|
| 16MB | 8-12 MB | 精简系统，仅基本功能 |
| 32MB | 20-24 MB | 基础系统 + 少量插件 |
| 64MB | 48-56 MB | 基础系统 + 常用插件 |
| 128MB | 100-120 MB | 完整系统 + 多数插件 |
| 256MB+ | 200-300 MB | 全功能系统 |

**示例**：
- 16MB Flash 的路由器，填 `8` 或 `12`
- 32MB Flash 的路由器，填 `20`
- 64MB Flash 的路由器，填 `48`
- 256MB Flash 的 Redmi AX6，填 `200` 或 `300`

> **警告**：RootFS 太小会导致无法安装更多插件；太大会增加编译时间和下载大小。

## 默认配置

系统首次启动时会自动执行 `files/etc/uci-defaults/99-custom` 脚本，应用以下配置：

| 配置项 | 默认值 | 说明 |
|--------|--------|------|
| LAN IP | `10.0.0.1` | 路由器管理地址 |
| 主机名 | `Xwrt` | 系统主机名 |
| Root 密码 | `root` | 管理员密码 |
| 2.4G SSID | `康达姆机器人_2.4G` | 2.4G WiFi 名称 |
| 5G SSID | `康达姆机器人_5G` | 5G WiFi 名称 |
| WiFi 密码 | `123*567890` | WiFi 连接密码 |
| 定时重启 | 每周日凌晨 5:00 | 自动重启计划 |
| RootFS 分区大小 | 300 MB | 编译时可调整 |

## 默认软件包

编译时预装以下软件包：

| 包名 | 功能 |
|------|------|
| `luci-app-quickstart` | 快速启动向导 |
| `luci-app-passwall` | 代理工具 |
| `luci-i18n-package-manager-zh-cn` | 软件中心中文语言包 |
| `luci-i18n-firewall-zh-cn` | 防火墙中文语言包 |
| `luci-app-advancedplus` | 高级设置 |
| `kmod-fs-ext4` | ext4 文件系统支持 |
| `kmod-usb-dwc3` | USB DWC3 控制器驱动 |
| `kmod-usb3` | USB 3.0 支持 |
| `kmod-tcp-bbr` | BBR 拥塞控制算法 |
| `swconfig` | 交换机配置工具 |
| `kmod-nft-tproxy` | nftables 透明代理 |
| `kmod-nft-socket` | nftables socket 匹配 |
| `opkg` | 软件包管理器 |
| `luci-app-vlmcsd` | KMS 激活服务 |
| `luci-app-diskman` | 磁盘管理 |
| `luci-app-upnp` | UPnP 服务 |
| `luci-app-timedreboot` | 定时重启 |
| `luci-app-taskplan` | 任务计划 |
| `luci-theme-argon` | Argon 主题 |
| `luci-app-wizard` | 设置向导 |
| `luci-i18n-base-zh-cn` | 基础中文语言包 |

## 目录结构

```
.
├── .github/workflows/
│   └── build-immortalwrt.yml    # GitHub Actions 工作流定义
├── files/
│   └── etc/uci-defaults/
│       └── 99-custom            # 首次启动自定义配置脚本
├── scripts/
│   ├── install-deps.sh          # 安装编译依赖
│   ├── get-platform.sh          # 获取设备目标平台
│   ├── download-extract.sh      # 下载并解压 ImageBuilder
│   ├── config-repos.sh          # 配置软件源仓库
│   ├── files-general.sh         # 生成系统配置文件
│   └── build-firmware.sh        # 独立编译脚本（备用）
├── del/                         # 临时目录
└── README.md                    # 说明文档
```

## 自定义修改

### 修改默认配置

编辑 `files/etc/uci-defaults/99-custom` 可修改以下配置：

- **网络配置**：IP 地址、主机名
- **无线配置**：SSID、密码、加密方式、快速漫游
- **服务配置**：KMS、Passwall、UPnP、定时重启
- **系统配置**：root 密码、固件描述

### 添加/移除软件包

在 Actions 运行时修改 `packages` 参数：

```
# 添加多个包
luci-app-passwall luci-app-ssr-plus luci-app-dockerman

# 排除默认包
-ppp -ppp-mod-pppoe -ip6tables

# 混合使用
luci-app-passwall -dnsmasq dnsmasq-full
```

## 脚本说明

| 脚本 | 功能 |
|------|------|
| `install-deps.sh` | 安装编译所需的系统依赖（jq, zstd, build-essential 等） |
| `get-platform.sh` | 从 ImmortalWrt API 获取设备目标平台信息 |
| `download-extract.sh` | 下载并解压对应版本的 ImageBuilder |
| `config-repos.sh` | 配置软件源仓库，添加 kiddin9 扩展源 |
| `files-general.sh` | 生成 opkg 配置和自定义软件源 |
| `build-firmware.sh` | 独立编译脚本，包含更多默认配置选项 |

## 注意事项

- 固件编译基于 ImmortalWrt 官方 ImageBuilder
- 默认添加 kiddin9 扩展软件源
- 已禁用签名检查以支持第三方软件源
- 编译过程约需 10-30 分钟，取决于软件包数量
- RootFS 分区越大，编译时间和下载大小越大
- 建议在设备 Flash 容量的 80% 以内设置 RootFS 大小
