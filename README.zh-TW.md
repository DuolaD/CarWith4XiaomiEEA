# CarWith4XiaomiEEA

[English](README.md) | [简体中文](README.zh-CN.md) | **繁體中文**

這是一個 Magisk / KernelSU 模組，把中國版 HyperOS 的手車互聯功能 CarWith 移植到 EEA 版和國際版小米手機上。

小米只在中國版 ROM 裡提供 CarWith（`com.miui.carlink`）。外版手機在中國大陸開車時，連不上支援 CarWith 或億連的車機。這個模組從中國版 ROM 補上缺少的兩個檔案，讓外版手機也能連。

## 測試環境

| 項目 | 版本 |
|---|---|
| 機型 | Xiaomi 15（`dada`） |
| ROM | HyperOS OS3.0.303.0.WOCEUXM（EEA，Android 16） |
| Root | KernelSU 3.3.1 + Zygisk Next 1.5.2 |
| CarWith | 4.0.3-20260513，擷取自 OS3.0.303.0.WOCCNXM |

目前只在這一套環境上測過。安裝腳本不檢查機型和系統版本，其他小米機型也可以試試。不管能不能用，都歡迎[開 issue](../../issues) 回報，並附上機型和 ROM 版本。

## 原理

模組從中國版 ROM 補上兩個檔案：

- `/product/app/CarWith/CarWith.apk`：CarWith 應用程式
- `/system_ext/framework/miui.car.server.jar`：`MiuiCarService` 系統服務

模組不依賴 LSPosed，也不修改 SELinux，因為 EEA ROM 本來就具備 CarWith 需要的大部分東西：

- `services.jar` 只要發現 `miui.car.server.jar` 存在，就會載入它；
- SELinux 情境和 `miui.car.permission.*` 權限都已經定義好；
- 設定裡的入口也已經存在，裝上 CarWith 後就會顯示。

另外，中國版和 EEA 用的是同一個平台簽章，CarWith 能正常取得簽章級權限。

很多 Root 隱藏方案（Zygisk Next、KernelSU 的「預設卸載模組」等）會對一般應用程式隱藏模組檔案。這樣一來，CarWith 讀不到自己的 APK，一打開就閃退。所以開機後，模組會把同一個 APK 再以「系統應用程式更新」的方式裝進 `/data/app`，所有程序都能讀到。

## 安裝

1. 從 [Releases](../../releases) 下載最新的 zip。
2. 在 KernelSU、Magisk 或 APatch 中刷入，然後重新開機。
3. 開機後等一分鐘左右，模組描述會顯示目前狀態：
   - ✅ CarWith 已安裝，`MiuiCarService` 正常執行。
   - ⚠️ CarWith 已安裝，但 `MiuiCarService` 沒有執行。
   - ❌ 系統沒有偵測到 CarWith。
4. 在 **設定 > 連線與分享 > CarWith** 中開啟，或者在 Root 管理器裡點模組的 **執行** 按鈕。

以下兩種情況，安裝腳本會拒絕安裝：
- 中國版 ROM：本來就內建 CarWith。
- 系統裡已經有 `/product/app/CarWith`。

## 連線方式

- 億連（EasyConnect）整合在 CarWith 裡，不用另外安裝。
- CarLife 需要另外的外掛 `com.baidu.carlife.xiaomi`，中國版 ROM 也沒有預裝。CarWith 要透過中國版小米應用商店（`com.xiaomi.market`）下載它，但外版 ROM 沒有這個商店。要用 CarLife 的話，可以自己安裝外掛 APK，或者安裝中國版小米應用商店。

## 已知限制

- 小愛同學、中國版應用商店等中國版專屬的小米應用程式，外版 ROM 都沒有，依賴它們的 CarWith 功能無法使用。
- 導航和音樂應用程式請自行安裝，例如高德地圖、百度地圖、QQ 音樂、網易雲音樂。
- 車機規格比較低時，投影畫面可能會有點卡。

## 執行按鈕

在 KernelSU 或 Magisk 裡點模組的 **執行**（或 **操作**）按鈕，會顯示：

- CarWith 的安裝路徑和版本
- `MiuiCarService` 有沒有執行
- 模組的 `guard.log`

接著會開啟 CarWith 的設定頁面。遇到問題時，開 issue 請附上這個頁面的截圖。

## 防開機卡死

- 連續 3 次無法開機，模組會自動停用。
- 開機過程中，`system_server` 重啟了 3 次，或者 5 分鐘後開機動畫還沒結束，模組會自動停用並重新開機。

觸發時，原因會寫進 `/data/adb/modules/carwith_eea_port/guard.log`。

## 解除安裝

在 Root 管理器裡移除模組，然後重新開機。下次開機大約 15 秒後，模組會順帶解除安裝 `/data/app` 裡的 CarWith 副本。

## 建置

在 GitHub 上發布 Release 時，會觸發 `.github/workflows/release.yml`。它會：

1. 把模組版本號設為 Release 的 tag；
2. 把 `module/` 打包成 `CarWith4XiaomiEEA-<tag>.zip`；
3. 上傳到這個 Release。

`versionCode` 依 tag 裡的數字計算：`主版本 × 10000 + 次版本 × 100 + 修訂號`。例如：

- `v1.2.3` → `10203`
- `26.11.05` → `261105`

tag 格式請固定用一種，這樣 `versionCode` 才會一直遞增。

手動打包時，壓縮的是 `module/` 裡面的內容，不是 `module` 這個資料夾本身。

`tools/dexrefcheck.py` 用來檢查 jar 或 APK 引用的框架方法和欄位在目標 ROM 上是否存在，移植到新版本 ROM 時可以用。

## 免責聲明

CarWith、HyperOS 和小米是小米公司的商標。`CarWith.apk` 和 `miui.car.server.jar` 是小米的閉源軟體，原封不動擷取自官方中國版 ROM。本專案與小米公司無關。修改系統檔案有風險，後果自負。

本儲存庫的腳本採用 [MIT 授權條款](LICENSE)。
