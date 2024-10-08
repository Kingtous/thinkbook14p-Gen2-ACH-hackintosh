# Hackintosh for ThinkBook 14p 2021 Gen2-ACH

PDF: [ThinkBook_14p_G2_ACH Reference](https://psref.lenovo.com/syspool/Sys/PDF/ThinkBook/ThinkBook_14p_G2_ACH/ThinkBook_14p_G2_ACH_Spec.pdf)

This EFI aims to work with `macOS Sequoia` now. Stay tuned :)


## EFI Details

- latest **stable** support👍: 14.5 stable+. (the best experience)
- latest **beta** support👷🧱: macOS Sequoia beta 15.0(24A5320a)

![image2](https://github.com/user-attachments/assets/44a52777-0d41-4879-bcf4-a623f381f52d)

![image](https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/02f40418-6ff5-49aa-8fae-fe562e95be5f)


|Properties|Detail| Works(stable)? | Works(beta)? |
|---|-----|--|--|
|CPU|AMD Ryzen 7 5800H| YES| YES|
|Memory|32G| YES|YES|
|GPU|Vega 8(integrated GPU)| YES|YES|
|Sound|ALC3287(ALC257, layout-id=11)|YES|NO(wait for the fix from AppleALC)|
|HDMI|Vega 8(integrated GPU)|YES|Not Tested|
|Network Card| AX200 WiFi6|YES|PART(with itlwm+heliport only, and doesn't work with AirportItlwm)|
|iCloud|Sync|YES|YES|
|Camera (HID)|FaceTime|YES|YES|
|Bluetooth|AX2000 WiFi6|YES|YES|
|Battery|![截屏2023-09-06 01 45 33](https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/105d003c-ba13-4ee9-85b9-3988d7ffb01f)|YES|YES|


## How to grab my latest EFI

The latest **stable** EFI will always have a snapshot release and I have already placed it in [Github Release Page](https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/releases).

The latest **beta** EFI will always be the latest commit on the master branch of this repo. Just clone it and use it.


## Credits

- Apple for macOS

QQ Group:

<p><img src="https://github.com/Kingtous/thinkbook14p-Gen2-ACH-hackintosh/assets/39793325/bd834b10-c755-4745-83b3-feadd75e0051" width=300></img></p>


## Question

### Chrome is about to freeze the whole macOS when opening.

A: This is an upstream issue of NootedRed, which is the AMD graphic driver which is responsible for accelerate video encoding/decoding. Please check [NootedRed Guide for configuring Chrome](https://chefkissinc.github.io/nred#chrome-chromium-based-browsers-and-apps-like-sublime-text-cause-graphical-artefacts-amongst-other-problems) to solve it.
