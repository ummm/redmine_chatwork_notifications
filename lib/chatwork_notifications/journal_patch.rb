
module ChatworkNotifications
  module JournalPatch
    extend ActiveSupport::Concern

    included do
      unloadable
      after_create :notify_chatwork_after_create
    end

    private

    def notify_chatwork_after_create
      if Helpers.active? and Setting.plugin_redmine_chatwork_notifications[:issue_notify_on_update] and not self.private_notes? and not self.issue.is_private?
        notes = Helpers.truncate_words(self, :notes)
        url = Helpers.issue_url(self.issue)

        title = l("chatwork.issue_updated_notify_title", id: self.issue.id, url: url, title: self.issue.subject, user: self.user.name)
        description = l("chatwork.issue_updated_notify_description", comment: notes) if notes

        Helpers.put_chatwork_message [title, description.presence].compact.join("\n#{"-"*40}\n")
      end
    end 
  end
end

