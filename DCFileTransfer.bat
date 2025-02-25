robocopy \\SASRVR\D$\Lebanon "F:\San Antonio\Lebanon" /COPYALL /MIR /XO /R:3 /W:1 /LOG:c:\Scripts\Logs\robo_Lebanon.log /NP
robocopy \\SASRVR\D$\LEXAR "F:\San Antonio\LEXAR" /COPYALL /MIR /XO /R:3 /W:1 /LOG:c:\Scripts\Logs\robo_LEXAR.log /NP
robocopy "\\SASRVR\D$\Purchase Orders" "F:\San Antonio\Purchase Orders" /COPYALL /MIR /XO /R:3 /W:1 /LOG:c:\Scripts\Logs\robo_PurchaseOrders.log /NP
robocopy \\SASRVR\D$\Purchase_Orders "F:\San Antonio\Purchase_Orders" /COPYALL /MIR /XO /R:3 /W:1 /LOG:c:\Scripts\Logs\robo_Purchase_Orders.log /NP
robocopy \\SASRVR\D$\Texas "F:\San Antonio\Texas" /COPYALL /MIR /XO /R:3 /W:1 /LOG:c:\Scripts\Logs\robo_Texas.log /NP

