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

### 已测试

- 亿连 - 无线连接 - 热点连接 连接方式
- 智能导航流转
- 媒体音频传输

- 高德地图(17.02.2.2014，通过Google Play Store安装)
- Spotify(9.1.98.614，CarWith标记为实验性支持APP，通过Google Play Store安装)
- 哔哩哔哩(8.85.0，中国内地发行版本，非国际版；CarWith标记为实验性支持APP，通过Aurora Store安装)


### 未测试

- 百度地图
- 小爱同学（测试设备未安装中国ROM特供小爱同学助理，无法调用国际ROM中的Gemini）
- 应用商店（测试设备未安装中国ROM特供应用商店）
- 其它CarWith APP
- 其它被CarWith标记为实验性支持的APP

- 通话音频传输
- 其它CarWith功能


### 已知问题

- 暂无

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

## 使用第三方修改版 CarWith

网上有人发布修改过的 CarWith（二改版）。想用这类版本的话，可以把模块里的 `CarWith.apk` 换掉：

1. 从 [Releases](../../releases) 下载模块 zip。
2. 用 MT 管理器、ZArchiver 等能编辑压缩包的工具打开 zip，找到 `system/product/app/CarWith/CarWith.apk`。
3. 把修改版 APK 重命名为 `CarWith.apk`，替换原来的文件，其他文件不要动。

   在电脑上操作也可以：解压 zip，替换文件，然后进入解压出来的文件夹，把里面的所有文件重新打包成 zip。不要把外层文件夹也压进去，否则 Root 管理器会安装失败。
4. 如果之前装过原版模块，先在 Root 管理器里移除模块并重启。开机约 15 秒后，旧的 CarWith 副本会自动卸载，然后再刷入改好的 zip。修改版和原版的签名不同，直接覆盖刷入可能装不上，或者继续用着旧版。
5. 刷入后重启。

注意：

- 修改版的包名必须还是 `com.miui.carlink`，否则设置里的入口和模块的状态检测都找不到它。
- 修改版一般由作者重新签名，不再是小米的平台签名，因此拿不到签名级权限，部分功能可能用不了。这类问题请先找修改版作者反馈。
- 第三方修改版来源不明，可能夹带恶意代码，请只从信得过的地方下载。
- 开机后模块描述显示 ❌，或者 CarWith 打不开时，点运行按钮，看日志里 `installed /data copy` 那一行的安装结果。

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

## 截图

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/7c8c8328-a8e4-4a2d-9b2f-d4c46c3a09d2" />

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/5e6ba6be-a0cd-4378-afaf-5c2fec41b740" />

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/0d8f731c-37aa-483c-8107-9604dbdd132f" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/55650d15-f4e3-459a-bde6-dbd708c5a24e" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/9ba3112c-3d21-4758-a39f-9dbbf4cc68a7" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/943aa4da-0d34-454a-8be4-006a81aeafaa" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/9eafe5c5-ad71-4ae7-b233-3b36804c5e0f" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/00a46119-4c62-4705-874b-88c9dd71bee4" />

## 免责声明

CarWith、HyperOS 和小米是小米公司的商标。`CarWith.apk` 和 `miui.car.server.jar` 是小米的闭源软件，原样提取自官方国行 ROM，没有修改。本项目与小米公司无关。修改系统文件有风险，后果自负。

本仓库的脚本使用 [MIT 许可证](LICENSE)。
