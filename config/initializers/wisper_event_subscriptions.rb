# Initializer to register event listeners via the Wisper (https://github.com/krisleech/wisper) gem

#Monitor when school has been regenerated so we can show school target progress report
Wisper.subscribe(Targets::ContentGenerationListener.new, :ContentBatch)

#Send emails when school activated by making visible
Wisper.subscribe(Onboarding::OnboardingListener, :SchoolCreator)
