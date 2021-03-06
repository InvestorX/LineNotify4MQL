//+------------------------------------------------------------------+
//|                                                     linetest.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#include "LineNotify.mqh"
input string ltoken="アクセストークンを入力してください";
input int timer = 2000;//データの更新間隔(ミリ秒）

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   //Print(LineNotify("testDLL なぜ60ってつくのか",ltoken));
   ChartScreenShot(0,"testcap.png",1280,720,ALIGN_RIGHT);
   FileMove("testcap.png",FILE_READ,"testcap.png",FILE_REWRITE|FILE_COMMON);  
   Print(LineNotifyAt("testDLL",ltoken,"testcap.png"));
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
