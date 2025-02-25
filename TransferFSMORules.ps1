#Change name of DC to server the roles are being moved to
Move-ADDirectoryServerOperationMasterRole -Identity "MilkywayDC2" -OperationMasterRole PDCEmulator,RIDMaster,InfrastructureMaster,SchemaMaster,DomainNamingMaster

#Confirm roles transferred
netdom query fsmo