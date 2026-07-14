//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Utility Functions                 |
//| Helper functions for calculations and common operations         |
//+------------------------------------------------------------------+

#ifndef __UTILITIES_MQH__
#define __UTILITIES_MQH__

#include "Settings.mqh"

//+------------------------------------------------------------------+
//| Get symbol index in array                                      |
//+------------------------------------------------------------------+

int GetSymbolIndex(const string symbol)
{
    for(int i = 0; i < SYMBOL_COUNT; i++)
    {
        if(SYMBOLS[i] == symbol)
            return i;
    }
    return -1;
}

//+------------------------------------------------------------------+
//| Get Close price                                                |
//+------------------------------------------------------------------+

double GetClose(const string symbol, ENUM_TIMEFRAMES timeframe, int shift = 0)
{
    double closeBuffer[];
    ArraySetAsSeries(closeBuffer, true);
    
    int bars = Bars(symbol, timeframe);
    if(bars < shift + 1)
        return 0.0;
    
    if(CopyClose(symbol, timeframe, shift, 1, closeBuffer) < 1)
        return 0.0;
    
    return closeBuffer[0];
}

//+------------------------------------------------------------------+
//| Get High price                                                |
//+------------------------------------------------------------------+

double GetHigh(const string symbol, ENUM_TIMEFRAMES timeframe, int shift = 0)
{
    double highBuffer[];
    ArraySetAsSeries(highBuffer, true);
    
    if(CopyHigh(symbol, timeframe, shift, 1, highBuffer) < 1)
        return 0.0;
    
    return highBuffer[0];
}

//+------------------------------------------------------------------+
//| Get Low price                                                 |
//+------------------------------------------------------------------+

double GetLow(const string symbol, ENUM_TIMEFRAMES timeframe, int shift = 0)
{
    double lowBuffer[];
    ArraySetAsSeries(lowBuffer, true);
    
    if(CopyLow(symbol, timeframe, shift, 1, lowBuffer) < 1)
        return 0.0;
    
    return lowBuffer[0];
}

//+------------------------------------------------------------------+
//| Calculate Average True Range (ATR)                             |
//+------------------------------------------------------------------+

double GetATR(const string symbol, ENUM_TIMEFRAMES timeframe, int period = 14)
{
    int handleATR = iATR(symbol, timeframe, period);
    if(handleATR == INVALID_HANDLE)
        return 0.0;
    
    double atrBuffer[];
    ArraySetAsSeries(atrBuffer, true);
    
    if(CopyBuffer(handleATR, 0, 0, 1, atrBuffer) < 1)
    {
        IndicatorRelease(handleATR);
        return 0.0;
    }
    
    IndicatorRelease(handleATR);
    return atrBuffer[0];
}

//+------------------------------------------------------------------+
//| Calculate RSI (Relative Strength Index)                        |
//+------------------------------------------------------------------+

double GetRSI(const string symbol, ENUM_TIMEFRAMES timeframe, int period = 14)
{
    int handleRSI = iRSI(symbol, timeframe, period, PRICE_CLOSE);
    if(handleRSI == INVALID_HANDLE)
        return 50.0; // Neutral
    
    double rsiBuffer[];
    ArraySetAsSeries(rsiBuffer, true);
    
    if(CopyBuffer(handleRSI, 0, 0, 1, rsiBuffer) < 1)
    {
        IndicatorRelease(handleRSI);
        return 50.0;
    }
    
    IndicatorRelease(handleRSI);
    return rsiBuffer[0];
}

//+------------------------------------------------------------------+
//| Calculate MACD                                                |
//+------------------------------------------------------------------+

bool GetMACD(const string symbol, ENUM_TIMEFRAMES timeframe, double &macdLine, double &signalLine)
{
    int handleMACD = iMACD(symbol, timeframe, 12, 26, 9, PRICE_CLOSE);
    if(handleMACD == INVALID_HANDLE)
        return false;
    
    double macdBuffer[];
    double signalBuffer[];
    ArraySetAsSeries(macdBuffer, true);
    ArraySetAsSeries(signalBuffer, true);
    
    if(CopyBuffer(handleMACD, 0, 0, 1, macdBuffer) < 1 ||
       CopyBuffer(handleMACD, 1, 0, 1, signalBuffer) < 1)
    {
        IndicatorRelease(handleMACD);
        return false;
    }
    
    macdLine = macdBuffer[0];
    signalLine = signalBuffer[0];
    
    IndicatorRelease(handleMACD);
    return true;
}

//+------------------------------------------------------------------+
//| Format price with correct decimal places                      |
//+------------------------------------------------------------------+

string FormatPrice(double price, const string symbol)
{
    int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
    return DoubleToString(price, digits);
}

//+------------------------------------------------------------------+
//| Get Bar count for symbol and timeframe                        |
//+------------------------------------------------------------------+

int GetBarCount(const string symbol, ENUM_TIMEFRAMES timeframe)
{
    return Bars(symbol, timeframe);
}

//+------------------------------------------------------------------+
//| Verify symbol exists and is available                         |
//+------------------------------------------------------------------+

bool SymbolAvailable(const string symbol)
{
    return SymbolSelect(symbol, true);
}

//+------------------------------------------------------------------+
//| Print formatted log message                                   |
//+------------------------------------------------------------------+

void LogMessage(const string message, const string level = "INFO")
{
    PrintFormat("%s [%s] %s", TimeToString(TimeCurrent()), level, message);
}

//+------------------------------------------------------------------+
//| Convert signal type to string                                 |
//+------------------------------------------------------------------+

string SignalToString(SignalType signal)
{
    switch(signal)
    {
        case SIGNAL_BUY:
            return "BUY";
        case SIGNAL_SELL:
            return "SELL";
        case SIGNAL_WAIT:
            return "WAIT";
        default:
            return "UNKNOWN";
    }
}

//+------------------------------------------------------------------+
//| Convert trend type to string                                  |
//+------------------------------------------------------------------+

string TrendToString(TrendType trend)
{
    switch(trend)
    {
        case TREND_BULLISH:
            return "BULL";
        case TREND_BEARISH:
            return "BEAR";
        case TREND_NEUTRAL:
            return "WAIT";
        default:
            return "???";
    }
}

//+------------------------------------------------------------------+
//| Convert setup type to string                                  |
//+------------------------------------------------------------------+

string SetupToString(SetupType setup)
{
    switch(setup)
    {
        case SETUP_PULLBACK:
            return "PULLBACK";
        case SETUP_BREAKOUT:
            return "BREAKOUT";
        case SETUP_RETEST:
            return "RETEST";
        case SETUP_MOMENTUM:
            return "MOMENTUM";
        case SETUP_TRENDCONTINUATION:
            return "TREND";
        default:
            return "WAIT";
    }
}

//+------------------------------------------------------------------+
//| Convert entry readiness to string                            |
//+------------------------------------------------------------------+

string EntryToString(EntryReadiness entry)
{
    switch(entry)
    {
        case ENTRY_READY:
            return "READY";
        case ENTRY_PENDING:
            return "PENDING";
        default:
            return "WAIT";
    }
}

#endif
