# ThinkBook 14p / Tahoe 当前 U 盘说明（2026-10-23）

## 最新状态：修复构建双开已通过本机测试

当前使用 [Kingtous/NootedRed 0f1a6b3 的 Release](https://github.com/Kingtous/NootedRed/actions/runs/39979133573)，同时开启 `-NRedDisplayFix -NRedVideoFix`。两个共享缓存 hook 的原生调用与补丁处理已分离，显示补丁的大型临时数据已移到堆上。用户替换后反馈“完全可用了”。修复前的单开成功、双开失败记录保留为历史，不能再当作当前配置。

[上游 PR #4](https://github.com/steve12311/NootedRed/pull/4) 已提交，尚未合并。三个构建版本、Clang 静态分析和相关回归测试通过。两个入口 wrapper 的 Release 局部栈预留均为 24 字节，不含保存寄存器及后续调用。栈耗尽尚非完全证明的根因：本构建还包含 pre-release.6 之后的上游改动，未实测未修改的 27e75c8 双开基线。

默认打包 profile 改为 `dual`；`experimental` 是同一双开参数的兼容别名，display-only、video-only、baseline 保留供对照。`python scripts/package_efi.py` 会生成双开包。dist/ 仅保存在本地，在本机工作目录打包会保留本机身份，不应直接公开上传。

本次在 U 盘部署前的备份为 `Tahoe-Tools/backups/before-stack-fix-dual-20261023-233922/`，包含原 kext 和 VideoFix 单开配置。保留诊断参数、OpenCore 文件日志和完整 kext dump；没有改动其他驱动。以下内容为诊断与旧交付记录；具体音视频路径、睡眠唤醒和长时间稳定性仍需独立验收。

## 历史诊断与交付记录

## 当前进度与配置

已完成安装，用户确认 baseline 配置能完成欢迎流程并进入桌面。最新反馈整体卡顿明显减轻，Edge 首次启动仍冻结约 10–20 秒。截图确认 Tahoe 26.7.1、Renoir 显卡与 4 GB 显存；音频是否恢复尚待确认。

这里的 baseline 是可进桌面的排障基线，关闭 fork 的两个功能开关不是最终修复，也不能据此宣布硬件视频加速已可用。

最新实机反馈：仅开启 `-NRedDisplayFix` 没有问题，已提升为仓库及打包工具默认配置。此反馈确认单开配置可启动，尚不单独证明 Edge 首开冻结已消失或硬件视频编解码可用。

## fork 功能恢复测试

使用的是 steve12311/NootedRed v0.9.0-pre-release.6（128b980），不是上游原版构建。[该版本说明](https://github.com/steve12311/NootedRed/releases/tag/v0.9.0-pre-release.6) 明确区分渲染修正与实验 VCN 功能，两个开关可独立启用；本机 1002:1638 在实验 VCN 2.2 列表内。入表不等于本机已完成验收。

下一步保持系统、kext、SMBIOS 及 coremedia 设置相同，只比较以下参数。目前已验证双开失败、双关能进桌面、单开 DisplayFix 没有问题；VideoFix 单开尚未验证，仍不能确定双开失败的具体原因，更不能证明永久关闭是正确解决方案。

| 打包 profile | 额外参数 | 用途 |
|---|---|---|
| baseline | 无 | 已确认能进桌面的回退基线 |
| display-only | -NRedDisplayFix | 默认；用户确认单开没有问题，继续观察 Edge 与渲染 |
| video-only | -NRedVideoFix | 单独检查 VCN 与启动稳定性 |
| experimental | 两者同时启用 | 单项通过后再测组合 |

例如 `python scripts/package_efi.py --profile display-only`，输出到本地 dist/。`no-vcn` 是 display-only 的旧别名。测试包未替换当前 U 盘 EFI；请保留已能启动的配置。单项或组合仍 panic 时，需要 panic 首行、完整回溯及 fork 的补丁状态日志，继续定位兼容性或 hook 问题。

公开仓库的 PlatformInfo/Generic 身份字段已清空；本机工作目录和 U 盘保留原身份，未上传带序列号的截图。下文 ZIP 与安装包均为本地交付物，不是 GitHub Release。

当前 E:/EFI 是 display-only + SimpleHDA 1.0.0 的配置：
- MacBookPro16,2、8 核 AMD 补丁和 Darwin 25.4+ TSC 修补保留。
- NootedRed 本体及 -NRedDisplayFix 启用；-NRedVideoFix 关闭。单开 DisplayFix 已经用户验证，VideoFix 单项测试及此前 Double fault 的根因尚未确认。
- Lilu → AppleALC → SimpleHDA 加载，保留原 layout-id 11，SimpleHDA 仅在 Darwin 25.x 启用。
- 不改 SIP 或系统卷；可选 HAL 安装包仅存放在工具目录，尚未安装。
- 音频候选已做 ocvalidate、依赖和文件回读检查，实际扬声器/耳机口/麦克风待测试。

启动方式：F12 直接选择 UEFI U 盘 → OpenCore → 已安装的 macOS。
Ventoy F6 链式启动实测会卡住，后续不用该路径。U 盘原 Ventoy/Mint 文件及内置 Windows EFI 未修改。

## 卡顿规避（需在目标 macOS 执行）

NootedRed 维护者在 issue 235 / discussion 430 给出 Sonoma+ 的 Metal transfer session 规避方法，症状涉及壁纸、头像、欢迎流程、视频等停顿。它与本机现象相符，但尚未通过日志确认本机卡顿就是同一原因。

先用当前 U 盘启动 macOS，在终端执行：

    sh /Volumes/MKINGS/Tahoe-Tools/fix-macos-stutter.sh

脚本会备份原设置到桌面目录，执行以下上游命令，完成后需重启再比较：

    sudo defaults write /Library/Preferences/com.apple.coremedia allowMetalTransferSession -bool NO
    sudo chmod 644 /Library/Preferences/com.apple.coremedia.plist

输入的是 macOS 登录密码，终端不回显密码字符。

验证设置：

    defaults read /Library/Preferences/com.apple.coremedia allowMetalTransferSession

应返回 0。若原键不存在，撤销可用：

    sudo defaults delete /Library/Preferences/com.apple.coremedia allowMetalTransferSession

如果原键已有值，按桌面备份 previous-value.txt 恢复原布尔值，不直接删除已有设置。

上游：https://github.com/ChefKissInc/NootedRed/issues/235

## 验收与采样

先测试声音输出是否出现内置扬声器、耳机口和麦克风，再比较同一场景下周期性停顿是否减轻。恢复 fork 功能时按上表逐项测试，避免同时改动其他设置。

如果声音仍无声或卡顿未改善，在 macOS 运行：

    sh /Volumes/MKINGS/Tahoe-Tools/collect-macos-desktop.sh

约 20 秒后桌面生成 thinkbook-desktop-时间目录，包含显示/Metal 信息、音频设备、kext、最近日志、磁盘 I/O 与 CPU 采样；文件留在本地，不自动上传。优先查看 graphics-audio.txt、recent-log.txt、iostat.txt。诊断文件可能含本机标识，分享前检查。

若加音频驱动后无法进系统，Tahoe-Tools/EFI-before-SimpleHDA.zip 是已经确认能进桌面的旧 baseline 备份，可恢复其 EFI/OC 配置与文件；不要覆盖共享 EFI 分区中的 Microsoft 目录。

## 本地交付

- ThinkBook14p-Tahoe-Final-EFI.zip / ThinkBook14p-Tahoe-Baseline-Audio-EFI.zip：此前 baseline + 音频测试版（不包含最新默认 DisplayFix 改动）；新配置请使用打包工具生成 display-only 包。
- EFI/：相同配置的解压目录。
- InstallAssistant-macOS-Tahoe-26.7.1-25G241.pkg：已下载的 Apple 完整安装包，约 17.1 GiB，已校验 XAR TOC 与全部 1753 个完整性数据块。
- com.apple.recovery.boot/：已核验的 Tahoe 26.6.2（25G83）联网恢复镜像；完整 pkg 与它是不同交付物。pkg 本身不能直接从 Ventoy 启动。

音频来源：https://github.com/laobamac/SimpleHDA/releases/tag/v1.0.0
