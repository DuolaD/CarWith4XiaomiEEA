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

### 已測試

- 億連 - 無線連線 - 熱點連線 連線方式
- 智慧導航流轉
- 媒體音訊傳輸

- 高德地圖(17.02.2.2014，透過Google Play Store安裝)
- Spotify(9.1.98.614，CarWith標記為實驗性支援APP，透過Google Play Store安裝)
- 嗶哩嗶哩(8.85.0，中國大陸發行版本，非國際版；CarWith標記為實驗性支援APP，透過Aurora Store安裝)


### 未測試

- 百度地圖
- 小愛同學（測試裝置未安裝中國ROM特供小愛同學助理，無法呼叫國際ROM中的Gemini）
- 應用商店（測試裝置未安裝中國ROM特供應用商店）
- 其它CarWith APP
- 其它被CarWith標記為實驗性支援的APP

- 通話音訊傳輸
- 其它CarWith功能


### 已知問題

- 暫無

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

> [!IMPORTANT]
> **KernelSU 使用者需要先安裝元模組（metamodule）。** 本模組透過 `system/` 目錄把檔案掛載進系統分割區。新版 KernelSU（導入元模組機制的版本，例如 3.x）本身不再掛載模組的 `system/` 目錄，這項工作交給元模組完成，例如官方的 meta-overlayfs。沒裝元模組的話，腳本照樣會執行，但兩個檔案都不會出現在系統裡，模組狀態會顯示 ❌。請先裝好元模組，再刷入本模組。Magisk 和 APatch 內建掛載，不需要元模組。
>
> 重新開機後可以在 Root shell 裡執行下面的指令檢查掛載，兩個路徑都能列出來就代表成功：
>
> ```sh
> ls /product/app/CarWith/CarWith.apk /system_ext/framework/miui.car.server.jar
> ```

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

## 使用第三方修改版 CarWith

網路上有人發布修改過的 CarWith（二改版）。想用這類版本的話，可以把模組裡的 `CarWith.apk` 換掉：

1. 從 [Releases](../../releases) 下載模組 zip。
2. 用 MT 管理器、ZArchiver 等能編輯壓縮檔的工具開啟 zip，找到 `system/product/app/CarWith/CarWith.apk`。
3. 把修改版 APK 重新命名為 `CarWith.apk`，取代原本的檔案，其他檔案不要動。

   在電腦上操作也可以：解壓縮 zip，取代檔案，然後進入解壓縮出來的資料夾，把裡面的所有檔案重新壓縮成 zip。不要把外層資料夾也壓進去，否則 Root 管理器會安裝失敗。
4. 如果之前裝過原版模組，先在 Root 管理器裡移除模組並重新開機。開機約 15 秒後，舊的 CarWith 副本會自動解除安裝，然後再刷入改好的 zip。修改版和原版的簽章不同，直接覆蓋刷入可能裝不上，或者繼續用著舊版。
5. 刷入後重新開機。

注意：

- 修改版的套件名稱必須還是 `com.miui.carlink`，否則設定裡的入口和模組的狀態偵測都找不到它。
- 修改版一般由作者重新簽章，不再是小米的平台簽章，因此拿不到簽章級權限，部分功能可能無法使用。這類問題請先向修改版作者回報。
- 第三方修改版來源不明，可能夾帶惡意程式，請只從信得過的地方下載。
- 開機後模組描述顯示 ❌，或者 CarWith 打不開時，點執行按鈕，看日誌裡 `installed /data copy` 那一行的安裝結果。

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

## 截圖

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/7c8c8328-a8e4-4a2d-9b2f-d4c46c3a09d2" />

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/5e6ba6be-a0cd-4378-afaf-5c2fec41b740" />

<img width="1200" height="2670" alt="Image" src="https://github.com/user-attachments/assets/0d8f731c-37aa-483c-8107-9604dbdd132f" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/55650d15-f4e3-459a-bde6-dbd708c5a24e" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/9ba3112c-3d21-4758-a39f-9dbbf4cc68a7" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/943aa4da-0d34-454a-8be4-006a81aeafaa" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/9eafe5c5-ad71-4ae7-b233-3b36804c5e0f" />

<img width="1024" height="592" alt="Image" src="https://github.com/user-attachments/assets/00a46119-4c62-4705-874b-88c9dd71bee4" />

## 免責聲明

CarWith、HyperOS 和小米是小米公司的商標。`CarWith.apk` 和 `miui.car.server.jar` 是小米的閉源軟體，原封不動擷取自官方中國版 ROM。本專案與小米公司無關。修改系統檔案有風險，後果自負。

本儲存庫的腳本採用 [MIT 授權條款](LICENSE)。
