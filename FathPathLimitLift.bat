:: Purpose: Enable long file path support in Windows.
:: Sets LongPathsEnabled to 1 so Win32 APIs can use paths beyond MAX_PATH.
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f