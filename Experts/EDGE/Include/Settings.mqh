//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Settings Configuration             |
//| This file contains all configurable parameters and enums         |
//+------------------------------------------------------------------+

#ifndef __SETTINGS_MQH__
#define __SETTINGS_MQH__

//+------------------------------------------------------------------+
//| INPUT PARAMETERS
//+------------------------------------------------------------------+

input uint RefreshTime = 60;              // Refresh interval (seconds)
input uint EMA_Period = 20;               // EMA period
input uint AlertThreshold = 70;           // Alert score threshold (0-100)
input bool EnableEmailAlerts = false;     // Enable email notifications
input bool EnableSoundAlerts = true;      // Enable sound alerts
input bool EnablePopupAlerts = true;      // Enable popup alerts

//+------------------------------------------------------------------+
//| DASHBOARD SETTINGS
//+------------------------------------------------------------------+

const int DashboardX = 20;                // Dashboard X position
const int DashboardY = 20;                // Dashboard Y position
const int DashboardWidth = 1200;          // Dashboard width (pixels)
const int DashboardHeight = 400;          // Dashboard height (pixels)
const int CellHeight = 25;                // Row height
const int CellPadding = 5;                // Cell padding

//+------------------------------------------------------------------+
//| COLOR SCHEME
//+------------------------------------------------------------------+

const color ColorBUY = clrLime;           // BUY signal color (Green)
const color ColorSELL = clrRed;           // SELL signal color (Red)
const color ColorWAIT = clrYellow;        // WAIT signal color (Yellow)
const color ColorBG = clrBlack;           // Background color
const color ColorHeader = clrWhite;       // Header text color
const color ColorText = clrWhiteSmoke;    // Body text color
const color ColorBorder = clrGray;        // Border color

//+------------------------------------------------------------------+
//| SYMBOL LIST
//+------------------------------------------------------------------+

const string SYMBOLS[] = {
    "EURUSD",   // Euro vs US Dollar
    "GBPUSD",   // British Pound vs US Dollar
    "USDJPY",   // US Dollar vs Japanese Yen
    "EURJPY",   // Euro vs Japanese Yen
    "GBPJPY",   // British Pound vs Japanese Yen
    "XAUUSD",   // Gold
    "XAGUSD",   // Silver
    "BTCUSD",   // Bitcoin
    "ETHUSD",   // Ethereum
    "US30",     // US 30 Index
    "XBRUSD",   // Brent Crude Oil
    "XTIUSD"    // WTI Crude Oil
};

const int SYMBOL_COUNT = ArraySize(SYMBOLS);

//+------------------------------------------------------------------+
//| TIMEFRAME CONFIGURATION
//+------------------------------------------------------------------+

const ENUM_TIMEFRAMES TIMEFRAME_D1 = PERIOD_D1;     // Daily
const ENUM_TIMEFRAMES TIMEFRAME_H4 = PERIOD_H4;     // 4-Hour
const ENUM_TIMEFRAMES TIMEFRAME_H1 = PERIOD_H1;     // 1-Hour
const ENUM_TIMEFRAMES TIMEFRAME_M15 = PERIOD_M15;   // 15-Minute

//+------------------------------------------------------------------+
//| ENUMS
//+------------------------------------------------------------------+

enum TrendType
{
    TREND_BULLISH = 1,
    TREND_BEARISH = -1,
    TREND_NEUTRAL = 0
};

enum SignalType
{
    SIGNAL_BUY = 1,
    SIGNAL_SELL = -1,
    SIGNAL_WAIT = 0
};

enum SetupType
{
    SETUP_NONE = 0,
    SETUP_PULLBACK = 1,
    SETUP_BREAKOUT = 2,
    SETUP_RETEST = 3,
    SETUP_MOMENTUM = 4,
    SETUP_TRENDCONTINUATION = 5
};

enum EntryReadiness
{
    ENTRY_NONE = 0,
    ENTRY_PENDING = 1,
    ENTRY_READY = 2
};

//+------------------------------------------------------------------+
//| MARKET DATA STRUCTURE
//+------------------------------------------------------------------+

struct MarketData
{
    string symbol;
    double price;
    double ema20;
    double emaSlope;
    
    TrendType trendD1;
    TrendType trendH4;
    SetupType setupH1;
    EntryReadiness entryM15;
    
    SignalType signal;
    int edgeScore;
    
    datetime lastUpdate;
};

//+------------------------------------------------------------------+
//| GLOBAL VARIABLES
//+------------------------------------------------------------------+

MarketData gMarketData[];
int gHandleEMA_D1[];
int gHandleEMA_H4[];
int gHandleEMA_H1[];
int gHandleEMA_M15[];

bool gDashboardCreated = false;
uint gLastRefreshTime = 0;

//+------------------------------------------------------------------+
//| CONSTANTS
//+------------------------------------------------------------------+

const double MIN_PRICE_CHANGE = 0.00001;  // Minimum price movement
const int MAX_BARS_HISTORY = 500;         // Maximum bars to analyze
const double RSI_OVERBOUGHT = 70.0;       // RSI overbought level
const double RSI_OVERSOLD = 30.0;         // RSI oversold level

#endif
