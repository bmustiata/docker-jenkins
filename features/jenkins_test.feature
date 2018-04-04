Feature: Jenkins should start.

Scenario: Trying to connect to Jenkins should open the first page.
    Given I open the local jenkins
    When I wait for the jenkins to load
    Then I get the jenkins main page

