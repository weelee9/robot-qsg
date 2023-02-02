*** Settings ***
Documentation    Introduction to robotframework's test cases

# Importing keywords from libraries
Library          lib/LoginLibrary.py
Library          OperatingSystem

# Executes keywords before/after each test
Suite Setup      Clear login database
Suite Teardown   Clear login database

# Tags can be used to select groups of tests to be executed
# Reports can also produce statistics based on tags
Force Tags       quickstart
Default Tags     example    smoke

*** Test Cases ***
User can create account and log in
    Create valid user    fred    P4ssw0rd
    Attempt to Login with Credentials    fred    P4ssw0rd
    Status Should Be    Logged In

User cannot log in with bad password
    Create valid user    betty    P4ssw0rd
    Attempt to Login with Credentials    betty    wrong
    Status Should Be    Access Denied

# given-when-then format for writing test cases (behaviour driven development)
User can change password
    Given A user has a valid account
    When She changes her password
    Then She can log in with the new password
    And She cannot use the old password anymore

# Using tags and variables
User status is stored in database
    [Tags]    variables    database
    Create valid user    ${USERNAME}    ${PASSWORD}
    Database should contain    ${USERNAME}    ${PASSWORD}    Inactive
    Login    ${USERNAME}    ${PASSWORD}
    Database should contain    ${USERNAME}    ${PASSWORD}    Active

# Data-driven testing using Template setting
Invalid password
    [Template]    Creating user with invalid password should fail
    abCD5            ${PWD INVALID LENGTH}
    abCD567890123    ${PWD INVALID LENGTH}
    123DEFG          ${PWD INVALID CONTENT}
    abcd56789        ${PWD INVALID CONTENT}
    AbCdEfGh         ${PWD INVALID CONTENT}
    abCD56+          ${PWD INVALID CONTENT}

*** Keywords ***
Clear login database
    Remove file    ${DATABASE FILE}

Create valid user
    [Arguments]    ${username}    ${password}
    Create User    ${username}    ${password}
    Status Should Be    SUCCESS

Creating user with invalid password should fail
    [Arguments]    ${password}    ${error}
    Create User    example    ${password}
    Status Should Be    Creating user failed: ${error}

Login
    [Arguments]    ${username}    ${password}
    Attempt To Login With Credentials    ${username}    ${password}
    Status should be    Logged In

Database should contain
    [Arguments]    ${username}    ${password}    ${status}
    ${database} =     Get File    ${DATABASE FILE}
    Should Contain    ${database}    ${username}\t${password}\t${status}\n

# Keywords for higher level tests
A user has a valid account
    Create valid user    ${USERNAME}    ${PASSWORD}

She changes her password
    Change Password    ${USERNAME}    ${PASSWORD}    ${NEW PASSWORD}
    Status Should Be    SUCCESS

She can log in with the new password
    Login    ${USERNAME}    ${NEW PASSWORD}

She cannot use the old password anymore
    Attempt To Login With Credentials    ${USERNAME}    ${PASSWORD}
    Status Should Be    Access Denied

*** Variables ***
${USERNAME}               janedoe
${PASSWORD}               J4N3d0E
${NEW PASSWORD}           e0D3n4J
# Python login script is using a temporary directory
${DATABASE FILE}          ${TEMPDIR}/robotframework-quickstart-db.txt
${PWD INVALID LENGTH}     Password must be 7-12 characters long
${PWD INVALID CONTENT}    Password must be a combination of lowercase and uppercase letters and numbers