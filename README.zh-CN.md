# CarWith4XiaomiEEA

[English](README.md) | **简体中文** | [繁體中文](README.zh-TW.md)

这是一个 Magisk / KernelSU 模块，把国行 HyperOS 的手车互联功能 CarWith 移植到 EEA 版和国际版小米手机上。

小米只在国行 ROM 里提供 CarWith（`com.miui.carlink`）。外版手机在中国大陆用车时，连不上支持 CarWith 或亿连的车机。这个模块从国行 ROM 里补上缺少的两个文件，让外版手机也能连。

## 测试环境

| 项目 | 版本 |
|---|---|
| 机型 | Xiaomi 15（`dada`） |
| ROM | HyperOS OS3.0.303.0.WOCEUXM（EEA，Android 16） |
| Root | KernelSU 3.3.1 + Zygisk Next 1.5.2 |
| CarWith | 4.0.3-20260513，提取自 OS3.0.303.0.WOCCNXM |

目前只在这一套环境上测过。安装脚本不检查机型和系统版本，其他小米机型也可以试试。不管能不能用，都欢迎[提 issue](../../issues) 反馈，并附上机型和 ROM 版本。

## 原理

模块从国行 ROM 补上两个文件：

- `/product/app/CarWith/CarWith.apk`：CarWith 应用
- `/system_ext/framework/miui.car.server.jar`：`MiuiCarService` 系统服务

模块不依赖 LSPosed，也不修改 SELinux，因为 EEA ROM 本来就具备 CarWith 需要的大部分东西：

- `services.jar` 只要发现 `miui.car.server.jar` 存在，就会加载它；
- SELinux 上下文和 `miui.car.permission.*` 权限都已经定义好；
- 设置里的入口也已经存在，装上 CarWith 后就会显示。

另外，国行和 EEA 用的是同一个平台签名，CarWith 能正常获得签名级权限。

很多 Root 隐藏方案（Zygisk Next、KernelSU 的“默认卸载模块”等）会对普通应用隐藏模块文件。这样一来，CarWith 读不到自己的 APK，一打开就闪退。所以开机后，模块会把同一个 APK 再以“系统应用更新”的方式装进 `/data/app`，所有进程都能读到。

## 安装

1. 从 [Releases](../../releases) 下载最新的 zip。
2. 在 KernelSU、Magisk 或 APatch 中刷入，然后重启。
3. 开机后等一分钟左右，模块描述会显示当前状态：
   - ✅ CarWith 已安装，`MiuiCarService` 正常运行。
   - ⚠️ CarWith 已安装，但 `MiuiCarService` 没有运行。
   - ❌ 系统没有识别到 CarWith。
4. 在 **设置 > 连接与共享 > CarWith** 中打开，或者在 Root 管理器里点模块的 **运行** 按钮。

以下两种情况，安装脚本会拒绝安装：
- 国行 ROM：本来就自带 CarWith。
- 系统里已经有 `/product/app/CarWith`。

## 连接方式

- 亿连（EasyConnect）集成在 CarWith 里，不用另外装东西。
- CarLife 需要单独的插件 `com.baidu.carlife.xiaomi`，国行 ROM 也没有预装。CarWith 要通过国行小米应用商店（`com.xiaomi.market`）下载它，但外版 ROM 没有这个商店。要用 CarLife 的话，可以自己装插件 APK，或者装国行小米应用商店。

## 已知限制

- 小爱同学、国行应用商店等国行专属的小米应用，外版 ROM 都没有，依赖它们的 CarWith 功能用不了。
- 导航和音乐应用请自己安装，比如高德地图、百度地图、QQ 音乐、网易云音乐。
- 车机配置比较低时，投屏可能有点卡。

## 运行按钮

在 KernelSU 或 Magisk 里点模块的 **运行**（或 **操作**）按钮，会显示：

- CarWith 的安装路径和版本
- `MiuiCarService` 有没有运行
- 模块的 `guard.log`

然后会打开 CarWith 的设置页面。遇到问题时，提 issue 请附上这个页面的截图。

## 防卡开机

- 连续 3 次没能开机，模块会自动禁用。
- 开机过程中，`system_server` 重启了 3 次，或者 5 分钟后开机动画还没结束，模块会自动禁用并重启。

触发时，原因会写进 `/data/adb/modules/carwith_eea_port/guard.log`。

## 卸载

在 Root 管理器里移除模块，然后重启。下次开机大约 15 秒后，模块会顺带卸载 `/data/app` 里的 CarWith 副本。

## 构建

在 GitHub 上发布 Release 时，会触发 `.github/workflows/release.yml`。它会：

1. 把模块版本号设为 Release 的 tag；
2. 把 `module/` 打包成 `CarWith4XiaomiEEA-<tag>.zip`；
3. 上传到这个 Release。

`versionCode` 按 tag 里的数字计算：`主版本 × 10000 + 次版本 × 100 + 修订号`。例如：

- `v1.2.3` → `10203`
- `26.11.05` → `261105`

tag 格式请固定用一种，这样 `versionCode` 才会一直递增。

手动打包时，压缩的是 `module/` 里面的内容，不是 `module` 这个文件夹本身。

`tools/dexrefcheck.py` 用来检查 jar 或 APK 引用的框架方法和字段在目标 ROM 上是否存在，移植到新版本 ROM 时可以用。

## 免责声明

CarWith、HyperOS 和小米是小米公司的商标。`CarWith.apk` 和 `miui.car.server.jar` 是小米的闭源软件，原样提取自官方国行 ROM，没有修改。本项目与小米公司无关。修改系统文件有风险，后果自负。

本仓库的脚本使用 [MIT 许可证](LICENSE)。
