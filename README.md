# TODO

# Top Employers Institute assignment

## Instructions

1. Create a Salesforce playground and create a custom LWC component page that lists all accounts from the org inside panels in a grid layout.

    Initially show 4 panels per row, every panel should contain the account name in the header area and under the header it should have a section showing two account fields: the ticker symbol and annual revenue.

    Under this section the panel should show 3 tabs, "Contact Relations (n)", "Contacts (n)" and "Opportunities (n)":
    - The "Contact Relations" tab should list all related contact relations, every row should show only the contact name and the created date.
    - The "Contacts" tab should list all related contacts, every row should show only the contact name and the created date.
    - The "Opportunities" tab should list all related opportunities, every row should show only the opportunity name and the amount.

    All records should be sorted by name and every tab should contain in the title the number of related records.
    Every record name should be clickable and navigate to the record detail page after clicking on it.
    The UI should adapt to smaller device sizes, like phones and tablets.

2. Create two fields on Account: Business_Users__c and Decision_Makers__c.

    Use a trigger to update these two fields to always contain the number of related contacts with the role "Business User" and "Decision Maker" respectively.

3. Add the new fields "Business_Users__c" and "Decision_Makers__c" to the account overview panels, place them under the ticker symbol and annual revenue.

    Add a clickable control element to every row in the "Contact Relations" tab, to enable the user to edit the assigned roles. The UI should reflect the changes done when the user updated the roles.

4. Optional: Implement a solution so that when the number of records increases in the future, the solution will still remain performant.

## General guidelines

- Create a Salesforce Developer account or Trailhead Playground for this assignment and build it as a SFDX project.
- Try to use standard LWC Salesforce components and the SLDS library when possible and follow best practices for the implementation.
- Use system labels whenever possible.
- Please commit to a public repository on GitHub and share the path with us, make sure to commit all the necessary items (lwc components, flexipage etc.)
- Use branches and commits following best practices.
- Include a README page with the instructions necessary to deploy and run the project.

## How to deploy

# TODO