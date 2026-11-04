# CarWith 移植模块（Xiaomi 15 dada / EEA）

把国行 HyperOS OS3.0.303.0.WOCCNXM 里的 CarWith 移植到 EEA 版 OS3.0.303.0.WOCEUXM。

## 目录

- `module/`：模块源码
- `out/`：打包好的模块 zip
- `tools/dexrefcheck.py`：检查 dex 引用的系统 API 在目标 ROM 中是否存在
- `work/`：ROM 解包和分析的中间文件（约 30 GB，可以删除，需要时可重新生成）

## 分析结论

| 项目 | 结果 |
|---|---|
| 缺失组件 | 只缺 `/product/app/CarWith/CarWith.apk`（com.miui.carlink 4.0.3-20260513）和 `/system_ext/framework/miui.car.server.jar` |
| 平台签名 | CN、EEA 与 CarWith 三者是同一个证书（SHA256 C9:00:9D:…:90:25），CarWith 能拿到 signature 级权限 |
| 系统服务加载 | EEA 的 `services.jar` 里本来就有 `MiuiCarServiceLoader`，会无条件加载 `/system_ext/framework/miui.car.server.jar`，没有地区判断 |
| SELinux | EEA 已有 `MiuiCarService u:object_r:miui_car_service:s0` 及相关策略 |
| 框架权限和广播 | EEA 的 `framework-ext-res` 已经定义 `miui.car.permission.*` |
| API 兼容 | `miui.car.server.jar` 引用的方法在 EEA framework 中全部存在（0 个缺失） |
| 设置入口 | EEA 设置的 `config_show_ucar_projection_screen=true`，XML 和国行相同；装好 CarWith 后入口自动出现 |
| 应用内地区判断 | 只用于统计上报和选择应用商店包名，不拦截核心功能 |
| privapp 权限 | 国行也没有为 CarWith 配置（它在 /product/app，不是特权应用），所以不需要 |

## 已知限制

- 小爱语音（com.miui.voiceassist）、国行应用商店（车机应用下载）、国行音乐等外版没有，相关功能不可用，或需要自行安装国行版本。
- 导航和音乐请自行安装高德、百度、QQ 音乐、网易云等国内应用。

## 安全机制

- `post-fs-data.sh`：连续 3 次开机未完成时自动禁用模块。
- `service.sh`：开机阶段 system_server 重启 3 次，或 5 分钟内开机动画仍未结束时，自动禁用模块并重启。
