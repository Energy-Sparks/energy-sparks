# Initializer to register event listeners via the Wisper (https://github.com/krisleech/wisper) gem

#Send emails when school activated by making visible
if EnergySparks::FeatureFlags.active?(:data_enabled_onboarding)
  Wisper.subscribe(Onboarding::OnboardingDataEnabledListener.new)
else
  Wisper.subscribe(Onboarding::OnboardingListener.new)
end

#Invalidate cached calendars when they are edited
Wisper.subscribe(CalendarEventListener.new)
