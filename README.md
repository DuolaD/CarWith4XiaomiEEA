# CarWith4XiaomiEEA

**English** | [简体中文](README.zh-CN.md) | [繁體中文](README.zh-TW.md)

A Magisk / KernelSU module that brings CarWith, the car connectivity feature from China HyperOS, to Xiaomi phones running EEA or Global ROMs.

Xiaomi only ships CarWith (`com.miui.carlink`) on its China ROMs. If you use an EEA or Global phone in mainland China, you can't connect it to a CarWith or EasyConnect head unit. This module adds the two missing pieces from the China ROM so you can.

## Tested on

| Item | Version |
|---|---|
| Device | Xiaomi 15 (`dada`) |
| ROM | HyperOS OS3.0.303.0.WOCEUXM (EEA, Android 16) |
| Root | KernelSU 3.3.1 + Zygisk Next 1.5.2 |
| CarWith | 4.0.3-20260513, taken from OS3.0.303.0.WOCCNXM |

That's the only setup tested so far. The installer doesn't check device model or ROM version, so you can try it on other Xiaomi phones. If it works or breaks for you, please [open an issue](../../issues) with your device and ROM version.

### Tested

- EasyConnect (亿连) - Wireless - Hotspot connection
- Smart navigation handoff
- Media audio

- Amap (17.02.2.2014, installed from Google Play Store)
- Spotify (9.1.98.614, marked by CarWith as experimental, installed from Google Play Store)
- Bilibili (8.85.0, mainland China release, not the international version; marked by CarWith as experimental, installed from Aurora Store)


### Untested

