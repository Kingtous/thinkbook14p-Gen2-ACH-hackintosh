# Hackintosh for ThinkBook 14p 2021 Gen2-ACH

PDF: [ThinkBook_14p_G2_ACH Reference](https://psref.lenovo.com/syspool/Sys/PDF/ThinkBook/ThinkBook_14p_G2_ACH/ThinkBook_14p_G2_ACH_Spec.pdf)

This EFI aims to work with `macOS Sonoma` now. Stay tuned :)

latest support: macOS Sonoma 14.3.1 stable.

Note: PLZ do not update to 14.4 beta and newer, many issues related to AirportItlwm, NootedRed has reported recently.

![image](https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/02f40418-6ff5-49aa-8fae-fe562e95be5f)


|Properties|Detail| Works? |
|---|-----|--|
|CPU|AMD Ryzen 7 5800H| YES|
|Memory|32G| YES|
|GPU|Vega 8(integrated GPU)| YES|
|Sound|ALC3287(ALC257, layout-id=11)|YES|
|HDMI|Vega 8(integrated GPU)|YES|
|Network Card| AX200 WiFi6|YES|
|iCloud|Sync|YES|
|Camera (HID)|FaceTime|YES|
|Bluetooth|AX2000 WiFi6|YES|
|Battery|![截屏2023-09-06 01 45 33](https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/105d003c-ba13-4ee9-85b9-3988d7ffb01f)|YES|


## Credits

- Apple for macOS

QQ Group:

<p><img src="https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/bd834b10-c755-4745-83b3-feadd75e0051" width=300></img></p>


## Question

### Chrome is about to freeze the whole macOS when opening.

A: This is an upstream issue of NootedRed, which is the AMD graphic driver which is responsible for accelerate video encoding/decoding. Please check [NootedRed Guide for configuring Chrome](https://chefkissinc.github.io/nred#chrome-chromium-based-browsers-and-apps-like-sublime-text-cause-graphical-artefacts-amongst-other-problems) to solve it.
