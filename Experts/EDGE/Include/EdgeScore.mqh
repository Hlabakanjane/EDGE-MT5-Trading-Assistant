//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Edge Score Calculator            |
//| Calculates probability score from 0-100                        |
//+------------------------------------------------------------------+

#ifndef __EDGE_SCORE_MQH__
#define __EDGE_SCORE_MQH__

#include "Settings.mqh"
#include "Utilities.mqh"
#include "TrendEngine.mqh"
#include "MarketStructure.mqh"
#include "EntryEngine.mqh"

//+------------------------------------------------------------------+
//| Calculate EDGE Score (0-100)                                 |
//+------------------------------------------------------------------+

int CalculateEdgeScore(const string symbol)
{
    int score = 0;
    int maxScore = 100;
    
    // 1. Daily Trend Component (20%)
    TrendType trendD1 = CheckDailyTrend(symbol);
    if(trendD1 != TREND_NEUTRAL)
        score += 20;
    
    // 2. H4 Confirmation Component (20%)
    TrendType trendH4 = CheckH4Trend(symbol);
    if(trendD1 == trendH4 && trendH4 != TREND_NEUTRAL)
        score += 20;
    
    // 3. H1 Setup Quality (20%)
    SetupType setupH1 = DetectH1Setup(symbol);
    if(setupH1 != SETUP_NONE)
        score += 20;
    
    // 4. M15 Entry Confirmation (15%)
    EntryReadiness entryM15 = ConfirmM15Entry(symbol);
    if(entryM15 == ENTRY_READY)
        score += 15;
    else if(entryM15 == ENTRY_PENDING)
        score += 8;
    
    // 5. EMA Alignment (10%)
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    int idx = GetSymbolIndex(symbol);
    if(idx >= 0)
    {
        double emaD1 = GetEMA(symbol, TIMEFRAME_D1, gHandleEMA_D1[idx]);
        double emaH4 = GetEMA(symbol, TIMEFRAME_H4, gHandleEMA_H4[idx]);
        double emaH1 = GetEMA(symbol, TIMEFRAME_H1, gHandleEMA_H1[idx]);
        
        // Check alignment
        bool aligned = false;
        if(trendD1 == TREND_BULLISH && price > emaD1 && price > emaH4 && price > emaH1)
            aligned = true;
        if(trendD1 == TREND_BEARISH && price < emaD1 && price < emaH4 && price < emaH1)
            aligned = true;
        
        if(aligned)
            score += 10;
    }
    
    // 6. Momentum Strength (15%)
    double rsi = GetRSI(symbol, TIMEFRAME_H1, 14);
    double macdLine, signalLine;
    bool macdOK = GetMACD(symbol, TIMEFRAME_H1, macdLine, signalLine);
    
    if(macdOK)
    {
        // Strong bullish momentum
        if(trendH4 == TREND_BULLISH && rsi > 55.0 && macdLine > signalLine)
            score += 10;
        // Strong bearish momentum
        else if(trendH4 == TREND_BEARISH && rsi < 45.0 && macdLine < signalLine)
            score += 10;
    }
    
    return MathMin(score, maxScore);
}

//+------------------------------------------------------------------+
//| Get score color                                               |
//+------------------------------------------------------------------+

color GetScoreColor(int score)
{
    if(score >= 85)
        return ColorBUY;      // Excellent: Green
    if(score >= 70)
        return clrLightGreen; // Good: Light Green
    if(score >= 50)
        return ColorWAIT;     // Average: Yellow
    return ColorSELL;        // Poor: Red
}

//+------------------------------------------------------------------+
//| Get score rating                                             |
//+------------------------------------------------------------------+

string GetScoreRating(int score)
{
    if(score >= 95)
        return "EXCELLENT";
    if(score >= 85)
        return "VERY STRONG";
    if(score >= 70)
        return "GOOD";
    if(score >= 50)
        return "AVERAGE";
    return "IGNORE";
}

#endif
