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

## Building

Pushing a GitHub Release triggers `.github/workflows/release.yml`. It sets the module version to the release tag, packs `module/` into `CarWith4XiaomiEEA-<tag>.zip`, and uploads it to the release.

`versionCode` comes from the numbers in the tag, as `major × 10000 + minor × 100 + patch`:

- `v1.2.3` → `10203`
- `26.11.05` → `261105`

Stick with one tag scheme so `versionCode` keeps going up.

To build by hand, zip the contents of `module/`, not the folder itself.

`tools/dexrefcheck.py` checks whether the framework methods and fields a jar or APK references exist on the target ROM. It's useful when porting to a new ROM version.

## Disclaimer

CarWith, HyperOS, and Xiaomi are trademarks of Xiaomi. `CarWith.apk` and `miui.car.server.jar` are Xiaomi's proprietary software, taken unmodified from the official China ROM. This project isn't affiliated with Xiaomi. Modifying system files can break your phone, so use it at your own risk.

The scripts in this repository are under the [MIT License](LICENSE).
