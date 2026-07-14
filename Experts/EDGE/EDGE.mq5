//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant                                    |
//| Professional Market Scanner Expert Advisor                    |
//| Purpose: Scan multiple markets every 60 seconds               |
//| Never places trades - Scanner only                            |
//+------------------------------------------------------------------+

#property copyright   "Hlabakanjane"
#property link        "https://github.com/Hlabakanjane/EDGE-MT5-Trading-Assistant"
#property version     "1.0"
#property strict
#property description "EDGE MT5 Trading Assistant - Multi-Timeframe Market Scanner"

// Include all modules
#include "Include/Settings.mqh"
#include "Include/Utilities.mqh"
#include "Include/TrendEngine.mqh"
#include "Include/MarketStructure.mqh"
#include "Include/EntryEngine.mqh"
#include "Include/EdgeScore.mqh"
#include "Include/Dashboard.mqh"
#include "Include/SymbolScanner.mqh"
#include "Include/Alerts.mqh"

//+------------------------------------------------------------------+
//| Expert Advisor Initialization                                 |
//+------------------------------------------------------------------+

int OnInit()
{
    LogMessage("EDGE MT5 Trading Assistant Starting...", "INFO");
    
    // Initialize indicator handles
    if(!InitializeIndicatorHandles())
    {
        LogMessage("Failed to initialize indicator handles", "ERROR");
        return INIT_FAILED;
    }
    
    // Initialize market data array
    ArrayResize(gMarketData, SYMBOL_COUNT);
    for(int i = 0; i < SYMBOL_COUNT; i++)
    {
        gMarketData[i].symbol = "";
        gMarketData[i].price = 0.0;
        gMarketData[i].ema20 = 0.0;
        gMarketData[i].edgeScore = 0;
    }
    
    // Initialize dashboard
    if(!InitializeDashboard())
    {
        LogMessage("Failed to initialize dashboard", "WARN");
    }
    
    // Set timer for periodic scanning
    if(!EventSetTimer(RefreshTime))
    {
        LogMessage("Failed to set timer", "ERROR");
        return INIT_FAILED;
    }
    
    LogMessage("EDGE MT5 Trading Assistant Ready (Refresh: " + (string)RefreshTime + "s)", "INFO");
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert Advisor Deinitialization                               |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{
    LogMessage("EDGE MT5 Trading Assistant Shutting Down...", "INFO");
    
    // Kill timer
    EventKillTimer();
    
    // Release all indicator handles
    ReleaseIndicatorHandles();
    
    // Clean up dashboard
    CleanupDashboard();
    
    LogMessage("EDGE MT5 Trading Assistant Stopped", "INFO");
}

//+------------------------------------------------------------------+
//| Timer Event - Main Scanning Loop                             |
//+------------------------------------------------------------------+

void OnTimer()
{
    // Perform full market scan
    if(!ScanAllSymbols())
    {
        LogMessage("Failed to scan symbols", "ERROR");
        return;
    }
    
    // Update dashboard
    UpdateDashboard(gMarketData);
    
    // Check for high probability signals and send alerts
    CheckForHighProbabilitySignals();
    
    // Print results to journal (optional, comment out for performance)
    PrintScannerResults();
    
    gLastRefreshTime = GetTickCount();
}

//+------------------------------------------------------------------+
//| Chart Event Handler                                          |
//+------------------------------------------------------------------+

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    // Handle chart events if needed
}

//+------------------------------------------------------------------+
//| Tick Event (for monitoring purposes)                         |
//+------------------------------------------------------------------+

void OnTick()
{
    // Tick processing if needed
    // Most scanning is done via OnTimer
}

//+------------------------------------------------------------------+
// END OF EXPERT ADVISOR
//+------------------------------------------------------------------+
