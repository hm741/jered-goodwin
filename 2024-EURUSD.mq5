//+------------------------------------------------------------------+
//|                                                   2024EURUSD.mq5 |
//|                                                         h.moradi |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "h.moradi"
#property link      ""
#property version   "1.00"
#include <Trade/Trade.mqh>
CTrade trade;

enum enum_Exit {
  TimeBased=0,
  profitableCandle=1,
  StopLoss=2
};

input enum_Exit Exit_Strategy= 0;
input int       Magic = 741;
input int       StopLoss = 250;
input int       opentime=1; // Trade Open time
input int       closetime=3; // Trade Close time
input double    lot=0.01; 
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
  if (Exit_Strategy == 0){
     cSL=NULL;
     if(Time.hour >= closetime)
     {closeAll();};
  }
      
  if (Exit_Strategy == 1 && Time.hour == opentime){
     cSL=NULL;
     closeProfitable();
  }
  
  if (Exit_Strategy == 2){
     cSL=StopLoss;
  }
   //Entry Rules
        if(Time.hour == opentime)
     {
    OrderDelete(); 
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
   double Ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double Bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
   if(SP()==0 && SO()==0 && close1 > high2)trade.SellStop(lot,low1,_Symbol,cSL);
   if(BP()==0 && BO()==0 && close1 < low2)trade.BuyStop(lot,high1,_Symbol,cSL);
 
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
int SO()
{
//sell orders counting
int SELLorder = 0;
for(int v=OrdersTotal()-1 ; v>=0 ; v--)
  {
   ulong orderTicket = OrderGetTicket(v);
   if(OrderSelect(orderTicket))
     {
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == Magic)
        {
         if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_SELL_STOP){SELLorder = SELLorder+1;}
        }
     }
   }
   return(SELLorder);
}
//+------------------------------------------------------------------+
int BO()
{
//buy orders counting
int BUYorder = 0;
for(int v=OrdersTotal()-1 ; v>=0 ; v--)
  {
   ulong orderTicket = OrderGetTicket(v);
   if(OrderSelect(orderTicket))
     {
      if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == Magic)
        {
         if(OrderGetInteger(ORDER_TYPE) == ORDER_TYPE_BUY_STOP){BUYorder = BUYorder+1;}
        }
     }
   }
   return(BUYorder);
}
//+------------------------------------------------------------------+
void OrderDelete()
{
if(OrdersTotal() <= 0)
      return;
   for(int i = OrdersTotal() - 1 ; i>=0 ; i--)
     {
      ulong ticket = OrderGetTicket(i);
      if(OrderSelect(ticket))
        {
         if(OrderGetString(ORDER_SYMBOL) == _Symbol && OrderGetInteger(ORDER_MAGIC) == Magic)
           {          
             trade.OrderDelete(ticket);               
        }
     }
   }   

}
//+------------------------------------------------------------------+
void closeAll()
{
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
