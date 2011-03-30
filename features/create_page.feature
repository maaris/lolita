Feature: Create pages
    In order to manage content
    As lolita user
    I want to create posts

    Scenario: List and create new with valid data
      When I go to list
      And I follow "Add new post"
      And I fill in "Title" with "Lolita is nice"
      When I press "Save" within ".save"
      Then I should see "Successfully saved"
      When I follow "Post"
      #Then I should see "Lolita is nice"
      
		Scenario: List and create new with invalid data
			When I go to list
	      And I follow "Add new post"
	      When I press "Save" within ".save"
	      Then I should see "Save did not succeed"
	      When I follow "Post"