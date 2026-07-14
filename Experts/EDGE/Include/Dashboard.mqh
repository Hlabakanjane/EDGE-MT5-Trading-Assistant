//+------------------------------------------------------------------+
//| EDGE MT5 Trading Assistant - Dashboard                         |
//| Professional UI for displaying market scanner results           |
//+------------------------------------------------------------------+

#ifndef __DASHBOARD_MQH__
#define __DASHBOARD_MQH__

#include "Settings.mqh"
#include "Utilities.mqh"

//+------------------------------------------------------------------+
//| Initialize Dashboard                                          |
//+------------------------------------------------------------------+

bool InitializeDashboard()
{
    if(gDashboardCreated)
        return true;
    
    // Create title label
    CreateLabel("EDGE_TITLE", "EDGE MT5 TRADING ASSISTANT - SCANNER v1.0",
                DashboardX, DashboardY, ColorHeader, 12, "Arial");
    
    // Create column headers
    int headerY = DashboardY + 30;
    int colX[] = {DashboardX + 5, DashboardX + 100, DashboardX + 180, DashboardX + 260, 
                  DashboardX + 320, DashboardX + 380, DashboardX + 440, DashboardX + 520, 
                  DashboardX + 620, DashboardX + 720};
    string headers[] = {"SYMBOL", "PRICE", "EMA20", "D1", "H4", "H1", "M15", "SIGNAL", "SCORE", "RATING"};
    
    for(int i = 0; i < ArraySize(headers); i++)
    {
        CreateLabel("HEADER_" + (string)i, headers[i],
                    colX[i], headerY, ColorHeader, 10, "Arial Bold");
    }
    
    // Create data labels for each symbol
    for(int i = 0; i < SYMBOL_COUNT; i++)
    {
        for(int j = 0; j < 10; j++)
        {
            string labelName = "DATA_" + (string)i + "_" + (string)j;
            CreateLabel(labelName, "-",
                       colX[j], headerY + 25 + (i * CellHeight),
                       ColorText, 9, "Arial");
        }
    }
    
    gDashboardCreated = true;
    return true;
}

//+------------------------------------------------------------------+
//| Create Label Object                                           |
//+------------------------------------------------------------------+

void CreateLabel(const string name, const string text, int x, int y,
                 color clr, int fontSize, const string font)
{
    // Check if label already exists
    if(ObjectFind(ChartID(), name) >= 0)
    {
        ObjectSetString(ChartID(), name, OBJPROP_TEXT, text);
        ObjectSetInteger(ChartID(), name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(ChartID(), name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(ChartID(), name, OBJPROP_COLOR, clr);
        ObjectSetInteger(ChartID(), name, OBJPROP_FONTSIZE, fontSize);
        return;
    }
    
    // Create new label
    ObjectCreate(ChartID(), name, OBJ_LABEL, 0, 0, 0);
    ObjectSetString(ChartID(), name, OBJPROP_TEXT, text);
    ObjectSetInteger(ChartID(), name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(ChartID(), name, OBJPROP_YDISTANCE, y);
    ObjectSetInteger(ChartID(), name, OBJPROP_COLOR, clr);
    ObjectSetInteger(ChartID(), name, OBJPROP_FONTSIZE, fontSize);
    ObjectSetString(ChartID(), name, OBJPROP_FONT, font);
}

//+------------------------------------------------------------------+
//| Update Dashboard                                             |
//+------------------------------------------------------------------+

void UpdateDashboard(const MarketData &data[])
{
    if(!gDashboardCreated)
        return;
    
    int colX[] = {DashboardX + 5, DashboardX + 100, DashboardX + 180, DashboardX + 260,
                  DashboardX + 320, DashboardX + 380, DashboardX + 440, DashboardX + 520,
                  DashboardX + 620, DashboardX + 720};
    int headerY = DashboardY + 30;
    
    for(int i = 0; i < ArraySize(data); i++)
    {
        if(data[i].symbol == "")
            continue;
        
        int rowY = headerY + 25 + (i * CellHeight);
        
        // Symbol
        UpdateLabel("DATA_" + (string)i + "_0", data[i].symbol, colX[0], rowY, ColorText);
        
        // Price
        UpdateLabel("DATA_" + (string)i + "_1", FormatPrice(data[i].price, data[i].symbol), colX[1], rowY, ColorText);
        
        // EMA20
        UpdateLabel("DATA_" + (string)i + "_2", FormatPrice(data[i].ema20, data[i].symbol), colX[2], rowY, ColorText);
        
        // D1 Trend
        UpdateLabel("DATA_" + (string)i + "_3", TrendToString(data[i].trendD1), colX[3], rowY, ColorText);
        
        // H4 Trend
        UpdateLabel("DATA_" + (string)i + "_4", TrendToString(data[i].trendH4), colX[4], rowY, ColorText);
        
        // H1 Setup
        UpdateLabel("DATA_" + (string)i + "_5", SetupToString(data[i].setupH1), colX[5], rowY, ColorText);
        
        // M15 Entry
        UpdateLabel("DATA_" + (string)i + "_6", EntryToString(data[i].entryM15), colX[6], rowY, ColorText);
        
        // Signal
        color signalColor = (data[i].signal == SIGNAL_BUY) ? ColorBUY :
                           (data[i].signal == SIGNAL_SELL) ? ColorSELL : ColorWAIT;
        UpdateLabel("DATA_" + (string)i + "_7", SignalToString(data[i].signal), colX[7], rowY, signalColor);
        
        // Score
        UpdateLabel("DATA_" + (string)i + "_8", (string)data[i].edgeScore + "%", colX[8], rowY, GetScoreColor(data[i].edgeScore));
        
        // Rating
        UpdateLabel("DATA_" + (string)i + "_9", GetScoreRating(data[i].edgeScore), colX[9], rowY, GetScoreColor(data[i].edgeScore));
    }
}

//+------------------------------------------------------------------+
//| Update Existing Label                                        |
//+------------------------------------------------------------------+

void UpdateLabel(const string name, const string text, int x, int y, color clr)
{
    if(ObjectFind(ChartID(), name) >= 0)
    {
        ObjectSetString(ChartID(), name, OBJPROP_TEXT, text);
        ObjectSetInteger(ChartID(), name, OBJPROP_COLOR, clr);
    }
}

//+------------------------------------------------------------------+
//| Clean up Dashboard                                           |
//+------------------------------------------------------------------+

void CleanupDashboard()
{
    for(int i = 0; i < 1000; i++)
    {
        if(ObjectFind(ChartID(), "EDGE_TITLE") >= 0)
            ObjectDelete(ChartID(), "EDGE_TITLE");
        if(ObjectFind(ChartID(), "HEADER_" + (string)i) >= 0)
            ObjectDelete(ChartID(), "HEADER_" + (string)i);
        if(ObjectFind(ChartID(), "DATA_" + (string)i) >= 0)
            ObjectDelete(ChartID(), "DATA_" + (string)i);
    }
    gDashboardCreated = false;
}

#endif
