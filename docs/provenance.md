# 恢复来源与对应关系

原始材料：课程汇报《Verilog 实现流水线 RV32I 处理器》，封面日期 2025 年 6 月 3 日，文件名 `汇报PPT.pptx`，共 35 页。作者已确认原始源码找不到，本次仅恢复图片中能够确认的代码。

原 PPTX 的 SHA-256：

```text
c9b839ec8ffc743fb893c1224b85255904bef081b53cc17809e16bbc1b668499
```

## 恢复方式

从 PPTX ZIP 容器中直接提取原始代码 PNG，逐张阅读并转录为 Verilog。55 张代码截图位于 `source-images/`，内容未经重绘或裁剪；重复出现在幻灯片中的同一图片只保留一份。`assets/pipeline.png` 对应第 4 页的原数据通路图。

整理包括统一缩进、按模块拆文件、合并同类型端口／信号声明、合并相同赋值的 case 标签、精简／翻译部分注释。恢复版本保留截图的逻辑选择、常量、存储器索引、复位行为、非阻塞赋值和文件操作；它是人工转录与格式整理版本，不是遗失源文件的逐字副本。

**语法拼接修补：** 第 10 页 `image28.png` 可见的 ASel 代码结束于 else 块的 `end`，下一张已进入 BSel 块。恢复时补入一个用于闭合 ASel 外层 `always` 的 `end`，没有增加功能逻辑。原图可供审阅这一拼接边界。

**保留缺失：** 没有把第 15 页 `Reg` 擅自改名或扩写成 `WBReg_ID_Hazard`，没有修正顶层 IMEM 连接，也没有新增原始测试程序。源码已知缺陷没有混入恢复时修复。

## 模块索引

| 恢复文件 | PPT 页码 |
| --- | --- |
| [`Top_module.v`](../rtl/Top_module.v) | 9 |
| [`Control_logic.v`](../rtl/Control_logic.v) | 10, 11 |
| [`Control_Hazard.v`](../rtl/Control_Hazard.v) | 12 |
| [`IF.v`](../rtl/IF.v) | 13 |
| [`IMEM.v`](../rtl/IMEM.v) | 14 |
| [`Reg.v`](../rtl/Reg.v) | 15 |
| [`Branch_Comp.v`](../rtl/Branch_Comp.v) | 16 |
| [`ImmGen.v`](../rtl/ImmGen.v) | 17 |
| [`ALU.v`](../rtl/ALU.v) | 18 |
| [`DMEM.v`](../rtl/DMEM.v) | 19 |
| [`IF_ID_Reg.v`](../rtl/IF_ID_Reg.v) | 20 |
| [`ID_EX_Reg.v`](../rtl/ID_EX_Reg.v) | 20 |
| [`EX_M_Reg.v`](../rtl/EX_M_Reg.v) | 20 |
| [`M_WB_Reg.v`](../rtl/M_WB_Reg.v) | 20 |
| [`MUX_2.v`](../rtl/MUX_2.v) | 21 |
| [`MUX.v`](../rtl/MUX.v) | 22 |
| [`WB_MUX.v`](../rtl/WB_MUX.v) | 22 |

## 原图索引

### 第 9 页

[slide9-image15.png](source-images/slide9-image15.png) · [slide9-image16.png](source-images/slide9-image16.png) · [slide9-image17.png](source-images/slide9-image17.png) · [slide9-image18.png](source-images/slide9-image18.png) · [slide9-image19.png](source-images/slide9-image19.png)

### 第 10 页

[slide10-image20.png](source-images/slide10-image20.png) · [slide10-image21.png](source-images/slide10-image21.png) · [slide10-image22.png](source-images/slide10-image22.png) · [slide10-image23.png](source-images/slide10-image23.png) · [slide10-image24.png](source-images/slide10-image24.png) · [slide10-image25.png](source-images/slide10-image25.png) · [slide10-image26.png](source-images/slide10-image26.png) · [slide10-image27.png](source-images/slide10-image27.png) · [slide10-image28.png](source-images/slide10-image28.png)

### 第 11 页

[slide11-image29.png](source-images/slide11-image29.png) · [slide11-image30.png](source-images/slide11-image30.png) · [slide11-image31.png](source-images/slide11-image31.png) · [slide11-image32.png](source-images/slide11-image32.png) · [slide11-image33.png](source-images/slide11-image33.png) · [slide11-image34.png](source-images/slide11-image34.png) · [slide11-image35.png](source-images/slide11-image35.png) · [slide11-image36.png](source-images/slide11-image36.png)

### 第 12 页

[slide12-image37.png](source-images/slide12-image37.png) · [slide12-image38.png](source-images/slide12-image38.png) · [slide12-image39.png](source-images/slide12-image39.png) · [slide12-image40.png](source-images/slide12-image40.png)

### 第 13 页

[slide13-image41.png](source-images/slide13-image41.png)

### 第 14 页

[slide14-image42.png](source-images/slide14-image42.png) · [slide14-image43.png](source-images/slide14-image43.png)

### 第 15 页

[slide15-image44.png](source-images/slide15-image44.png) · [slide15-image45.png](source-images/slide15-image45.png) · [slide15-image46.png](source-images/slide15-image46.png)

### 第 16 页

[slide16-image47.png](source-images/slide16-image47.png) · [slide16-image48.png](source-images/slide16-image48.png)

### 第 17 页

[slide17-image49.png](source-images/slide17-image49.png) · [slide17-image50.png](source-images/slide17-image50.png)

### 第 18 页

[slide18-image51.png](source-images/slide18-image51.png) · [slide18-image52.png](source-images/slide18-image52.png)

### 第 19 页

[slide19-image53.png](source-images/slide19-image53.png) · [slide19-image54.png](source-images/slide19-image54.png) · [slide19-image55.png](source-images/slide19-image55.png) · [slide19-image56.png](source-images/slide19-image56.png) · [slide19-image57.png](source-images/slide19-image57.png)

### 第 20 页

[slide20-image58.png](source-images/slide20-image58.png) · [slide20-image59.png](source-images/slide20-image59.png) · [slide20-image60.png](source-images/slide20-image60.png) · [slide20-image61.png](source-images/slide20-image61.png) · [slide20-image62.png](source-images/slide20-image62.png) · [slide20-image63.png](source-images/slide20-image63.png) · [slide20-image64.png](source-images/slide20-image64.png) · [slide20-image65.png](source-images/slide20-image65.png)

### 第 21 页

[slide21-image66.png](source-images/slide21-image66.png) · [slide21-image67.png](source-images/slide21-image67.png)

### 第 22 页

[slide22-image68.png](source-images/slide22-image68.png) · [slide22-image69.png](source-images/slide22-image69.png)

## 完整性复核

`manifest.json` 保存每张代码截图的 SHA-256。运行 `python3 scripts/verify_sources.py` 检查仓库图片完整性；如果本地保留原汇报，可额外执行：

```sh
python3 scripts/verify_sources.py --presentation /path/to/original.pptx
```

该命令验证 PPTX 哈希、所有代码截图及数据通路图与原包内容逐字节一致。图片哈希通过并不等于代码转录经过形式等价验证。

## 原材料与本次新增内容

- 来自 2025 年材料：代码截图、数据通路图、对应转录逻辑，以及历史性能表。
- 2026 年新增：仓库结构、格式整理、来源注释、README、技术文档、定向测试、临时目录运行方式、统计脚本、来源检查与 CI。
- 未上传：四份课程 PDF、整份 PPT、同名压缩包、带学号的封面、无关课程材料和本地检查中间文件。
