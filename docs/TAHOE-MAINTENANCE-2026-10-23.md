# ThinkBook 14p Gen2-ACH：Tahoe 测试版维护记录

本次维护在 Windows 下完成，未写入内置磁盘 EFI，未执行安装、推送或提交。用户已从 U 盘 F12 进入 OpenCore，初版在 Darwin 25.6.0 发生 Non-monotonic time panic；现已补入对应内核适配，修订版仍待重试。当前仍是实验配置，不能称为 Tahoe 已适配成功。

## 设备与原始状态

- Windows 实查：AMD Ryzen 7 5800H，8 个物理核心、16 线程；核显 `1002:1638`；BIOS `GWCN47WW`，日期 2024-01-15。
- 原仓库 HEAD：`5ae1d6e`，OpenCore 1.0.4。更改前完整 EFI 备份：`.maintenance/EFI-before-2026-10-23.zip`，仅保存在本地、已被 Git 忽略。
- 最终 SMBIOS 改为 MacBookPro16,2，并用 OpenCore macserial 生成匹配的序列号/MLB；保留原 UUID/ROM、USB 映射、显示与音频设备属性、定制 DSDT，以及已经回退验证过的触摸板组合。旧配置另存本地备份。
- 保留 VoodooI2C 2.8 和 VoodooI2CHID 原版本：`99ca9d8` 明确记录“revert: I2C 触摸板问题”。原 config 注释写成 2.9.1，本次改为实际版本。

## 旧问题定位

### 1. 电源插拔约半分钟延迟：已确认资源入口缺失，实际因果仍需实测

当前注入的 `EFI/OC/ACPI/DSDT.aml` 中，真实 EC 为 `\_SB.PCI0.LPC0.H_EC`，HID 为 `PNP0C09`。它只有 `XCRS`，没有 `_CRS`。

Windows 下使用 ACPICA `acpidump` 读出了这台设备当前 BIOS 的完整 ACPI 表。实际固件 DSDT 在相同路径拥有 `_CRS`，返回 0x35 字节资源，包括 EC I/O `0x62` / `0x66` 和 GPIO 连接；与注入 DSDT 的 `XCRS` 资源内容一致。

原 config 又启用了无设备/表范围限制的 `04 5F435253 -> 04 58435253` 重命名。它按 AML 字节模式匹配，不能保证只命中 HPET，属于不应保留的宽泛补丁；而当前 SSDT-HPET 是新建 HPET 设备，并没有为真实 EC 恢复 `_CRS`。资源入口缺失会妨碍 EC 驱动正确枚举及建立事件链路，是电源状态只能等待轮询的具体嫌疑。

本次禁用该重命名，新增 `SSDT-EC-CRS.aml`，只在已有 H_EC 下通过 `_CRS -> XCRS()` 补回入口，保持原 DSDT 字节不变。

离线复现：只加载原注入 DSDT，求值 `H_EC._CRS` 返回 `AE_NOT_FOUND`；加入新 SSDT 后返回 0x35 字节资源 Buffer。再加入 Windows 实机导出的 15 张固件 SSDT 和全部已启用附加表，资源求值同样成功，没有命名空间冲突/符号解析错误。单独加载 DSDT 时出现的 `ALIB` 缺失来自没有同时加载固件 SSDT，不能当成机器真实报错；完整表求值消除了该错误。ACPICA 退出仍有缓存分配统计提示，不能描述为整份固件“零警告”。

其他结论：

