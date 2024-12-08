//+------------------------------------------------------------------+
//|                                                   2024EURUSD.mq5 |
//|                                                         h.moradi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "h.moradi"
#property link      "originally for AUDUSD,USDCAD,USDCHF,USDJPY"
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;


input int       Magic = 741;
input int       opentime = 1; // Trade Open hour
input int       closetime = 22; // Trade Close hour
input int       buyExit_days = 2; 
input int       sellExit_days = 1;
input bool      BailoutExit = false;
input double    lot = 0.01; 
bool timeOk;

double cSL;
int totalBars;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    trade.SetExpertMagicNumber(Magic);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   MqlDateTime Time;
   TimeCurrent(Time);
   //Exiting Rules
   if(Time.hour==closetime && !BailoutExit){
     if(buyExit_days == buyDaysPast())
     {closeBUY();}      
     if(sellExit_days == sellDaysPast())
     {closeSELL();}     
   }else{Bailout();}

   //Entry Rules
        if(Time.hour == opentime)
     {
    int bars = iBars(_Symbol,PERIOD_CURRENT);
    if (totalBars != bars){
    totalBars = bars;
   double high1 = iHigh(_Symbol,PERIOD_D1,1);
   double low1 = iLow(_Symbol,PERIOD_D1,1);
   double close1 = iClose(_Symbol,PERIOD_D1,1);
   double open1 = iOpen(_Symbol,PERIOD_D1,1);
   double high2 = iHigh(_Symbol,PERIOD_D1,2);
   double low2 = iLow(_Symbol,PERIOD_D1,2);
   double close2 = iClose(_Symbol,PERIOD_D1,2);
   double open2 = iOpen(_Symbol,PERIOD_D1,2);
   double high3 = iHigh(_Symbol,PERIOD_D1,3);
   double low3 = iLow(_Symbol,PERIOD_D1,3);
   double close3 = iClose(_Symbol,PERIOD_D1,3);
   double open3 = iOpen(_Symbol,PERIOD_D1,3);
   double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(SP()==0 && close1>close2 && close2>close3)trade.Sell(lot,_Symbol,Bid);
   if(BP()==0 && close1<close2 && close2<close3)trade.Buy(lot,_Symbol,Ask);
     
    }
   }
}//end of ontick func
//+------------------------------------------------------------------+
int SP()//sell positions counting
{
   int SELLposition = 0;
   for(int i=PositionsTotal()-1 ; i>=0 ; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
           {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
             {SELLposition = SELLposition + 1;}
           }
         }
      }
return(SELLposition);
}
//+------------------------------------------------------------------+
int BP()//buy positions counting
{
   int BUYposition = 0;
   for(int i=PositionsTotal()-1 ; i>=0 ; i--)
     {
      ulong posTicket = PositionGetTicket(i);
      if(PositionSelectByTicket(posTicket))
        {
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
           {
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
             {BUYposition = BUYposition+1;}
           }
         }
      }
return(BUYposition);
}
//+------------------------------------------------------------------+
void closeBUY()
{
if(PositionsTotal() <= 0)
      return;
   int positions = 0;
   for(int i = PositionsTotal() - 1 ; i>=0 ; i--)
     {
      ulong posticket = PositionGetTicket(i);
      if(PositionSelectByTicket(posticket))
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
           {
            trade.PositionClose(posticket);           
        }
     }
   }   
  }
//+------------------------------------------------------------------+
void closeSELL()
{
if(PositionsTotal() <= 0)
      return;
   int positions = 0;
   for(int i = PositionsTotal() - 1 ; i>=0 ; i--)
     {
      ulong posticket = PositionGetTicket(i);
      if(PositionSelectByTicket(posticket))
        {
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
           {
            trade.PositionClose(posticket);           
        }
     }
   }   
  }
//+------------------------------------------------------------------+
void Bailout()
{
   MqlDateTime PosTime;
   MqlDateTime Time;
   TimeCurrent(Time);
     double ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
     double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
if(PositionsTotal() <= 0)
      return;
   int positions = 0;
   for(int i = PositionsTotal() - 1 ; i>=0 ; i--)
     {
      ulong posticket = PositionGetTicket(i);
      if(PositionSelectByTicket(posticket))
        {
        
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic)
           {
           TimeToStruct(PositionGetInteger(POSITION_TIME),PosTime);
           if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && PositionGetDouble(POSITION_PRICE_OPEN)<ask && PosTime.day_of_year > Time.day_of_year)trade.PositionClose(posticket);         
           if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && PositionGetDouble(POSITION_PRICE_OPEN)>bid && PosTime.day_of_year > Time.day_of_year)trade.PositionClose(posticket);                    
     }
   }   
  }
 } 
//+------------------------------------------------------------------+
int buyDaysPast()
{
int days=0;
   MqlDateTime PosTime;
   MqlDateTime Time;
   TimeCurrent(Time);
   int positions = 0;
   for(int i = PositionsTotal() - 1 ; i>=0 ; i--)
     {
      ulong posticket = PositionGetTicket(i);
      if(PositionSelectByTicket(posticket))
        {        
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
           TimeToStruct(PositionGetInteger(POSITION_TIME),PosTime);
           days = Time.day_of_year - PosTime.day_of_year;       
     }
   }   
  }
  return(days);
 } 
//+------------------------------------------------------------------+
int sellDaysPast()
{
int days=0;
   MqlDateTime PosTime;
   MqlDateTime Time;
   TimeCurrent(Time);
   int positions = 0;
   for(int i = PositionsTotal() - 1 ; i>=0 ; i--)
     {
      ulong posticket = PositionGetTicket(i);
      if(PositionSelectByTicket(posticket))
        {        
         if(PositionGetString(POSITION_SYMBOL) == _Symbol && PositionGetInteger(POSITION_MAGIC) == Magic && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
           {
           TimeToStruct(PositionGetInteger(POSITION_TIME),PosTime);
           days =Time.day_of_year - PosTime.day_of_year;       
     }
   }   
  }
  return(days);
 } 
//+------------------------------------------------------------------+
