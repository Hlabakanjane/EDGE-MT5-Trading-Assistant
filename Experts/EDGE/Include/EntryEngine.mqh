//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Entry Engine                     |
//| Analyzes H1 and M15 for setup and entry confirmation          |
//+------------------------------------------------------------------+

#ifndef __ENTRY_ENGINE_MQH__
#define __ENTRY_ENGINE_MQH__

#include "Settings.mqh"
#include "Utilities.mqh"
#include "MarketStructure.mqh"

//+------------------------------------------------------------------+
//| Check for EMA Pullback                                        |
//+------------------------------------------------------------------+

bool IsEMAPullback(const string symbol, ENUM_TIMEFRAMES timeframe, int &handleEMA)
{
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double ema = GetEMA(symbol, timeframe, handleEMA);
    double atr = GetATR(symbol, timeframe, 14);
    
    if(ema == 0.0 || atr == 0.0)
        return false;
    
    // Price within 0.5 ATR of EMA = pullback to EMA
    double distance = MathAbs(price - ema);
    return distance < (atr * 0.5);
}

//+------------------------------------------------------------------+
//| Check for Breakout                                            |
//+------------------------------------------------------------------+

bool IsBreakout(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    double resistance = CalculateResistance(symbol, timeframe, 20);
    double support = CalculateSupport(symbol, timeframe, 20);
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    
    // Price breaks above resistance
    if(price > resistance && GetClose(symbol, timeframe, 1) <= resistance)
        return true;
    
    // Price breaks below support
    if(price < support && GetClose(symbol, timeframe, 1) >= support)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Check for Retest                                             |
//+------------------------------------------------------------------+

bool IsRetest(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    double resistance = CalculateResistance(symbol, timeframe, 20);
    double support = CalculateSupport(symbol, timeframe, 20);
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double low = GetLow(symbol, timeframe, 0);
    double high = GetHigh(symbol, timeframe, 0);
    
    // Retest of broken level
    double tolerance = GetATR(symbol, timeframe, 14) * 0.25;
    
    // Retest of support
    if(MathAbs(low - support) < tolerance && price > support)
        return true;
    
    // Retest of resistance
    if(MathAbs(high - resistance) < tolerance && price < resistance)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Check for Momentum                                            |
//+------------------------------------------------------------------+

bool IsMomentum(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    double rsi = GetRSI(symbol, timeframe, 14);
    double macdLine, signalLine;
    bool macdOK = GetMACD(symbol, timeframe, macdLine, signalLine);
    
    // Strong momentum: RSI > 60 or RSI < 40 AND MACD aligned
    if(!macdOK)
        return false;
    
    // Bullish momentum
    if(rsi > 60.0 && macdLine > signalLine)
        return true;
    
    // Bearish momentum
    if(rsi < 40.0 && macdLine < signalLine)
        return true;
    
    return false;
}

//+------------------------------------------------------------------+
//| Detect H1 Setup                                               |
//+------------------------------------------------------------------+

SetupType DetectH1Setup(const string symbol)
{
    int idx = GetSymbolIndex(symbol);
    if(idx < 0)
        return SETUP_NONE;
    
    // Check for pullback to EMA
    if(IsEMAPullback(symbol, TIMEFRAME_H1, gHandleEMA_H1[idx]))
        return SETUP_PULLBACK;
    
    // Check for breakout
    if(IsBreakout(symbol, TIMEFRAME_H1))
        return SETUP_BREAKOUT;
    
    // Check for retest
    if(IsRetest(symbol, TIMEFRAME_H1))
        return SETUP_RETEST;
    
    // Check for trend continuation
    if(IsBreakOfStructure(symbol, TIMEFRAME_H1))
        return SETUP_TRENDCONTINUATION;
    
    // Check for momentum
    if(IsMomentum(symbol, TIMEFRAME_H1))
        return SETUP_MOMENTUM;
    
    return SETUP_NONE;
}

//+------------------------------------------------------------------+
//| Check for Bullish/Bearish Engulfing                          |
//+------------------------------------------------------------------+

bool IsBullishEngulfing(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    double open0 = GetClose(symbol, timeframe, 1); // Previous candle close (was open)
    double close0 = GetClose(symbol, timeframe, 0);
    double low0 = GetLow(symbol, timeframe, 1);
    double high0 = GetHigh(symbol, timeframe, 0);
    
    // Current candle must engulf previous candle
    return (close0 > open0) && (low0 > GetLow(symbol, timeframe, 0)) && (high0 > GetHigh(symbol, timeframe, 1));
}

bool IsBearishEngulfing(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    double open0 = GetClose(symbol, timeframe, 1);
    double close0 = GetClose(symbol, timeframe, 0);
    double high0 = GetHigh(symbol, timeframe, 1);
    double low0 = GetLow(symbol, timeframe, 0);
    
    // Current candle must engulf previous candle
    return (close0 < open0) && (high0 < GetHigh(symbol, timeframe, 0)) && (low0 < GetLow(symbol, timeframe, 1));
}

//+------------------------------------------------------------------+
//| Confirm M15 Entry                                            |
//+------------------------------------------------------------------+

EntryReadiness ConfirmM15Entry(const string symbol)
{
    int idx = GetSymbolIndex(symbol);
    if(idx < 0)
        return ENTRY_NONE;
    
    // Check for Break of Structure on M15
    if(IsBreakOfStructure(symbol, TIMEFRAME_M15))
    {
        // Check for rejection candles
        if(IsBullishEngulfing(symbol, TIMEFRAME_M15) || IsBearishEngulfing(symbol, TIMEFRAME_M15))
            return ENTRY_READY;
    }
    
    // Check for strong rejection at level
    if(IsBullishEngulfing(symbol, TIMEFRAME_M15) || IsBearishEngulfing(symbol, TIMEFRAME_M15))
    {
        return ENTRY_READY;
    }
    
    // Check for EMA bounce on M15
    if(IsEMAPullback(symbol, TIMEFRAME_M15, gHandleEMA_M15[idx]))
    {
        return ENTRY_PENDING;
    }
    
    return ENTRY_NONE;
}

#endif
