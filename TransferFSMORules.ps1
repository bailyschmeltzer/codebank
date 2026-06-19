# Purpose: Transfer all FSMO roles to a designated domain controller.
#Change name of DC to server the roles are being moved to
Move-ADDirectoryServerOperationMasterRole -Identity "MilkywayDC2" -OperationMasterRole PDCEmulator,RIDMaster,InfrastructureMaster,SchemaMaster,DomainNamingMaster

#Confirm roles transferred
# Validate that all five FSMO roles now point to the target DC.
netdom query fsmo