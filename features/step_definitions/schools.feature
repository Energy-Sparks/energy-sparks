Feature: Display Schools
  In order to see how my school is using energy
  As a user
  I want to browse schools and see detailed information

  Scenario: show school
    Given a school exists with name: "Oldfield Park Infants"
    When I go to the school's page
    Then I should see "Oldfield Park Infants"