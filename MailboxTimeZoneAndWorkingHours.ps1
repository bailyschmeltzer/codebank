# Configure the mailbox regional settings for the Bungalow mailbox.
Set-MailboxRegionalConfiguration -Identity "Bungalow" -TimeZone "Eastern Standard Time" -Language 1033

# Set the room mailbox calendar working hours and time zone.
Set-MailboxCalendarConfiguration -Identity "Room" -WorkingHoursStartTime 08:00 -WorkingHoursEndTime 17:00 -WorkingHoursTimeZone "Eastern Standard Time"
