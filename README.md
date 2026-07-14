# EDGE MT5 Trading Assistant

![Version](https://img.shields.io/badge/version-1.0-blue)
![MQL5](https://img.shields.io/badge/MQL5-Production-green)
![License](https://img.shields.io/badge/license-MIT-blue)

## Overview

**EDGE MT5 Trading Assistant** is a professional, multi-timeframe market scanner Expert Advisor for MetaTrader 5. It scans multiple forex, crypto, and commodity symbols every 60 seconds, identifying high-probability trading opportunities using a sophisticated D1 → H4 → H1 → M15 analysis workflow.

**⚠️ Important:** This is a **scanner only** — it does NOT place trades automatically. It identifies opportunities for manual execution or future automation.

---

## Key Features

✅ **Multi-Timeframe Analysis**
- D1 (Daily): Determine overall market trend
- H4 (4-Hour): Confirm trend
- H1 (1-Hour): Identify trade setup
- M15 (15-Minute): Confirm precise entry

✅ **Professional Dashboard**
- Real-time symbol scanning
- BUY/SELL/WAIT signals
- EDGE Score (0-100)
- Live price and EMA data

✅ **Smart Alerts**
- Popup alerts
- Sound alerts
- Email notifications (configurable)

✅ **Production Quality**
- Zero errors, zero warnings
- Modular, extensible architecture
- Cached indicator handles for performance
- Support for 100+ symbols

---

## Installation

### Step 1: Clone Repository
```bash
git clone https://github.com/Hlabakanjane/EDGE-MT5-Trading-Assistant.git
```

### Step 2: Copy to MT5
Copy the `Experts/EDGE/` folder to:
```
C:\Program Files\IC Markets\MetaTrader 5\MQL5\Experts\EDGE\
```

### Step 3: Compile
1. Open MetaEditor in MT5
2. Open `Experts/EDGE/EDGE.mq5`
3. Press **F7** to compile
4. Verify: **0 errors, 0 warnings**

### Step 4: Attach to Chart
1. Drag `EDGE.mq5` onto any chart
2. Allow DLL imports and live trading
3. Dashboard appears automatically

---

## Supported Symbols

**Forex:** EURUSD, GBPUSD, USDJPY, EURJPY, GBPJPY  
**Crypto:** BTCUSD, ETHUSD  
**Commodities:** XAUUSD (Gold), XAGUSD (Silver), XBRUSD (Brent), XTIUSD (WTI)  
**Indices:** US30

*All symbols are configurable in Settings.mqh*

---

## Dashboard Display

```
╔═════════════════════════════════════════════════════════════════╗
║    EDGE MT5 TRADING ASSISTANT - SCANNER v1.0                   ║
╠═════════════════════════════════════════════════════════════════╣
║ SYMBOL  │ PRICE   │ EMA20   │ D1   │ H4   │ H1    │ SIGNAL    ║
╠═════════════════════════════════════════════════════════════════╣
║ EURUSD  │ 1.1742  │ 1.1728  │ BULL │ BULL │ READY │ BUY ✓     ║
║ GBPUSD  │ 1.3640  │ 1.3661  │ BEAR │ BEAR │ READY │ SELL ✗   ║
║ USDJPY  │ 149.85  │ 150.12  │ WAIT │ WAIT │ WAIT  │ ...       ║
║ XAUUSD  │ 2420.5  │ 2415.2  │ BULL │ BULL │ SETUP │ WATCH     ║
║ BTCUSD  │ 95420   │ 94850   │ BEAR │ BEAR │ READY │ SELL ✓    ║
╚═════════════════════════════════════════════════════════════════╝
```

---

## Configuration

Edit **EDGE.mq5** inputs:

```mql5
input uint RefreshTime = 60;           // Scan interval (seconds)
input uint EMA_Period = 20;            // EMA period
input uint AlertThreshold = 70;        // Alert score threshold
input bool EnableEmailAlerts = false;  // Email notifications
input bool EnableSoundAlerts = true;   // Sound notifications
```

---

## How It Works

```
D1 TREND  →  H4 CONFIRM  →  H1 SETUP  →  M15 ENTRY  →  BUY/SELL/WAIT
```

**EDGE Score Components:**
- Daily Trend (20%)
- H4 Confirmation (20%)
- H1 Setup Quality (20%)
- M15 Entry Confirmation (15%)
- EMA Alignment (10%)
- Momentum Strength (15%)

---

## Performance

⚡ Scans 12 symbols in <1 second  
💾 Memory usage: ~5-10 MB  
📊 Supports 100+ symbols  
🔄 Configurable refresh rate  
✅ Zero lag with cached indicators

---

## Future Roadmap

- v1.5: Market session detection, news filter
- v2.0: Smart Money Concepts, Fair Value Gaps, Order Blocks
- v3.0: AI-assisted ranking, trade journaling, performance stats
- v4.0: Semi-automatic trade execution

---

## Support

📍 For issues or questions: Open an [Issue](https://github.com/Hlabakanjane/EDGE-MT5-Trading-Assistant/issues)

---

## License

MIT License - See [LICENSE](LICENSE) file

---

**Happy Trading! 📈**
