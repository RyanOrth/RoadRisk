# Road Risk

A simple application to give a relative risk amount for driving on particular roads. This
was made for the Casualty Actuarial Society in competition for their inaugrual Hackuary
competition. This was made using Flutter as the front-end and Django for the back-end.

## Usage

This application is currently live at \<insert url\>. With the current data available for this
project, only the area in New York City is fully functioning with all the risk calculations.
Other locations may be ran to get a route with travel distance, travel time, and an estimation
of the risk.

## Development

As mentioned above, this project runs with Flutter and Django. For detailed setup instructions
of both of these, it is best to visit their install instructions at __ and __.

### Dev Setup

To start work on this project, it can be pulled with the following command:

```bash
git clone git@github.com:RyanOrth/RoadRisk.git
```

Then to run the project the process is to first start the backend and then run whatever
version of the frontend is wanted to be worked on.

```bash
cd  django_roadrisk_backend/ && python manage.py runserver
```

Leave the backend running in its own terminal and run the flutter project in a new one.

```bash
flutter run
```

This will run the default version, this can be switched to the preferred version by adding
this tag.

```bash
flutter run -d <platform>
```
### Licence
This project is licensed under the Mozilla Public License Version 2.0
https://www.mozilla.org/en-US/MPL/2.0/
