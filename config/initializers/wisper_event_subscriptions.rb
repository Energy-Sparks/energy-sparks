# Initializer to register event listeners via the Wisper (https://github.com/krisleech/wisper) gem

#Monitor when school has been regenerated so we can show school target progress report
Wisper.subscribe(Targets::ContentGenerationListener.new, :ContentBatch)

#Send emails when school activated by making visible
if EnergySparks::FeatureFlags.active?(:data_enabled_onboarding)
  Wisper.subscribe(Onboarding::OnboardingDataEnabledListener.new)
else
  Wisper.subscribe(Onboarding::OnboardingListener.new)
end
