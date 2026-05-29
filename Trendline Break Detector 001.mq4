//+------------------------------------------------------------------+
//|                               TrendlineBreakDetector.mq4         |
//|         Detects and Alerts When a Trendline is Broken            |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input string TrendlineName = "Trendline";  // Name of the trendline to monitor
input bool AlertOnBreak = true;            // Enable alert when the trendline is broken
input bool ExecuteTrade = false;           // Enable trade execution on break
input double LotSize = 0.1;                // Lot size for trade execution
input double StopLossPips = 50;            // Stop loss in pips
input double TakeProfitPips = 100;         // Take profit in pips

//+------------------------------------------------------------------+
//| Main Function                                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   Print("Trendline Break Detector started.");
   while (!IsStopped())
   {
      // Check if the trendline exists
      if (ObjectFind(0, TrendlineName) == -1) {
         Print("Trendline not found: ", TrendlineName);
         Sleep(1000);
         continue;
      }

      // Get trendline properties
      datetime time1 = (datetime)ObjectGetInteger(0, TrendlineName, OBJPROP_TIME1);
      double price1 = ObjectGetDouble(0, TrendlineName, OBJPROP_PRICE1);
      datetime time2 = (datetime)ObjectGetInteger(0, TrendlineName, OBJPROP_TIME2);
      double price2 = ObjectGetDouble(0, TrendlineName, OBJPROP_PRICE2);

      if (time1 == 0 || time2 == 0) {
         Print("Invalid trendline properties.");
         Sleep(1000);
         continue;
      }

      // Calculate the current price on the trendline
      double slope = (price2 - price1) / (time2 - time1);
      double currentTrendlinePrice = price1 + slope * (TimeCurrent() - time1);

      // Get the current market price
      double currentPrice = iClose(Symbol(), 0, 0);

      // Check for trendline break
      bool isBreakUp = (currentPrice > currentTrendlinePrice);
      bool isBreakDown = (currentPrice < currentTrendlinePrice);

      if (isBreakUp || isBreakDown) {
         // Alert on trendline break
         if (AlertOnBreak) {
            string direction = isBreakUp ? "UP" : "DOWN";
            Alert("Trendline Broken! Direction: ", direction, " | Price: ", currentPrice);
            Print("Trendline Broken! Direction: ", direction, " | Price: ", currentPrice);
         }

         // Execute trade on trendline break
         if (ExecuteTrade) {
            ExecuteTradeOnBreak(isBreakUp);
         }

         // Exit after detection
         break;
      }

      Sleep(1000); // Wait for the next check
   }

   Print("Trendline Break Detector stopped.");
}

//+------------------------------------------------------------------+
//| Function to Execute Trade on Trendline Break                    |
//+------------------------------------------------------------------+
void ExecuteTradeOnBreak(bool isBreakUp)
{
   int orderType = isBreakUp ? OP_BUY : OP_SELL;
   double price = isBreakUp ? Ask : Bid;
   double stopLoss = isBreakUp ? price - (StopLossPips * Point) : price + (StopLossPips * Point);
   double takeProfit = isBreakUp ? price + (TakeProfitPips * Point) : price - (TakeProfitPips * Point);

   // Send order
   int ticket = OrderSend(Symbol(), orderType, LotSize, price, 3, stopLoss, takeProfit, "Trendline Break Trade", 0, 0, clrBlue);
   if (ticket < 0) {
      Print("Trade execution failed: ", GetLastError());
   } else {
      Print("Trade executed. Ticket: ", ticket, " | Type: ", isBreakUp ? "BUY" : "SELL");
   }
}