- `_Q10` 已经通知 BAT0 与 ADP1；通知前等待 300 ms，后面另有 600 ms 等待。这两段本身不能解释半分钟延迟。
- `XL10` 在 Windows 读出的原始 BIOS DSDT 中就存在，不能归咎于旧 EFI，也不能凭名称直接改回 `_L10`。本次没有新增或改写 GPE 中断方法。
- `RMDT.P1` 的定义实际内嵌在注入 DSDT 尾部，因此 SSDT-RMDT 未启用并不表示这些调试调用必然失败。本次保留它。
- `ECRD` 的 ECMT 锁等待上限为 `0xA000`（40960 ms）。这只是超时上限，尚无证据表明实际发生锁竞争；如补回资源后仍延迟，再核对 EC 日志、通知到达时间与此锁的耗时。
- 旧 ACPIBatteryManager、SSDT-BATT、SSDT-AC 均未启用；没有与 SMCBatteryManager 同时加载。SSDT-AC 只定义 `_PRW`，启用它不能修复通知，还可能与已有定义冲突。

因此，**已修补确定的静态缺陷，但“30 秒延迟已解决”必须等实机测试才能下结论**。

### 2. NootedRed 硬解

原驱动有桌面/Metal 加速，不等于具有完整 VideoToolbox 硬解。按用户指定切换为 [steve12311 v0.9.0-pre-release.6](https://github.com/steve12311/NootedRed/releases/tag/v0.9.0-pre-release.6)，提交 `128b98067387e0ee49692d424b8543de5739bd6a`。

- `1002:1638` 属于该分支声明的实验 VCN 2.2 设备。
- 使用新参数 `-NRedDisplayFix -NRedVideoFix`；前者启用显示修复，后者显式请求实验硬解/编码。
- 不启用 `NRedECFix=1`：这是针对特定固件的背光功能，与充电状态通知不同，现有亮度路径没有理由一起更改。
- 发布说明明确：非官方实验分支，多系统实机验收和长期稳定性仍待完成，VCN 1.x 不支持，完整 FairPlay 视频 DRM 不保证。
- 该版本在 Sonoma/Sequoia 依赖特定参考缓存，不能拿新包直接替换旧系统的工作 EFI 后假设兼容；本次包以 Tahoe 试装为目标。

### 3. Tahoe 启动前置条件

原 AMD 补丁大部分止于 Darwin 24，无法承担 Tahoe 的 Darwin 25。本次同步 [AMD-OSX/AMD_Vanilla](https://github.com/AMD-OSX/AMD_Vanilla) 提交 `eaf52ef292abf4ebec899df6d48626569ba50cc6` 的完整补丁集，四条核心数补丁均设为物理 8 核 `08`，保留 `ProvideCurrentCpuInfo=true`。保留原来 Sonoma 及以前的 Shaneee PAT 选择；Sequoia/Tahoe 仍采用 Algrey/Zormeister PAT；两种 PAT 不同时启用。

MacBookPro16,3 不在 Tahoe 支持机型中。最终按 [NootedRed 当前官方指南](https://chefkiss.dev/applehax/nootedred/) 改用 MacBookPro16,2，生成匹配的序列号和 MLB，保留硬件 UUID/ROM；`PlatformInfo/Automatic=true` 使 OpenCore 根据该机型填充平台信息。已经移除初版测试配置的 `-no_compat_check`，保留 RestrictEvents 的 `revpatch=auto,sbvmm`。参考 [Apple 支持机型](https://support.apple.com/en-us/122867)。

[NootedRed #404](https://github.com/ChefKissInc/NootedRed/discussions/404) 确认更换 SMBIOS 能解决部分 5800H/Tahoe 启动图形问题，维护者表示指南已针对被淘汰的机型更新，但原帖未明确区分更换前后的型号，不能据此独自认定目标机型。[AMD-OSX 的 16,4 讨论](https://forum.amd-osx.com/threads/bios-16-4.6464/) 中专家确实建议 16,4，但同帖作者表示 16,2 可工作、切到 16,4 无显示，随后仍持续报告黑屏，因此不能算作 16,4 成功装机证据。本次以 NootedRed 官方当前明确列出的笔记本机型 16,2 为基准，实际图形功能仍待本机测试。

## 首次实机启动后的 TSC 修订

用户照片显示 `Non-monotonic time: invoke at ... runnable at ... @sched_prim.c:3851`，Darwin 25.6.0、机型 MacBookPro16,2，系统初始化前即 panic。它首先指向线程时间检查/TSC 路径，不能凭回溯中的 AppleACPIPlatform 就断定是电池 SSDT，也不能直接归因于 VCN。

主分支旧线程补丁仍声明到 25.99.99，但 Darwin 25.4 后相关偏移从 0x48x 改为 0x490，旧掩码无法覆盖目标位置。[AMD_Vanilla PR #215](https://github.com/AMD-OSX/AMD_Vanilla/pull/215) 尚未合并；本次从提交 `a174cca80efe2377fde3b902666c70863ea66454` 仅导入 TSC 变更：旧 `thread_invoke, thread_dispatch` 补丁上限收窄到 25.3.99，新增 25.4.0–25.99.99 的对应补丁。该 PR 的另一项 PCI 改动未导入，其他 kext、机型和参数不变。

已提取本次恢复镜像 25G83 的实际 BootKernelExtensions.kc。按新补丁掩码、搜索顺序和 Count=2，两个目标位于文件偏移 0x18ed52 与 0x18fcda，原指令均使用 0x490，旧补丁在这两个位置均不匹配；离线替换验证保留前七字节指令，仅以 NOP 替换后六字节条件跳转。详见 [内核匹配证据](tsc-patch-25G83-evidence.json)。这不等于实机验证成功，也不证明物理 TSC 已完全同步；ForgedInvariant 保留，后续仍要检查运行和休眠稳定性。

用户实测 Ventoy F6 链式启动会卡住，F12 直接选择 U 盘可进入 OpenCore。后续走 F12 直接启动路径，F6 菜单不再推荐。

## 组件版本

| 组件 | 原实际版本 | 本次版本 |
|---|---|---|
| OpenCore、BOOTx64、随包可匹配的 drivers/tools | 1.0.4 | 1.0.8 RELEASE |
| Lilu | 1.7.0 | 1.7.2 |
| VirtualSMC / SMCBatteryManager / SMCLightSensor | 1.3.4 | 1.3.8，同一发行包 |
| NootedRed | CFBundleVersion 1.0.0 的旧构建 | 0.9.0-pre-release.6（fork 版本体系不同） |
| AppleALC | 1.9.4 | 1.9.8 |
| RestrictEvents | 1.1.5 | 1.1.6 |
| NVMeFix | 1.1.2 | 1.1.3 |
| BlueToolFixup | 2.6.9 | 2.7.2 |
| ECEnabler | 1.0.5 | 1.0.6（新增 Tahoe 范围） |
| ForgedInvariant | 1.0.0 | 1.5.0（TSC 同步修正） |
| USBToolBox | 1.1.1 | 1.2.0（Tahoe 支持仍标 WIP） |
| Tahoe Wi-Fi | itlwm 2.3.0 + HeliPort | laobamac AirportItlwm 2.4.0-alpha，构建 738d4c6 |

[下载来源与 SHA-256](components-2026-10-23.json) 记录了所有 12 个发行包；下载摘要已与 GitHub 发行资产 digest 核对。kext 整包替换，避免新旧二进制/Info.plist 混装。

Lilu 1.7.2 的发布说明包含 Tahoe AMDSupport 锁死/panic 修复；VirtualSMC 1.3.8 包含电池与电源通知修正，但没有据此宣称它修好了本机的插拔延迟。

其他配置调整：

- 按 OpenCore 1.0.8 新增 `Booter/Quirks/ClearTaskSwitchBit`、Driver `HideVerbose`、`UEFI/Unload` 字段。
- USBToolBox 放在 UTBMap 前，核对全部启用的非 Apple kext 依赖均存在。
- FeatureUnlock 限制到 Darwin 24，Tahoe 暂不加载旧的额外功能解锁。
- 移除旧的 `-lilubetaall`、`-revbeta`、`-alcbeta`、`-vsmcbeta` 和 `-ChefKissInternal`；新版关键组件已有 Tahoe 版本范围。
- NVRAM Delete 中加入 `boot-args`，确保新参数不被此前存储的旧值遮蔽；保留日志但关闭每次启动的完整 SysReport。
- IntelBluetoothFirmware/IntelBTPatcher 保留原 2.5.0 构建：上游当前 stable 2.4.0 比本机版本更低，不能把降级冒充更新。CPU 管理/传感器、触摸板、USB 映射等没有依据时不替换，其 Tahoe 工作情况待测。
- 历史未加载驱动与 ACPI 文件保留在源码树；发布 ZIP 仅包含启用的顶层组件及所需子插件/资源，不夹带旧 NootedRed 备份。

## Tahoe 尚存的功能边界

**内置 ALC257/ALC3287 音频：** Tahoe 移除了 AppleHDA，更新 AppleALC 本身不能恢复扬声器/耳机口。现有布局和 AppleALC 保留，待选定音频恢复方案后继续适配；当前可先用 USB 音频设备完成安装测试。没有自动修改 SIP 或系统卷。参考 [Dortania Tahoe 说明](https://dortania.github.io/OpenCore-Install-Guide/extras/tahoe.html) 和 [AppleALC README](https://github.com/acidanthera/AppleALC)。

**Wi-Fi：** 根据用户提供的 [laobamac/itlwm 发行页](https://github.com/laobamac/itlwm/releases)，默认改用 `AirportItlwm-Tahoe-v2.4.0-RELEASE-alpha-738d4c6.zip`，在 EFI 中单独保存为 `AirportItlwm-Tahoe.kext`。Windows 实查无线网卡为 Intel AX200 `8086:2723`，属于上游支持设备系列；本机 Tahoe 连接仍待测。

新驱动只在 Darwin `25.0.0–25.99.99` 加载；旧 itlwm 限制到 Darwin `24.0.0–24.99.99`，原 Sonoma/Monterey AirportItlwm 仍禁用，避免两种 Wi-Fi 驱动同系统并载。Tahoe 下使用系统原生 Wi-Fi 界面，无需 HeliPort，也不注入旧 IOSkywalk/IO80211 补丁或修改系统卷。

该分支仍是 alpha，发布说明要求逐设备硬件验证。依其 [README](https://github.com/laobamac/itlwm/blob/main/README.md)，支持扫描、连接、切换网络和私有 Wi-Fi 地址；Wi-Fi 6/HE 默认关闭，本次未添加 `itlwm_he=1`。WPA2-Personal 与可选 PMF 的 WPA2/WPA3 混合网络可测试；WPA3-only、强制 PMF、AWDL/AirDrop 和 MLO 不支持。不能把原生菜单可用等同于 AirDrop/全部连续互通可用。

额外交付 `no-vcn-itlwm` 包，用原 itlwm + HeliPort 做 Wi-Fi 回退；不与新 AirportItlwm 同时加载。仍建议准备完整离线安装介质或可用有线网络，安装器无线功能未实测。

**其他：** 蓝牙、亮度、HDMI、休眠唤醒、触摸板、CPU 功耗和音频均需 Tahoe 实测；Windows 检查不能替代这些验收。

## 安装与回退顺序

`dist/` 下四份 ZIP 都以 `EFI/` 为顶层，只选一份解压到测试 U 盘 EFI 分区，先保留原磁盘 EFI：

1. **no-vcn**：建议先用它建立启动和电源行为基线；保留 NootedRed 显示修复，但不请求 VCN。
2. **experimental**：能进桌面后切换，启用 `-NRedVideoFix` 测硬解。
3. **installer**：若安装界面黑屏/图形异常，用它排障；`-NRedOff` 关闭 NootedRed，加速不可用，这是安装排障选项，并不保证所有图形问题都能绕过。
4. **no-vcn-itlwm**：新 AirportItlwm 有问题时的无线回退版；只在这份 Tahoe 配置中改回 itlwm + HeliPort。

前三份包均默认使用新版原生 AirportItlwm。

从固件启动菜单明确选择测试 U 盘。不要只覆盖 config 而混用另一份 OpenCore/驱动。启动后核对 `nvram boot-args`；如仍有旧 NVRAM 状态，可在 OpenCore 菜单按空格显示辅助项再运行 Reset NVRAM（会清除相关持久变量并可能影响启动项），重启后重新选 U 盘。

若新包无法启动，恢复原备份完整 EFI 并选择原系统；旧包没有 Tahoe 内核补丁，不能当成 Tahoe 备用引导。若只有 VCN 导致挂起，使用 no-vcn 包；若亮度或 EC 出现倒退，先关闭 `SSDT-EC-CRS.aml` 单独做对照，不要一起改 GPE/EC 寄存器。

最终 ZIP 包含生成的 MacBookPro16,2 序列号/MLB，并保留本机原 UUID/ROM。身份数据未打印在聊天中；包含这些字段的包不适合作为通用公共发行包。更换机型和身份后，已有 Apple 服务可能需要重新登录。

## 验证与后续采样

已完成：OpenCore 1.0.8 `ocvalidate` 主配置和四份解压后配置均通过；主配置 32 个启用 bundle（含按内核范围互斥的无线驱动）的路径、Mach-O、非 Apple 依赖、EFI PE 头、已启用 ACPI 长度/校验和、8 核和 Tahoe 范围检查通过；Tahoe 只选择一套 Wi-Fi 驱动；新增 AML 编译 0 错误/0 警告；EC 资源求值前后对照通过；`git diff --check` 通过。

复查命令（仓库根目录）：

```powershell
python scripts/validate_efi.py
python scripts/package_efi.py --profile no-vcn
python scripts/package_efi.py --profile experimental
python scripts/package_efi.py --profile installer
python scripts/package_efi.py --profile no-vcn --wifi itlwm
.\.maintenance\OpenCorePkg\Utilities\ocvalidate\ocvalidate.exe EFI\OC\config.plist
.\.maintenance\acpica\iasl.exe -p EFI/OC/ACPI/SSDT-EC-CRS DSDT/SSDT-EC-CRS.dsl
```

进入目标 macOS 后，在本仓库运行：

```sh
sh scripts/collect-macos.sh
```

采集脚本在桌面创建本地诊断目录，记录系统 build、启动参数、kext、ACPI、电池和 NRed 诊断字段，并连续约 90 秒采样电源状态。在此期间分别插拔一次，记下实际操作时间；不自动发送任何数据。日志/IORegistry 可能含设备标识，分享前检查。

电源验收比较实际插拔时间、`ExternalConnected`、`pmset` 的 AC/Battery 切换与 UI 提示；若 IORegistry 已即时切换而 UI 仍延迟，应转查电源管理/UI 通知，不能继续盲改 EC。

视频验收使用正常分辨率的本地 H.264 与 HEVC，分别测试播放、寻址、停止再开、空闲 5 分钟后再开，以及持续播放。记录 VideoToolbox 的 `UsingHardwareAcceleratedVideoDecoder` 属性、解码错误与 WindowServer/GPU reset。`NRedVCNRequested`、ABIValidated 或 UserEnabled 仅代表请求/校验，CPU 占用低或浏览器播放流畅也不足以证明硬解。FairPlay 视频需单独看待，不能用 Apple TV DRM 播放作为唯一硬解判据。

如仍延迟，下一轮优先查看真实 IORegistry 中 AppleACPIEC 是否绑定 H_EC、EC `_Q10` 是否到达、SMCBatteryManager 是否收到通知和 ECMT 锁耗时，再决定是否需要 ACPI 事件桥接。
