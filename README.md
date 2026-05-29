# Trendline Break Detector — MQL4 Script

A MetaTrader 4 script that **monitors a named chart trendline object** for price breakouts by retrieving its two anchor points via `ObjectGetDouble(OBJPROP_PRICE1/2)` and `ObjectGetInteger(OBJPROP_TIME1/2)`, computing the trendline's expected price at the current bar via a linear slope formula, comparing the current market price against that projected level, and firing a directional **UP** or **DOWN** breakout alert — with optional `OrderSend()` trade execution on confirmed break — exiting after the first detection.

---

## Overview

A trendline is one of the most fundamental tools in technical analysis, representing a straight line connecting a series of price pivot points that defines the prevailing directional bias. When price breaks through a trendline — particularly a well-established one connecting multiple significant pivots — it signals a potential change in market structure and is one of the most widely watched entry triggers in discretionary trading. Manually watching for trendline breaks requires continuous chart monitoring, which this script automates. By reading the coordinates of an existing trendline drawn by the trader, the script computes the line's mathematically precise price level at the current moment using linear interpolation, then monitors the live price against that level. The moment price crosses the line in either direction, an alert fires and optionally a trade is executed. The script exits after the first break detection rather than re-entering the loop, preventing multiple alerts on the same trendline event.

---

## Features

- **Live trendline level computation** — `ObjectFind(0, TrendlineName) == -1` guard validates existence each cycle before reading properties; `slope = (price2 − price1) / (time2 − time1)`; `currentTrendlinePrice = price1 + slope × (TimeCurrent() − time1)` computes the exact trendline price at the current moment via linear interpolation
- **`ObjectGetDouble()` / `ObjectGetInteger()` property retrieval** — `OBJPROP_PRICE1`, `OBJPROP_PRICE2`, `OBJPROP_TIME1`, `OBJPROP_TIME2` fetched each cycle; `time1 == 0 || time2 == 0` invalid-property guard skips the cycle with a sleep if anchor times are not yet set
- **Bidirectional break classification** — `isBreakUp = currentPrice > currentTrendlinePrice`; `isBreakDown = currentPrice < currentTrendlinePrice` — both evaluated each cycle; either true fires the alert and optionally the trade
- **`ExecuteTradeOnBreak(isBreakUp)` optional execution** — when `ExecuteTrade = true`: `orderType = isBreakUp ? OP_BUY : OP_SELL`; `price = isBreakUp ? Ask : Bid`; `sl` and `tp` computed from `StopLossPips` and `TakeProfitPips` × `Point`; `OrderSend()` dispatched with `"Trendline Break Trade"` comment and `clrBlue` marker
- **Single-detection `break` exit** — script exits the monitoring loop immediately after the first confirmed trendline break, preventing multiple alerts or trades on the same breakout event
- **Three notification channels:** sound alert, `Alert()`, and `Print()` to Experts tab

---

## How It Works

1. Every minute, `ObjectFind(0, TrendlineName)` validates existence; properties fetched via `ObjectGetDouble/Integer()`
2. `slope` and `currentTrendlinePrice` computed via linear interpolation
3. `isBreakUp` and `isBreakDown` evaluated; first true condition fires `Alert()` and optional `ExecuteTradeOnBreak()`
4. `break` exits the monitoring loop after detection

---

## Input Parameters

| Parameter          | Type   | Default        | Description                                                       |
|--------------------|--------|----------------|-------------------------------------------------------------------|
| `TrendlineName`    | string | `Trendline`    | Exact name of the trendline object on the active chart            |
| `AlertOnBreak`     | bool   | `true`         | Fire an on-screen/sound alert on trendline break detection        |
| `ExecuteTrade`     | bool   | `false`        | Automatically place a trade in the break direction                |
| `LotSize`          | double | `0.1`          | Lot size for optional break trade execution                       |
| `StopLossPips`     | double | `50`           | Stop loss in pips for the optional break trade                    |
| `TakeProfitPips`   | double | `100`          | Take profit in pips for the optional break trade                  |

---

## Alert Message Format

```
Trendline Break! Direction: UP | Price: 1.08520
```

---

## Installation

1. Copy `Trendline_Break_Detector_001.mq4` to `MQL4/Scripts/` in your MT4 data folder
2. Compile in MetaEditor (F7)
3. Draw a trendline on the chart and name it to match `TrendlineName` (right-click → Properties → Common tab → Name)
4. Drag the script onto the chart; configure inputs and click **OK**

> **Warning:** `ExecuteTrade = true` places a real order. Always test on a **demo account** first.

> **Note:** The script must be restarted manually after the first break detection to monitor subsequent breaks on the same or a new trendline.

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)
- A named trendline object present on the active chart

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
