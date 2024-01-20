*** Settings ***
Library  SeleniumLibrary
*** Variables ***

*** Test Cases ***
This is sample test case
    [Documentation]  Google test
    [Tags]  regression
    #Open Browser  http://www.google.com  chrome  options=add_argument("--headless");add_argument("--disable-gpu")
    Open Browser  http://www.google.com  firefox  options=add_argument("--headless");add_argument("--disable-gpu")
    Close Browser


*** Keywords ***
