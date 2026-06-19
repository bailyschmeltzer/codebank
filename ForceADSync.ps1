# Purpose: Trigger an Azure AD Connect delta synchronization.
# Delta sync processes only recent changes instead of a full cycle.
Start-AdSyncSyncCycle -PolicyType Delta