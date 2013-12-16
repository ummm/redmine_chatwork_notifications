
module ChatworkNotifications
  module WikiContentPatch
    extend ActiveSupport::Concern

    included do
      unloadable
      after_create :notify_chatwork_after_create
      after_update :notify_chatwork_after_update
    end

    private

    def notify_chatwork_after_create
      if Helpers.active? and Setting.plugin_redmine_chatwork_notifications[:wiki_notify_on_create]
        page = self.page
        comment = self.comments if self.comments.present?
        url = Helpers.wiki_page_url(page)

        title = l("chatwork.wiki_created_notify_title", url: url, project: page.project.name, title: page.pretty_title, user: self.author.name)
        description = l("chatwork.wiki_created_notify_description", comment: comment) if comment

        Helpers.put_chatwork_message [title, description].compact.join("\n")
      end
    end

    def notify_chatwork_after_update
      if Helpers.active? and Setting.plugin_redmine_chatwork_notifications[:wiki_notify_on_update]
        page = self.page
        comment = self.comments if self.comments.present?
        url = Helpers.wiki_page_url(page)

        title = l("chatwork.wiki_updated_notify_title", url: url, project: page.project.name, title: page.pretty_title, user: self.author.name)
        description = l("chatwork.wiki_updated_notify_description", comment: comment) if comment

        Helpers.put_chatwork_message [title, description].compact.join("\n")
      end
    end
  end
end

