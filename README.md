# On The Map

The On The Map is result of **iOS Networking with Swift** lesson of **Udacity's iOS Developer Nanodegree** course.

The On The Map app allows udacity students to share their location and a URL with their fellow students. To visualize this 
data, On The Map uses a map with pins for location and pin annotations for student names and URLs. 

First, the user logs in to the app using their Udacity username and password. 

After login, the app downloads locations and links previously posted by other students. These links can point to any URL 
that a student shares. After viewing the information posted by other students, a user can post their own location and link. The locations are specified with a string and forward geocoded. They can be as specific as a full street address or as generic as “Moscow, Russia” or “Palo Alto, CA”

## Implementation

The app has four view controller scenes:

- **LoginController** - allows the user to log in using their Udacity credentials. 
  
  When the user taps the Login button, the app will attempt to authenticate with Udacity’s servers. Clicking on the Sign Up link will open Safari to the Udacity sign-in page.
  
  If the login does not succeed, the user will be presented with an alert view specifying whether it was a failed network connection, or an incorrect email and password.

- **MapController** - displays a map with pins specifying the last 100 locations posted by students. 
  
  When the user taps a pin, it displays the pin annotation popup, with the student’s name (pulled from their Udacity profile) and the link associated with the student’s pin.
  
  Tapping anywhere within the annotation will launch Safari and direct it to the link associated with the pin.

- **ListController** - displays the most recent 100 locations posted by students in a table. Each row displays the name from the student’s Udacity profile. Tapping on the row launches Safari and opens the link associated with the student.

- **PinController** - allows users to input data in two steps: first adding their location string, then their link.
  
  When the user clicks on the “Find on the Map” button, the app will forward geocode the string. If the forward geocode fails, the app will display an alert view notifying the user.

## Requirements

 - Xcode 10
 - Swift 4.0
 
<p float="center">
<img src="https://user-images.githubusercontent.com/26684339/57973948-6edac680-7965-11e9-97ef-6411ea03eb89.png" width="250">
<img src="https://user-images.githubusercontent.com/26684339/57973949-6edac680-7965-11e9-938a-ffda4371b4c5.png" width="250">
<img src="https://user-images.githubusercontent.com/26684339/57973950-6f735d00-7965-11e9-85b6-75c484d55d6b.png" width="250">
<img src="https://user-images.githubusercontent.com/26684339/57973951-6f735d00-7965-11e9-92c3-b320d619c8d8.png" width="250">
<img src="https://user-images.githubusercontent.com/26684339/57973952-6f735d00-7965-11e9-995c-f098551b94cf.png" width="250">
<img src="https://user-images.githubusercontent.com/26684339/57973953-6f735d00-7965-11e9-8adb-cf6d8f1b7a99.png" width="250">
</p>