- Baidu Maps
- Xiao Ai (the test device doesn't have the China-ROM-only Xiao Ai assistant installed, and CarWith can't use Gemini on the international ROM)
- App store (the test device doesn't have the China-ROM-only app store installed)
- Other CarWith apps
- Other apps marked by CarWith as experimental

- Call audio
- Other CarWith features


### Known issues

- None yet

## What it does

The module adds these two files from the China ROM:

- `/product/app/CarWith/CarWith.apk`, the CarWith app
- `/system_ext/framework/miui.car.server.jar`, the `MiuiCarService` system service

It doesn't need LSPosed and doesn't patch SELinux. The EEA ROM already has most of what CarWith needs. Its `services.jar` loads `miui.car.server.jar` whenever the file exists. The SELinux context and `miui.car.permission.*` permissions are already defined. The Settings entry is already there and only shows up once CarWith is installed. China and EEA ROMs are also signed with the same platform key, so CarWith gets its signature-level permissions.

Most root-hiding setups (Zygisk Next, KernelSU's "umount modules by default", and so on) hide module files from normal apps. CarWith would then crash on launch because it can't open its own APK. To get around this, after boot the module installs the same APK again as a system app update in `/data/app`, where every process can see it.

## Install

1. Download the latest zip from [Releases](../../releases).
2. Flash it in KernelSU, Magisk, or APatch, then reboot.
3. Wait about a minute after boot. The module description shows the status:
   - ✅ CarWith is installed and `MiuiCarService` is running.
   - ⚠️ CarWith is installed, but `MiuiCarService` isn't running.
   - ❌ The system can't see CarWith.
4. Open CarWith from **Settings > Connection & sharing > CarWith**. You can also tap the module's **Action** button in your root manager.

The installer refuses to run in two cases: on China ROMs, which already have CarWith, and when `/product/app/CarWith` already exists in the system.

## Connection methods

- EasyConnect (亿连) is built into CarWith and works without anything else.
- CarLife needs the separate plugin `com.baidu.carlife.xiaomi`, which China ROMs don't bundle either. CarWith downloads it through the China Xiaomi app store (`com.xiaomi.market`), which EEA and Global ROMs don't have. To use CarLife, install the plugin APK yourself or install the China Xiaomi app store.

## Known limitations

- Xiao Ai voice assistant, the China app store, and other China-only Xiaomi apps aren't on EEA or Global ROMs. CarWith features that depend on them won't work.
- Install navigation and music apps yourself, such as Amap, Baidu Maps, QQ Music, or NetEase Cloud Music.
- Projection may lag a bit on low-end head units.

## Action button

Tap **Action** on the module in KernelSU or Magisk. It shows:

- the CarWith install path and version
- whether `MiuiCarService` is running
- the module's `guard.log`

After that it opens CarWith's settings page. If something goes wrong, include a screenshot of this page in your issue.

## Boot-loop protection

- If the phone fails to boot 3 times in a row, the module disables itself.
- During boot, if `system_server` restarts 3 times or the boot animation is still running after 5 minutes, the module disables itself and reboots.

If either happens, the reason is written to `/data/adb/modules/carwith_eea_port/guard.log`.

## Uninstall

Remove the module in your root manager and reboot. About 15 seconds after the next boot, the module also uninstalls the copy of CarWith in `/data/app`.

## Using a modified CarWith

Some people publish modified builds of CarWith. To use one, replace `CarWith.apk` in the module:

1. Download the module zip from [Releases](../../releases).
2. Open the zip with an app that can edit archives, such as MT Manager or ZArchiver, and find `system/product/app/CarWith/CarWith.apk`.
3. Rename the modified APK to `CarWith.apk` and replace the original. Leave the other files alone.

   On a computer, unzip the module, replace the file, then go into the extracted folder and zip everything inside it. Don't include the outer folder, or your root manager will refuse to install it.
4. If you already have the original module installed, remove it in your root manager and reboot first. About 15 seconds after boot, the old copy of CarWith is uninstalled automatically. Then flash the modified zip. The modified APK is signed with a different key, so flashing it over the original may fail or leave the old version running.
5. Reboot after flashing.

Things to keep in mind:

- The modified APK must keep the package name `com.miui.carlink`. Otherwise the Settings entry and the module's status check can't find it.
- Modified builds are usually re-signed by their authors, so they lose Xiaomi's platform signature and its signature-level permissions. Some features may not work. Report those problems to the author of the modified build first.
- A modified APK from an unknown source can contain malware. Only download from people you trust.
- If the module description shows ❌ after boot, or CarWith won't open, tap the Action button and check the `installed /data copy` line in the log.

## Building

Pushing a GitHub Release triggers `.github/workflows/release.yml`. It sets the module version to the release tag, packs `module/` into `CarWith4XiaomiEEA-<tag>.zip`, and uploads it to the release.

`versionCode` comes from the numbers in the tag, as `major × 10000 + minor × 100 + patch`:

- `v1.2.3` → `10203`
- `26.11.05` → `261105`

Stick with one tag scheme so `versionCode` keeps going up.

To build by hand, zip the contents of `module/`, not the folder itself.

`tools/dexrefcheck.py` checks whether the framework methods and fields a jar or APK references exist on the target ROM. It's useful when porting to a new ROM version.

## Screenshots

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/7c8c8328-a8e4-4a2d-9b2f-d4c46c3a09d2" />

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/5e6ba6be-a0cd-4378-afaf-5c2fec41b740" />

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/0d8f731c-37aa-483c-8107-9604dbdd132f" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/55650d15-f4e3-459a-bde6-dbd708c5a24e" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/9ba3112c-3d21-4758-a39f-9dbbf4cc68a7" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/943aa4da-0d34-454a-8be4-006a81aeafaa" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/9eafe5c5-ad71-4ae7-b233-3b36804c5e0f" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/00a46119-4c62-4705-874b-88c9dd71bee4" />

## Disclaimer

CarWith, HyperOS, and Xiaomi are trademarks of Xiaomi. `CarWith.apk` and `miui.car.server.jar` are Xiaomi's proprietary software, taken unmodified from the official China ROM. This project isn't affiliated with Xiaomi. Modifying system files can break your phone, so use it at your own risk.

The scripts in this repository are under the [MIT License](LICENSE).
