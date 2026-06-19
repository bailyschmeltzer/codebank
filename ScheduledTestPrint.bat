:: Purpose: Send test print jobs to production printers.
:: Sends the same validation PDF to two queues for quick output checks.
print /d:\\mwaaf-fs02\DEL-PROD-HONDAD \\mwaaf-fs02\netlogon\TEST PRINT.pdf
print /d:\\mwaaf-fs02\DEL-PROD-HONDAH \\mwaaf-fs02\netlogon\TEST PRINT.pdf