//+------------------------------------------------------------------+
//|                                             4candle reversal.mq5 |
//|                                                         h.moradi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "h.moradi"
#property link      ""
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;
//this is for test
enum enum_Exit {
  StopReverse=0,
  MAexit=1,
  Bailout=2,
  CandleCount=3,
  rsiExit=4
};

input enum_Exit            Exit_Strategy= 0;
input int                  RSIperiod = 5;//stop and reverse works in here too
input int                  MAperiod = 14;
input ENUM_MA_METHOD       MAmethod = MODE_EMA;
input int                  sellClosingCandle = 37;
input int                  buyClosingCandle = 37;
input int                  Magic = 741;
input int                  StopLoss = 500;
input int                  opentime=23; // Trade Open time
input double               lot=0.01; 
bool timeOk;
double ma[],rsi[];
int totalBars,MA_Handle,RSI_Handle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    trade.SetExpertMagicNumber(Magic);
    MA_Handle = iMA(_Symbol,PERIOD_D1,MAperiod,0,MAmethod,PRICE_CLOSE);
    RSI_Handle = iRSI(_Symbol,PERIOD_D1,RSIperiod,PRICE_CLOSE);
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
   double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   MqlDateTime Time;
   TimeCurrent(Time);
   //Exiting Rules
   //ma exit
  if (Exit_Strategy == 1){
  CopyBuffer(MA_Handle,0,0,1,ma);
     if(SP()>0 && Bid >= ma[0])
     {closeSELL();};
     if(BP()>0 && Ask <= ma[0])
     {closeBUY();};
  }
      // bailout exit
  if (Exit_Strategy == 2 && Time.hour == opentime){
     closeProfitable();
  }
  //candle count exit
  if (Exit_Strategy == 3){
     if(SP()>0 && sellDaysPast()>=sellClosingCandle)closeSELL();
     if(BP()>0 && buyDaysPast()>=buyClosingCandle)closeBUY();
  }
  //rsi exit
  if(Exit_Strategy == 4){
  CopyBuffer(RSI_Handle,0,0,1,rsi);
     if(SP()>0 && rsi[0] <= 30)
     {closeSELL();};
     if(BP()>0 && rsi[0] >= 70)
     {closeBUY();};

  }
   //Entry Rules
        if(Time.hour == opentime)
     {
    int bars = iBars(_Symbol,PERIOD_CURRENT);
    if (totalBars != bars){
    totalBars = bars;
   double close0 = iClose(_Symbol,PERIOD_D1,0);
   double open0 = iOpen(_Symbol,PERIOD_D1,0);
   double close1 = iClose(_Symbol,PERIOD_D1,1);
   double open1 = iOpen(_Symbol,PERIOD_D1,1);
   double close2 = iClose(_Symbol,PERIOD_D1,2);
   double open2 = iOpen(_Symbol,PERIOD_D1,2);
   double close3 = iClose(_Symbol,PERIOD_D1,3);
   double open3 = iOpen(_Symbol,PERIOD_D1,3);
   if(SP()==0 && close0>open0 && close1>open1 && close2>open2 && close3>open3 && close0>close1 && close1>close2 && close2>close3 && Exit_Strategy != 1){
   trade.Sell(lot,_Symbol,Bid,Ask+StopLoss*_Point);
   if(Exit_Strategy == 0 || Exit_Strategy == 4){closeBUY();}
   }
   if(BP()==0 && close0<open0 && close1<open1 && close2<open2 && close3<open3 && close0<close1 && close1<close2 && close2<close3 && Exit_Strategy != 1){
   trade.Buy(lot,_Symbol,Ask,Bid-StopLoss*_Point);
      if(Exit_Strategy == 0 || Exit_Strategy == 4){closeSELL();}
   }
   if(SP()==0 && close0>open0 && close1>open1 && close2>open2 && close3>open3 && close0>close1 && close1>close2 && close2>close3 && Exit_Strategy == 1 && Bid<ma[0]){
   trade.Sell(lot,_Symbol,Bid,Ask+StopLoss*_Point);
   }
   if(BP()==0 && close0<open0 && close1<open1 && close2<open2 && close3<open3 && close0<close1 && close1<close2 && close2<close3 && Exit_Strategy == 1 && Ask>ma[0]){
   trade.Buy(lot,_Symbol,Ask,Bid-StopLoss*_Point);
   }
   
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
void closeProfitable()
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
