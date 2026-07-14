//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Trend Engine                       |
//| Analyzes EMA and determines market trend (Bullish/Bearish)      |
//+------------------------------------------------------------------+

#ifndef __TREND_ENGINE_MQH__
#define __TREND_ENGINE_MQH__

#include "Settings.mqh"
#include "Utilities.mqh"

//+------------------------------------------------------------------+
//| Get EMA value for specific symbol and timeframe                 |
//+------------------------------------------------------------------+

double GetEMA(const string symbol, ENUM_TIMEFRAMES timeframe, int &handleEMA)
{
    if(handleEMA == INVALID_HANDLE)
    {
        handleEMA = iMA(symbol, timeframe, EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
        if(handleEMA == INVALID_HANDLE)
        {
            Print("Error creating EMA handle for ", symbol, " on ", timeframe);
            return 0.0;
        }
    }
    
    double emaBuffer[];
    ArraySetAsSeries(emaBuffer, true);
    
    if(CopyBuffer(handleEMA, 0, 0, 1, emaBuffer) < 1)
    {
        Print("Error copying EMA buffer for ", symbol);
        return 0.0;
    }
    
    return emaBuffer[0];
}

//+------------------------------------------------------------------+
//| Calculate EMA slope (trend strength)                            |
//+------------------------------------------------------------------+

double GetEMASlope(const string symbol, ENUM_TIMEFRAMES timeframe, int &handleEMA, int period = 5)
{
    if(handleEMA == INVALID_HANDLE)
    {
        handleEMA = iMA(symbol, timeframe, EMA_Period, 0, MODE_EMA, PRICE_CLOSE);
        if(handleEMA == INVALID_HANDLE)
            return 0.0;
    }
    
    double emaBuffer[];
    ArraySetAsSeries(emaBuffer, true);
    
    if(CopyBuffer(handleEMA, 0, 0, period, emaBuffer) < period)
        return 0.0;
    
    double slope = (emaBuffer[0] - emaBuffer[period - 1]) / (period - 1);
    return slope;
}

//+------------------------------------------------------------------+
//| Determine trend: Bullish, Bearish, or Neutral                  |
//+------------------------------------------------------------------+

TrendType DetermineTrend(const string symbol, ENUM_TIMEFRAMES timeframe, int &handleEMA)
{
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double ema = GetEMA(symbol, timeframe, handleEMA);
    double slope = GetEMASlope(symbol, timeframe, handleEMA, 5);
    
    if(ema == 0.0 || price == 0.0)
        return TREND_NEUTRAL;
    
    // Price above EMA and EMA sloping upward = BULLISH
    if(price > ema && slope > MIN_PRICE_CHANGE)
        return TREND_BULLISH;
    
    // Price below EMA and EMA sloping downward = BEARISH
    if(price < ema && slope < -MIN_PRICE_CHANGE)
        return TREND_BEARISH;
    
    return TREND_NEUTRAL;
}

//+------------------------------------------------------------------+
//| Check Daily trend (D1)                                         |
//+------------------------------------------------------------------+

TrendType CheckDailyTrend(const string symbol)
{
    return DetermineTrend(symbol, TIMEFRAME_D1, gHandleEMA_D1[GetSymbolIndex(symbol)]);
}

//+------------------------------------------------------------------+
//| Check 4-Hour trend (H4)                                        |
//+------------------------------------------------------------------+

TrendType CheckH4Trend(const string symbol)
{
    return DetermineTrend(symbol, TIMEFRAME_H4, gHandleEMA_H4[GetSymbolIndex(symbol)]);
}

//+------------------------------------------------------------------+
//| Check 1-Hour trend (H1)                                        |
//+------------------------------------------------------------------+

TrendType CheckH1Trend(const string symbol)
{
    return DetermineTrend(symbol, TIMEFRAME_H1, gHandleEMA_H1[GetSymbolIndex(symbol)]);
}

//+------------------------------------------------------------------+
//| Determine signal bias (BUY/SELL/WAIT) based on D1 and H4       |
//+------------------------------------------------------------------+

SignalType GetSignalBias(const string symbol)
{
    TrendType trendD1 = CheckDailyTrend(symbol);
    TrendType trendH4 = CheckH4Trend(symbol);
    
    // Both Daily and H4 Bullish = BUY Bias
    if(trendD1 == TREND_BULLISH && trendH4 == TREND_BULLISH)
        return SIGNAL_BUY;
    
    // Both Daily and H4 Bearish = SELL Bias
    if(trendD1 == TREND_BEARISH && trendH4 == TREND_BEARISH)
        return SIGNAL_SELL;
    
    // Anything else = WAIT
    return SIGNAL_WAIT;
}

//+------------------------------------------------------------------+
//| Get trend strength (0-100)                                     |
//+------------------------------------------------------------------+

int GetTrendStrength(const string symbol, ENUM_TIMEFRAMES timeframe, int &handleEMA)
{
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double ema = GetEMA(symbol, timeframe, handleEMA);
    double atr = GetATR(symbol, timeframe, 14);
    
    if(ema == 0.0 || atr == 0.0 || price == 0.0)
        return 0;
    
    double distance = MathAbs(price - ema);
    double strength = (distance / atr) * 100;
    
    return (int)MathMin(strength, 100);
}

#endif
