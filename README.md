Chatmunk
========
A chatbot engine for weather
----------------------------
Using Ruby, Sinatra, Google Maps Geocoding and Dark Sky API's

Installation Guide
------------------
**Installing Ruby on Mac OS:**

If you don't have a recent version of Ruby installed, you can use Homebrew to install Ruby 2.4.1. Although anything above Ruby 2.2 should work fine.

Here are instructions for installing **rbenv** using Homebrew:
https://github.com/rbenv/rbenv#homebrew-on-mac-os-x

Once **rbenv** is installed you can install any version of Ruby and set it as your default Ruby for this project:

```
rbenv install 2.4.1
```
Inside project directory type: `rbenv local 2.4.1`

**Installing dependencies:**

If you don't have it, please first install Ruby Gems:
https://rubygems.org/pages/download/

Then install the following gems with ruby gems by typing:
```
gem install sinatra
gem install sinatra-cross_origin
gem install dotenv
```
You can optionally install `Thin` as the webserver:
```
gem install thin
```

**Create a .env file**
We need to create a `.env` file to store API keys.
Since this file is not committed to the project repo. This allows us to keep the keys private.
```
GMAPS_KEY=<insert Google Maps API key here>
DARKSKY_KEY=<insert Dark Sky API key here>
```

**Running the app!**

Inside the project directory, you can type: `ruby chatmunk.rb`

##### This should take care of it. Congratulations!
---
**Optional: Run the specs**

If you would like to run the specs, you need to install the following gems:
```
gem install rack-test
gem install rspec
gem install webmock
```
After that you can just type `rspec` in the project root directory.
