
module ChatworkNotifications
  module IssuePatch
    extend ActiveSupport::Concern

    included do
      unloadable
      after_create :notify_chatwork_after_create
    end

    private

    def notify_chatwork_after_create
      if Helpers.active? and Setting.plugin_redmine_chatwork_notifications[:issue_notify_on_create] and not self.is_private?
        description = Helpers.truncate_words self, :description
        url = Helpers.issue_url(self)

        title = l("chatwork.issue_created_notify_title", id: self.id, url: url, title: self.subject, user: self.author.name)
        description = l("chatwork.issue_created_notify_description", comment: description) if description

        Helpers.put_chatwork_message [title, description.presence].compact.join("\n#{"-"*40}\n")
      end
    end
  end
end

