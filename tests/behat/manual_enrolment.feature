@local @local_tenantexample @javascript
Feature: Manual enrolment method in Moodle LMS vs Moodle Workplace
  As a teacher
  I want to be able to enrol users in my course

  Background:
    Given the following "users" exist:
      | username | firstname | lastname | email                    |
      | teacher  | Teacher   | 1        | teacher1@address.invalid |
      | user1    | User      | 1        | user1@address.invalid    |
      | user2    | User      | 2        | user2@address.invalid    |
      | user3    | User      | 3        | user3@address.invalid    |
      | user4    | User      | 4        | user4@address.invalid    |
      | user5    | User      | 5        | user5@address.invalid    |
    And the following "courses" exist:
      | fullname | shortname | category |
      | Course 1 | C1        | 0        |
    And the following "course enrolments" exist:
      | user    | course | role           |
      | teacher | C1     | editingteacher |

  Scenario: Without multitenancy plugin teacher can enrol any users on the site
    When I log in as "teacher"
    And I am on "Course 1" course homepage
    And I navigate to course participants
    And I press "Enrol users"
    And I click on ".form-autocomplete-downarrow" "css_element" in the ".modal-dialog" "css_element"
    # In the enrolment popup teacher can see all 5 users and also an admin.
    And I should see "User 1"
    And I should see "User 2"
    And I should see "User 3"
    And I should see "User 4"
    And I should see "User 5"
    And I should see "Admin User"
    And I click on "User 1" "text" in the ".modal-dialog .form-autocomplete-suggestions" "css_element"
    And I press key "27" in the field "Select users"
    And I click on "Enrol users" "button" in the "Enrol users" "dialogue"
    Then I should see "Student" in the "User 1" "table_row"
    And I navigate to "Users > Enrolment methods" in current page administration
    And I should see "2" in the "Manual enrolments" "table_row"
    And I click on "Enrol users" "link" in the "Manual enrolments" "table_row"
    # In the enrolment selector screen teacher can see remaining 4 users and also an admin as not enrolled.
    And "optgroup[label='Not enrolled users (5)']" "css_element" should exist in the "#addselect" "css_element"
    And "optgroup[label='Enrolled users (2)']" "css_element" should exist in the "#removeselect" "css_element"
    And the "Not enrolled users" select box should contain "User 2 (user2@address.invalid)"
    And the "Not enrolled users" select box should contain "User 3 (user3@address.invalid)"
    And the "Not enrolled users" select box should contain "User 4 (user4@address.invalid)"
    And the "Not enrolled users" select box should contain "User 5 (user5@address.invalid)"
    And I set the field "Not enrolled users" to "User 2"
    And I press "Add"
    And "optgroup[label='Not enrolled users (4)']" "css_element" should exist in the "#addselect" "css_element"
    And "optgroup[label='Enrolled users (3)']" "css_element" should exist in the "#removeselect" "css_element"
    And the "Enrolled users" select box should contain "User 2 (user2@address.invalid)"
    And I follow "Participants"
    And I should see "Student" in the "User 2" "table_row"
    And I log out

  @moodleworkplace
  Scenario: With multitenancy plugin teacher can only enrol users from the same tenant
    And the following tenants exist:
      | name    |
      | Tenant1 |
    And the following users allocations to tenants exist:
      | user    | tenant  |
      | user1   | Tenant1 |
      | user2   | Tenant1 |
      | user3   | Tenant1 |
      | teacher | Tenant1 |
    When I log in as "teacher"
    And I am on "Course 1" course homepage
    And I navigate to course participants
    And I press "Enrol users"
    And I click on ".form-autocomplete-downarrow" "css_element" in the ".modal-dialog" "css_element"
    And I should see "User 1"
    And I should see "User 2"
    And I should see "User 3"
    And I should not see "User 4"
    And I should not see "User 5"
    And I should not see "Admin User"
    # In the enrolment popup teacher can see only users 1-3.
    And I click on "User 1" "text" in the ".modal-dialog .form-autocomplete-suggestions" "css_element"
    And I press key "27" in the field "Select users"
    And I click on "Enrol users" "button" in the "Enrol users" "dialogue"
    Then I should see "Student" in the "User 1" "table_row"
    And I navigate to "Users > Enrolment methods" in current page administration
    And I should see "2" in the "Manual enrolments" "table_row"
    And I click on "Enrol users" "link" in the "Manual enrolments" "table_row"
    # In the enrolment selector screen teacher can see users 2 and 3 only.
    And "optgroup[label='Not enrolled users (2)']" "css_element" should exist in the "#addselect" "css_element"
    And "optgroup[label='Enrolled users (2)']" "css_element" should exist in the "#removeselect" "css_element"
    And the "Not enrolled users" select box should contain "User 2 (user2@address.invalid)"
    And the "Not enrolled users" select box should contain "User 3 (user3@address.invalid)"
    And I should not see "User 4"
    And I should not see "User 5"
    And I should not see "Admin User"
    And I set the field "Not enrolled users" to "User 2"
    And I press "Add"
    And "optgroup[label='Not enrolled users (1)']" "css_element" should exist in the "#addselect" "css_element"
    And "optgroup[label='Enrolled users (3)']" "css_element" should exist in the "#removeselect" "css_element"
    And the "Enrolled users" select box should contain "User 2 (user2@address.invalid)"
    And I follow "Participants"
    And I should see "Student" in the "User 2" "table_row"
    And I log out
