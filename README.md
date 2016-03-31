[![Build Status](https://travis-ci.org/the-guitarman/club_homepage.svg?branch=master)](https://travis-ci.org/the-guitarman/club_homepage)
[![Code Climate](https://codeclimate.com/github/the-guitarman/club_homepage/badges/gpa.svg)](https://codeclimate.com/github/the-guitarman/club_homepage)
[![Built with Spacemacs](https://cdn.rawgit.com/syl20bnr/spacemacs/442d025779da2f62fc86c2082703697714db6514/assets/spacemacs-badge.svg)](http://github.com/syl20bnr/spacemacs)

*Attention:* This is an after work project and neither it's finished nor it's ready for production usage.

# Club Homepage

This is a website skeleton for your soccer or handball club. It's a phoenixframework projekt written in elixir. The intension is not only the inform about the club. There is a back office to register and edit club members, create and edit teams, match lists, team selections and club news and there will be live events from running matches via channels (socket connections) so that other club members are informed about a running match asap.

## Installation

This is a phoenixframework app. So you need to install some requirements like Erlang, Elixir, Hex package manager, phoenix and node.js. See http://www.phoenixframework.org/docs/installation for more information.

Current Project Versions: 

- Elixir: v1.2.1
- Phoenix: v1.1.4

Now clone the project and install the project dependencies. Run these commands:

````
git clone git@github.com:the-guitarman/club_homepage.git
cd club_homepage
npm install
mix deps.get
````

### Database Setup

The project comes with sqlite support. You are free to use another database linke postgres or mysql. Don't forget to *change the username and password* to a role that has the correct database creation permissions. Therefore please see: 

- lib/club_homepage/repo.ex
- config/(dev|test|prod).exs

Now create and migrate the database:

````
mix ecto.create
mix ecto.migrate
````

## Configuration

### Translations

At the moment there are two languages which you can choose to run your side: english (en) and german (de, default). To change the default to en please edit the locale option within config/config.exs. 

### Seed Data

At first edit priv/repo/seeds.exs. You need to edit the administrator attributes. Don't forget to set a new password. Next you edit the data to fit your needs and provide first setup for your club data. Create the teams of your club, the season you need, the opponent teams of your league, addresses and meeting points. After that you seed your data into the database with one of the following commands: 

For development environment
````
MIX_ENV=dev mix run priv/repo/seeds.exs
````

For production environment:
````
MIX_ENV=prod mix run priv/repo/seeds.exs
````

### Run

For development environment:

````
mix phoenix.server 
````

See `http://localhost:4000`


For production environment:

At first open config/prod.exs and set your host name or ip address.

````
MIX_ENV=prod mix phoenix.server 
````

At this point you should have a running app. Please log in with the administrator user, you seeded in before.

### Edit Text Pages

Please click to open "master data -> text pages" in the top navbar. Text pages are all static sites like "about us", "contact", "chronicle", "registration information" and "sponsors". These sites have no content right now. You may edit the pages now to fill them.

### Logo & Background-Image

To change the logo at the homnepage you need to replace the image `web/static/assets/images/logo.png` with another one.

To change the background image you need to replace the image `web/static/assets/images/background_01.jpg` with another one.

To remove the background image open `web/templates/layout/app.html.eex` and remove the css class `background-image-01` from the body element.

## License

This project has a dual license.

This package is licensed under
the **LGPL 3.0**. Do whatever you want with it, but please give improvements and bugfixes back so everyone can benefit.

For commercial usage please contact me at first.

*Note:* Everything may break at every time.

## ToDos

- [ ] README.md
- [ ] Design
  - [ ] apple-touch-icon-precomposed.png
  - [ ] apple-touch-icon.png
- [ ] Plug
  - [ ] Permalink detection
- [ ] Models + Tests
  - [x] Address, with lat/lng
  - [x] Competition
  - [x] Match
  - [ ] MatchEvent, e.g.: foul, red/yellow card
  - [ ] MatchEventHistory
  - [ ] MatchPlayerPlan
  - [ ] MatchPlayer
  - [x] MeetingPoint
  - [x] News
  - [x] OpponentTeam
  - [x] Permalink
  - [x] Season
  - [x] Secret
  - [x] Team
  - [x] TextPage (about us, chronicle, ... + medium editor)
  - [x] User
- [ ] Commands + Tests
  - [ ] UserRole
- [ ] Controllers + Tests
  - [x] create permalink redirection after slug change
- [ ] Sites
  - [ ] Homepage
    - [ ] no user is logged in, so show public news only
    - [ ] a user is logged in, show all news
    - [ ] show a list of active teams from current season
    - [ ] show a list of last matches, one for each active team
    - [ ] show a list of next matches, one for each active team
  - [ ] Back Office
    - [x] Redirect after login

# Help & Donation

Better ideas and solutions are gladly accepted. If you want to donate this project please use this link: https://paypal.me/guitarman/5
