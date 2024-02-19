# Initializer to register event listeners via the Wisper (https://github.com/krisleech/wisper) gem
Rails.application.reloader.to_prepare do
  #Send emails when school activated by making visible
  Wisper.subscribe(Onboarding::OnboardingDataEnabledListener.new)
  #Invalidate cached calendars when they are edited
  Wisper.subscribe(CalendarEventListener.new)
end if false
