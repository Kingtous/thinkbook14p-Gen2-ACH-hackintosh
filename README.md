# Hackintosh for ThinkBook 14p 2021 Gen2-ACH

PDF: [ThinkBook_14p_G2_ACH Reference](https://psref.lenovo.com/syspool/Sys/PDF/ThinkBook/ThinkBook_14p_G2_ACH/ThinkBook_14p_G2_ACH_Spec.pdf)

## macOS Tahoe 26.7.1（2026-10-23）

Ryzen 7 5800H / Vega `1002:1638` / 32 GB / AX200 已在 SSK USB SSD 上完成安装、通过欢迎流程并进入桌面。截图显示 Tahoe 26.7.1、AMD Radeon RX Renoir Graphics、4 GB 显存；这不等同于已经验证硬件视频编解码。

- OpenCore 1.0.8，SMBIOS `MacBookPro16,2`，更新核心 kext；保留本机 USB 映射、定制 DSDT 和已回退验证的触摸板组合。
- 使用 **[steve12311/NootedRed v0.9.0-pre-release.6](https://github.com/steve12311/NootedRed/releases/tag/v0.9.0-pre-release.6) fork**，并非 ChefKissInc 原版构建。NootedRed 本体及 `-NRedDisplayFix` 启用，用户已确认单开 DisplayFix 可正常启动；`-NRedVideoFix` 保持关闭。此前双开曾出现 Double fault，VideoFix 单开与组合兼容性仍待定位。默认打包 profile 为 `display-only`，双关的 `baseline` 保留用于回退。
- AMD 8 核补丁及 [AMD_Vanilla PR #215](https://github.com/AMD-OSX/AMD_Vanilla/pull/215) 的 Darwin 25.4+ TSC 修补；只引入 TSC 部分，未引入该 PR 的 PCI 改动。
- Tahoe 使用 laobamac AirportItlwm；AppleALC + SimpleHDA 1.0.0 为音频候选，音频尚待用户验收。
- 最新反馈：整体卡顿明显减轻，Edge 首次打开仍冻结约 10–20 秒。硬件视频编解码、电源通知延迟、睡眠唤醒仍待验证，不能将原版 NootedRed 的问题直接视为此 fork 的诊断结论。

**公开配置中的序列号、MLB、UUID、ROM 已清空，使用前请自行生成并填写 `PlatformInfo/Generic`，机型保持 `MacBookPro16,2`。** 本机可启动配置及安装包仅保存在本地，不随仓库发布。截图包含本机序列号，未提交原图。

从 F12 直接选择 UEFI U 盘进入 OpenCore；本机 Ventoy F6 链式启动会卡住。

见 [当前配置、卡顿规避与音频验收（中文）](docs/TAHOE-FINAL-USB-2026-10-23.md) 和 [完整维护记录](docs/TAHOE-MAINTENANCE-2026-10-23.md)。


## EFI Details

The compatibility results below are historical (2024); they do not establish Tahoe compatibility.

- latest **stable** support👍: 14.5 stable+. (the best experience)
- latest **beta** support👷🧱: macOS 15.1.1 (24B91)

![截屏2024-12-08 12 48 10](https://github.com/user-attachments/assets/db0c9fcb-bb04-40c4-a17f-bad265568cbc)

|Properties|Detail| Works(stable)? | Works(beta)? |
|---|-----|--|--|
|CPU|AMD Ryzen 7 5800H| YES| YES|
|Memory|32G| YES|YES|
|GPU|Vega 8(integrated GPU)| YES|YES|
|Sound|ALC3287(ALC257, layout-id=11)|YES|YES|
|HDMI|Vega 8(integrated GPU)|YES|YES|
|Network Card| AX200 WiFi6|YES|PART(with itlwm+heliport only, and doesn't work with AirportItlwm)|
|iCloud|Sync|YES|YES|
|Camera (HID)|FaceTime|YES|YES|
|Bluetooth|AX2000 WiFi6|YES|YES|
|Battery|![截屏2023-09-06 01 45 33](https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/105d003c-ba13-4ee9-85b9-3988d7ffb01f)|YES|YES|


## How to grab my latest EFI

The latest **stable** EFI will always have a snapshot release and I have already placed it in [Github Release Page](https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/releases).

The latest experimental EFI is on the `main` branch. Generate your own platform identity before use; the historical stable releases below do not establish Tahoe compatibility.


## Credits

- Apple for macOS

QQ Group:

<p><img src="https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/bd834b10-c755-4745-83b3-feadd75e0051" width=300></img></p>


## Question

### Chrome is about to freeze the whole macOS when opening.

A: This is a historical NootedRed graphics issue. Graphics/Metal acceleration and hardware video encoding/decoding are separate capabilities; this tree's newer fork provides experimental VCN video support. See the Tahoe notes above for testing and fallback options. The original [NootedRed Chrome guidance](https://chefkissinc.github.io/nred#chrome-chromium-based-browsers-and-apps-like-sublime-text-cause-graphical-artefacts-amongst-other-problems) remains a reference for older builds.
