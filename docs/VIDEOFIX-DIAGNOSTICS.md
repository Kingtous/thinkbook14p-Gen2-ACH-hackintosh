# VideoFix 启动崩溃采样

> 以下为修复前诊断记录。当前用户已验证新构建双开可正常使用；最新状态见 [U 盘说明](TAHOE-FINAL-USB-2026-10-23.md)。

当前已知：DisplayFix 单开可启动，双开后启动崩溃。VideoFix 单开尚未测试，不能区分 VideoFix 本身与两组补丁的交互。旧日志是 launchd 的 Double fault，尚无最新失败测试的 panic 文件。

## 已准备的配置

本机 U 盘 `Tahoe-Tools/VideoFix-Diagnostics/` 下保存以下带本机身份的配置，仅留本地，不提交仓库：

- `restore-display-only.plist`：准备时的可启动配置，原样备份。
- `display-only-logging.plist`：DisplayFix 单开，增加日志设置。
- `video-only-logging.plist`：仅 VideoFix，用于区分单项与组合问题，尚未实机验证。
- `both-logging.plist`：两个开关都开，复现原问题，尚未实机验证。

本次准备不修改活动 `EFI/OC/config.plist`，不清除 NVRAM，不替换 kext。下次需要复现时，将选中的配置复制为 U 盘 `EFI/OC/config.plist`；失败后用 restore 文件恢复。首先用 display-only-logging 验证日志配置本身，再保持其余条件相同进行 video-only 测试。

日志配置保留 `-v debug=0x100 keepsyms=1`，增加 `msgbuf=1048576`；`Misc/Debug/Target=67` 启用安全方式的文件日志，保留 AppleDebug/ApplePanic；将 `Kernel/Quirks/PanicNoKextDump` 设为 false，尝试保留已加载 kext 的地址/UUID，方便将回溯地址映射到函数。完整 kext 列表可能刷走屏幕前面的 panic 行，测试时从启动前开始录视频。

OpenCore 仍是现有 RELEASE 构建，文件日志详细程度有限。预计 U 盘根目录出现 `opencore-*.txt`；ApplePanic 机制成功时可能有 `panic-*.txt`。这些文件都不能保证保存启动早期的崩溃；OpenCore 文件日志也不是 macOS 内核控制台的完整记录。

## 回到可启动配置后收集

在 macOS 终端执行：

```sh
sh /Volumes/MKINGS/Tahoe-Tools/collect-videofix-diagnostics.sh
```

桌面生成 `thinkbook-videofix-时间.zip`。包含近期 panic/GPU 重置、内核日志、当前加载驱动、当前 NRed 属性和 NVRAM、U 盘根目录日志。当前 boot-args/dmesg/IORegistry 来自恢复后的成功启动，不能当作失败那次的状态。早期日志未写盘时，这个脚本不能补回丢失的数据。

## fork 自带日志和进一步插桩

固定源码 128b980 的 `UserVideoDecode.cpp` 已使用 SYSLOG 输出 `stage=N` 和错误码，并设置 `NRedVCNUserD00..D15`、`NRedVCNUserLastError`、`NRedVCNUserEnabled`、`NRedVCNUserDynamicMatched/Applied` 等属性。Enabled 表示注册，不等于成功写入或硬解可用。

阶段编号：0 Called，1 OriginalError，2 Argument，3 CacheRead，4 CacheMismatch，5 CodeRead，6 CodeMismatch，7 Already，8 Mixed，9 NoMap，10 Region，11 Protection，12 Write，13 Restore，14 Rollback，15 Applied。每个阶段只首次输出一次，不能将 stage 数字简单理解为连续进度。

Display 和 Video 两个模块都 route `_shared_region_check_np`。结合旧 launchd Double fault，优先检查两个 hook 的调用链、栈占用及共享缓存读写；这是待验证方向，尚非根因结论。需要定制构建时，可在两个 wrapper 的调用原函数之前/之后、缓存解析前后、页面权限变更前后加入有次数限制的 SYSLOG（含模块、PID、入口/返回和错误码），避免每次系统调用都刷屏。需要目标 macOS 构建环境；目前未修改或编译 fork，也未宣称有可用的定制 kext。

发布资产当前只提供 NootedRed RELEASE。`-NRedDebug` 虽然在入口声明，但通常的 DBGLOG 在 RELEASE 编译中被移除；仅加参数不能恢复被编译掉的日志。Lilu 的 `-liludbgall`、`liludump=N` 也需要 DEBUG 构建，且写文件时机可能晚于这次崩溃，故没有直接塞入当前配置。

参考：[fork 版本说明](https://github.com/steve12311/NootedRed/releases/tag/v0.9.0-pre-release.6)、[Lilu 调试参数](https://github.com/acidanthera/Lilu#configuration)、[OpenCore 1.0.8 配置文档](https://github.com/acidanthera/OpenCorePkg/blob/1.0.8/Docs/Configuration.pdf)。
