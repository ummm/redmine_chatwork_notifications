
require 'redmine'
require 'chatwork_notifications'

Rails.configuration.to_prepare do
  require_dependency 'issue'
  unless Issue.included_modules.include? ChatworkNotifications::IssuePatch
    Issue.send(:include, ChatworkNotifications::IssuePatch)
  end

  require_dependency 'journal'
  unless Journal.included_modules.include? ChatworkNotifications::JournalPatch
    Journal.send(:include, ChatworkNotifications::JournalPatch)
  end 

  require_dependency 'wiki_content'
  unless WikiContent.included_modules.include? ChatworkNotifications::WikiContentPatch
    WikiContent.send(:include, ChatworkNotifications::WikiContentPatch)
  end
end

Redmine::Plugin.register :redmine_chatwork_notifications do
  name 'Redmine Chatwork Notifications plugin'
  author 'Office UMMM'
  description 'A plugin to display activity notifications on chatwork'
  version '0.0.1'
  url 'https://ummm.github.io/redmine_chatwork_notifications'
  author_url 'https://github.com/ummm'

  settings partial: 'settings/chatwork_notifications', default: {
    'room_id' => nil,
    'issue_notify_on_create' => true,
    'issue_notify_on_update' => true,
    'issue_description_max_lines' => 5,
    'issue_description_max_words' => 100,
    'wiki_notify_on_create' => true,
    'wiki_notify_on_update' => true,
  }
end

