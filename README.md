# redmine_chatwork_notifications

A plugin to display activity notifications on chatwork.

## Installation

- You need Redmine 2.0.0 or later.

- Install the plugin:

  `git clone https://github.com/ummm/redmine_chatwork_notifications.git plugins/redmine_chatwork_notifications`

- copy chatwork.yml.example into config/chatwork.yml with your Chatwork settings

  `cp plugins/redmine_chatwork_notifications/config/chatwork.yml.example config/chatwork.yml`

- bundle install

  this plugin is dependent on [nokogiri](http://nokogiri.org/).  
  `bundle install`

- plugin settings

  Browse to Redmine menu Administration >
  Plugins > Configure (/settings/plugin/redmine_chatwork_notifications)
  select room and Apply.

## License

This software is released under the MIT License, see LICENSE.txt.

