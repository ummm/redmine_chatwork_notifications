
require 'cgi'
require 'json'

module ChatworkNotifications
  # Chatwork client.
  #
  # token = "...."
  # client = ChatworkNotifications::Chatwork.new token
  #
  # client.rooms
  #  => {1 => "foo", 2 => "bar", 3 => "baz"}
  #
  # client.put_message 1, "Hello World!"      # => put message to chatwork
  #
  class Chatwork

    def initialize token
      @token = token
    end

    # Returns hash of {room_id => room_name}
    def rooms
      @rooms ||= begin
        Hash[get(entry_points[:rooms].call).map { |r| [ r['room_id'].freeze, r['name'].freeze ] }].freeze
      end
    end

    # Put message to chatwork.
    def put_message room_id, message
      post_with_urlencoded entry_points[:message].call(room_id), body: message
    end

    private

      def default_headers
        { 'X-ChatWorkToken' => @token }
      end

      def connection
        https = Net::HTTP.new('api.chatwork.com', 443)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        https.verify_depth = 5
        if block_given?
          https.start { yield(https) }
        else
          https
        end
      end

      def request
        connection do |https|
          raise ChatworkNotifications::ChatworkApiError, "Chatwork API token is not specified!" if @token.blank?
          response = yield(https)
          JSON.parse(response.body).tap do |json|
            raise ChatworkNotifications::ChatworkApiResponseError.new(json["errors"].try(:first), response.code, response.body) unless response.code == "200"
          end
        end
      end

      def get path, headers = {}
        request do |https|
          https.get path, default_headers.merge(headers)
        end
      end

      def post path, body, headers = {}
        request do |https|
          https.post path, body, default_headers.merge(headers)
        end
      end

      def post_with_urlencoded path, values, headers = {}
        body = values.map { |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join("&")
        post path, body, headers
      end

      def entry_points
        @entry_points ||= {
          rooms: -> { '/v1/rooms' },
          message: -> room_id { "/v1/rooms/#{room_id}/messages" },
        }
      end
  end
end

