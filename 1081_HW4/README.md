# HW4 Verilog – Testbench Design
### 電機三 沈哲瑋 B06901090
---
## 模擬結果
* correct:
<br>![](https://i.imgur.com/l4Rpe7J.png)
* error:<br>
![](https://i.imgur.com/8x6zkrU.png)
----
## 時序圖
* 影像輸入時序圖
![](https://i.imgur.com/55SQJ47.png)<br>
![](https://i.imgur.com/eJEIEAW.png)
* 影像輸出時序圖
![](https://i.imgur.com/11PJVQM.png)<br>
![](https://i.imgur.com/jJS8tAD.png)
----
## 我的設計
- 主要改寫自 HW1 裡的testbench
- 因為有addr，因此不需要pat、gold這兩個參數
- 一樣有err，統計錯誤出現的次數
- 多加了一個cnt，防止輸出的資料量對不上圖片大小
(不過這次用不到，因為主程式是對的)