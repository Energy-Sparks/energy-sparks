Feature: Basic checks

  Scenario: user visits the home page
    When I go to the home page
    Then I should see "Energy Sparks"

  Scenario: user visits the for teachers page
    When I go to the for teachers page
    Then I should see "About"

  Scenario: user visits the Contact page
    When I go to the contact page
    Then I should see "Contact"

  Scenario: user visits the Enrol page
    When I go to the enrol page
    Then I should see "Enrol"

  Scenario: user visits the Datasets page
    When I go to the datasets page
    Then I should see "Open data"
