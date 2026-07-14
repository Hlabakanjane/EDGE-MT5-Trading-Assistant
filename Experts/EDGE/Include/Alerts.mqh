//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Alerts System                    |
//| Handles popup, sound, and email alerts                         |
//+------------------------------------------------------------------+

#ifndef __ALERTS_MQH__
#define __ALERTS_MQH__

#include "Settings.mqh"
#include "Utilities.mqh"

//+------------------------------------------------------------------+
//| Send Alert                                                    |
//+------------------------------------------------------------------+

bool SendAlert(const string symbol, const SignalType signal, const int score)
{
    if(score < AlertThreshold)
        return false;
    
    string message = symbol + " - " + SignalToString(signal) + " Signal (Score: " + (string)score + "%+)";
    
    // Popup Alert
    if(EnablePopupAlerts)
    {
        Alert(message);
    }
    
    // Sound Alert
    if(EnableSoundAlerts)
    {
        PlaySound("alert.wav");
    }
    
    // Email Alert
    if(EnableEmailAlerts)
    {
        SendMail("EDGE Scanner Alert", message);
    }
    
    LogMessage(message, "ALERT");
    return true;
}

//+------------------------------------------------------------------+
//| Check for High Probability Signals                           |
//+------------------------------------------------------------------+

bool CheckForHighProbabilitySignals()
{
    for(int i = 0; i < ArraySize(gMarketData); i++)
    {
        if(gMarketData[i].symbol == "")
            continue;
        
        // Skip WAIT signals
        if(gMarketData[i].signal == SIGNAL_WAIT)
            continue;
        
        // Skip low score signals
        if(gMarketData[i].edgeScore < AlertThreshold)
            continue;
        
        // Send alert for BUY/SELL signals
        SendAlert(gMarketData[i].symbol, gMarketData[i].signal, gMarketData[i].edgeScore);
    }
    
    return true;
}

#endif
