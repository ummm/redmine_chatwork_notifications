
module ChatworkNotifications
  module Helpers
    class << self
      include Rails.application.routes.url_helpers

      # Returns chatwork notifications settings.
      def options
        @options ||= begin
          conf_file = File.join(Rails.root, 'config', 'chatwork.yml')
          options = YAML::load(File.open(conf_file)) rescue {}

          (options[Rails.env] || {}).with_indifferent_access.freeze
        end
      end

      def truncate_words object, attribute, end_string = "..."
        # textile to html
        textile = object.send(attribute).dup.gsub(/\r\n?/, "\n")
        html = Redmine::WikiFormatting.to_html(Setting.text_formatting, textile, object: object, attribute: attribute)

        # truncate text.
        original_text = (html_to_text(html) || textile).chomp
        filtered_text = original_text.split("\n")[0...max_lines].join("\n")[0...max_words]
        filtered_text << "\n" << end_string unless original_text == filtered_text
        filtered_text
      end

      # Returns a Boolean value indicating whether it is possible to send a message
      def active?
        !! (options[:api_token] and Setting.plugin_redmine_chatwork_notifications[:room_id])
      end

      # put message to chatwork
      def put_chatwork_message message
        room_id = Setting.plugin_redmine_chatwork_notifications[:room_id]
        client = ChatworkNotifications::Chatwork.new options[:api_token]
        client.put_message room_id, message

      rescue ChatworkNotifications::ChatworkApiResponseError => e
        Rails.logger.warn do
          [
            "",
            "Chatwork message put failed! (#{e.class}) - #{e.message}",
            "api_token => #{options[:api_token]}. room_id => #{room_id}.",
            "code => #{e.code}, body => #{e.body}",
            "message => #{message}",
            "",
          ].join("\n")
        end
      rescue => e
        Rails.logger.warn do
          [
            "",
            "Chatwork message put failed! (#{e.class}) - #{e.message}",
            "api_token => #{options[:api_token]}. room_id => #{room_id}.",
            "message => #{message}",
            "",
          ].join("\n")
        end
      end

      # Returns issue url from issue object.
      def issue_url issue
        super(issue, url_options)
      end

      # Returns wikipage url from wikipage object.
      def wiki_page_url page
        project_wiki_page_url({project_id: page.project.identifier, id: page.title}.merge(url_options))
      end

      private

        def url_options
          { host: Setting.host_name, protocol: Setting.protocol }
        end

        # Returns html to parsed text.
        # when parse failed, returns nil.
        def html_to_text html
          html = html.gsub(/\n\n+/, "\n").gsub("\t", "")
          doc = Nokogiri::HTML.parse html rescue nil
          if doc
            doc.search("br").each { |n| n.replace "\n" }
            doc.text
          end
        end

        def max_lines; [0, Setting.plugin_redmine_chatwork_notifications[:issue_description_max_lines].to_i].max.nonzero? || 5; end
        def max_words; [0, Setting.plugin_redmine_chatwork_notifications[:issue_description_max_words].to_i].max.nonzero? || 100; end
    end
  end
end

