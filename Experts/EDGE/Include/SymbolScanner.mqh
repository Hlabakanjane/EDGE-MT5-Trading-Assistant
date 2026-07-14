//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Symbol Scanner                   |
//| Main scanning loop that processes all symbols                  |
//+------------------------------------------------------------------+

#ifndef __SYMBOL_SCANNER_MQH__
#define __SYMBOL_SCANNER_MQH__

#include "Settings.mqh"
#include "TrendEngine.mqh"
#include "MarketStructure.mqh"
#include "EntryEngine.mqh"
#include "EdgeScore.mqh"
#include "Dashboard.mqh"
#include "Utilities.mqh"

//+------------------------------------------------------------------+
//| Initialize Indicator Handles                                  |
//+------------------------------------------------------------------+

bool InitializeIndicatorHandles()
{
    ArrayResize(gHandleEMA_D1, SYMBOL_COUNT, 0);
    ArrayResize(gHandleEMA_H4, SYMBOL_COUNT, 0);
    ArrayResize(gHandleEMA_H1, SYMBOL_COUNT, 0);
    ArrayResize(gHandleEMA_M15, SYMBOL_COUNT, 0);
    
    for(int i = 0; i < SYMBOL_COUNT; i++)
    {
        gHandleEMA_D1[i] = INVALID_HANDLE;
        gHandleEMA_H4[i] = INVALID_HANDLE;
        gHandleEMA_H1[i] = INVALID_HANDLE;
        gHandleEMA_M15[i] = INVALID_HANDLE;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Release All Indicator Handles                                |
//+------------------------------------------------------------------+

void ReleaseIndicatorHandles()
{
    for(int i = 0; i < SYMBOL_COUNT; i++)
    {
        if(gHandleEMA_D1[i] != INVALID_HANDLE)
            IndicatorRelease(gHandleEMA_D1[i]);
        if(gHandleEMA_H4[i] != INVALID_HANDLE)
            IndicatorRelease(gHandleEMA_H4[i]);
        if(gHandleEMA_H1[i] != INVALID_HANDLE)
            IndicatorRelease(gHandleEMA_H1[i]);
        if(gHandleEMA_M15[i] != INVALID_HANDLE)
            IndicatorRelease(gHandleEMA_M15[i]);
    }
}

//+------------------------------------------------------------------+
//| Scan All Symbols                                             |
//+------------------------------------------------------------------+

bool ScanAllSymbols()
{
    ArrayResize(gMarketData, SYMBOL_COUNT);
    
    uint startTime = GetTickCount();
    
    for(int i = 0; i < SYMBOL_COUNT; i++)
    {
        string symbol = SYMBOLS[i];
        
        // Select symbol
        if(!SymbolSelect(symbol, true))
        {
            LogMessage("Failed to select symbol: " + symbol, "WARN");
            continue;
        }
        
        // Get basic data
        gMarketData[i].symbol = symbol;
        gMarketData[i].price = SymbolInfoDouble(symbol, SYMBOL_BID);
        gMarketData[i].lastUpdate = TimeCurrent();
        
        if(gMarketData[i].price == 0.0)
        {
            LogMessage("Failed to get price for: " + symbol, "WARN");
            continue;
        }
        
        // Get EMA values
        gMarketData[i].ema20 = GetEMA(symbol, TIMEFRAME_H1, gHandleEMA_H1[i]);
        gMarketData[i].emaSlope = GetEMASlope(symbol, TIMEFRAME_H1, gHandleEMA_H1[i], 5);
        
        // D1 Analysis
        gMarketData[i].trendD1 = CheckDailyTrend(symbol);
        
        // H4 Analysis
        gMarketData[i].trendH4 = CheckH4Trend(symbol);
        
        // H1 Setup Detection
        gMarketData[i].setupH1 = DetectH1Setup(symbol);
        
        // M15 Entry Confirmation
        gMarketData[i].entryM15 = ConfirmM15Entry(symbol);
        
        // Determine Signal
        if(gMarketData[i].trendD1 == TREND_BULLISH && gMarketData[i].trendH4 == TREND_BULLISH)
            gMarketData[i].signal = SIGNAL_BUY;
        else if(gMarketData[i].trendD1 == TREND_BEARISH && gMarketData[i].trendH4 == TREND_BEARISH)
            gMarketData[i].signal = SIGNAL_SELL;
        else
            gMarketData[i].signal = SIGNAL_WAIT;
        
        // Calculate Edge Score
        gMarketData[i].edgeScore = CalculateEdgeScore(symbol);
    }
    
    uint elapsedTime = GetTickCount() - startTime;
    LogMessage("Scan completed in " + (string)elapsedTime + "ms", "INFO");
    
    return true;
}

//+------------------------------------------------------------------+
//| Print Scanner Results                                        |
//+------------------------------------------------------------------+

void PrintScannerResults()
{
    LogMessage("\n=== EDGE SCANNER RESULTS ===", "INFO");
    
    for(int i = 0; i < SYMBOL_COUNT; i++)
    {
        if(gMarketData[i].symbol == "")
            continue;
        
        PrintFormat("%s | D1:%s H4:%s | Setup:%s Entry:%s | Signal:%s | Score:%d",
                    gMarketData[i].symbol,
                    TrendToString(gMarketData[i].trendD1),
                    TrendToString(gMarketData[i].trendH4),
                    SetupToString(gMarketData[i].setupH1),
                    EntryToString(gMarketData[i].entryM15),
                    SignalToString(gMarketData[i].signal),
                    gMarketData[i].edgeScore);
    }
}

#endif
