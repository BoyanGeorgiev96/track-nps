# README

## Versions
* Ruby version - 3.1.0

* Rails version - 7.0.2.2

## Project initialization

  $ git clone git@github.com:BoyanGeorgiev96/track-nps.git

  $ rails db:setup

## Running the server and sending requests
Start the server by executing the following command in the terminal:

  $ rails server

A piece of software such as [https://www.postman.com](Postman) with the default headers can be used to send requests to the API.

### POST /survey endpoint

The request both requires and accepts 6 parameters:
score, respondent_class, respondent_id, object_class, object_id, touchpoint

The accepted values are as follows:
score - Integer - between 0 and 10, only whole numbers allowed
respondent_class - String - seller, realtor
respondent_id - Integer, has to exist in the database (use 1 for testing with a real request)
object_class - String - realtor, deal, property
object_id - Integer, has to exist in the database (use 1 for testing with a real request)
touchpoint - String - Currently anything is expected. Could be changed to expect just realtor/deal/property_feedback, just like object_class

### GET /touchpoint endpoint

The request requires only 'touchpoint' to be present as a paramater:

touchpoint - String - anything will work, as long as a touchpoint with the same param has been saved, e.g. 'i_do_not_want_to_see_this_feedback'. As with the POST /survey 'touchpoint' param, it can be changed to accept only realtor/deal/property_feedback if needed.

Optional parameters:
respondent_class, object_class
respondent_class - String - seller, realtor
object_class - String - realtor, deal, property

## Tests
Inside the project directory run:

  $ rspec

The test suite is comprised of 14 tests that cover all the functionalities of the survey_controller.

## Miscellaneous

Code comments can be inspected to understand more about the request handling.
