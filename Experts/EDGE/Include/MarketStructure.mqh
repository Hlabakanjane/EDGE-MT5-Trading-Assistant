//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Market Structure Analysis        |
//| Detect: HH, HL, LH, LL, BOS, CHOCH, Swing Points             |
//+------------------------------------------------------------------+

#ifndef __MARKET_STRUCTURE_MQH__
#define __MARKET_STRUCTURE_MQH__

#include "Settings.mqh"
#include "Utilities.mqh"

//+------------------------------------------------------------------+
//| Get Swing High                                                |
//+------------------------------------------------------------------+

double GetSwingHigh(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 10)
{
    double high = 0.0;
    for(int i = 1; i <= lookback; i++)
    {
        double currentHigh = GetHigh(symbol, timeframe, i);
        if(currentHigh > high)
            high = currentHigh;
    }
    return high;
}

//+------------------------------------------------------------------+
//| Get Swing Low                                                 |
//+------------------------------------------------------------------+

double GetSwingLow(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 10)
{
    double low = DBL_MAX;
    for(int i = 1; i <= lookback; i++)
    {
        double currentLow = GetLow(symbol, timeframe, i);
        if(currentLow < low)
            low = currentLow;
    }
    return (low == DBL_MAX) ? 0.0 : low;
}

//+------------------------------------------------------------------+
//| Check for Higher High (HH)                                   |
//+------------------------------------------------------------------+

bool IsHigherHigh(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 20)
{
    if(lookback < 2)
        return false;
    
    double currentHigh = GetHigh(symbol, timeframe, 0);
    double previousHigh = GetHigh(symbol, timeframe, lookback);
    
    return currentHigh > previousHigh;
}

//+------------------------------------------------------------------+
//| Check for Higher Low (HL)                                    |
//+------------------------------------------------------------------+

bool IsHigherLow(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 20)
{
    if(lookback < 2)
        return false;
    
    double currentLow = GetLow(symbol, timeframe, 0);
    double previousLow = GetLow(symbol, timeframe, lookback);
    
    return currentLow > previousLow;
}

//+------------------------------------------------------------------+
//| Check for Lower High (LH)                                    |
//+------------------------------------------------------------------+

bool IsLowerHigh(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 20)
{
    if(lookback < 2)
        return false;
    
    double currentHigh = GetHigh(symbol, timeframe, 0);
    double previousHigh = GetHigh(symbol, timeframe, lookback);
    
    return currentHigh < previousHigh;
}

//+------------------------------------------------------------------+
//| Check for Lower Low (LL)                                     |
//+------------------------------------------------------------------+

bool IsLowerLow(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 20)
{
    if(lookback < 2)
        return false;
    
    double currentLow = GetLow(symbol, timeframe, 0);
    double previousLow = GetLow(symbol, timeframe, lookback);
    
    return currentLow < previousLow;
}

//+------------------------------------------------------------------+
//| Check for Break of Structure (BOS)                           |
//+------------------------------------------------------------------+

bool IsBreakOfStructure(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    // Bullish BOS: break of previous swing low
    if(IsHigherHigh(symbol, timeframe, 10) && IsHigherLow(symbol, timeframe, 10))
    {
        double currentLow = GetLow(symbol, timeframe, 0);
        double previousLow = GetSwingLow(symbol, timeframe, 20);
        if(currentLow > previousLow)
            return true;
    }
    
    // Bearish BOS: break of previous swing high
    if(IsLowerHigh(symbol, timeframe, 10) && IsLowerLow(symbol, timeframe, 10))
    {
        double currentHigh = GetHigh(symbol, timeframe, 0);
        double previousHigh = GetSwingHigh(symbol, timeframe, 20);
        if(currentHigh < previousHigh)
            return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Check for Change of Character (CHOCH)                        |
//+------------------------------------------------------------------+

bool IsChangeOfCharacter(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    // Bullish CHOCH: HL + HH after LL + LH
    if(IsHigherLow(symbol, timeframe, 20) && IsHigherHigh(symbol, timeframe, 10))
    {
        // Confirm uptrend
        return true;
    }
    
    // Bearish CHOCH: LH + LL after HH + HL
    if(IsLowerHigh(symbol, timeframe, 20) && IsLowerLow(symbol, timeframe, 10))
    {
        // Confirm downtrend
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Detect if price is above/below key level                      |
//+------------------------------------------------------------------+

bool IsPriceAboveLevel(const string symbol, double level)
{
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    return price > level;
}

bool IsPriceBelowLevel(const string symbol, double level)
{
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    return price < level;
}

//+------------------------------------------------------------------+
//| Calculate support level                                      |
//+------------------------------------------------------------------+

double CalculateSupport(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 50)
{
    return GetSwingLow(symbol, timeframe, lookback);
}

//+------------------------------------------------------------------+
//| Calculate resistance level                                   |
//+------------------------------------------------------------------+

double CalculateResistance(const string symbol, ENUM_TIMEFRAMES timeframe, int lookback = 50)
{
    return GetSwingHigh(symbol, timeframe, lookback);
}

#endif
