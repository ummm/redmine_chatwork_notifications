
require File.expand_path('../../test_helper', __FILE__)

class ChatworkTest < ActiveSupport::TestCase

  def setup
    valid_headers = { 'X-ChatWorkToken' => "validheadertoken" }
    invalid_headers = { 'X-ChatWorkToken' => "invalidheadertoken" }

    WebMock.stub_request(:get, 'https://api.chatwork.com/v1/rooms').with(headers: valid_headers).to_return do
      { status: 200, body: '[{"room_id":1,"name":"foo"},{"room_id":2,"name":"bar"},{"room_id":3,"name":"baz"}]', headers: {} }
    end
    WebMock.stub_request(:get, 'https://api.chatwork.com/v1/rooms').with(headers: invalid_headers).to_return do
      { status: 401, body: '{"errors":"Invalid API token"}', headers: {} }
    end

    WebMock.stub_request(:post, 'https://api.chatwork.com/v1/rooms/1/messages').with(headers: valid_headers, body: "body=Hello+World").to_return do
      { status: 200, body: '{"message_id":204215742}', headers: {} }
    end
    WebMock.stub_request(:post, 'https://api.chatwork.com/v1/rooms/2/messages').with(headers: valid_headers, body: "body=Hello+World").to_return do
      { status: 403, body: '{"errors":["You don\'t have permission to send messages in this room"]}', headers: {} }
    end
    WebMock.stub_request(:post, 'https://api.chatwork.com/v1/rooms/1/messages').with(headers: invalid_headers, body: "body=Hello+World").to_return do
      { status: 401, body: '{"errors":"Invalid API token"}', headers: {} }
    end
  end

  def test_api_token_not_specified
    cw = ChatworkNotifications::Chatwork.new nil
    assert_raise(ChatworkNotifications::ChatworkApiError) { cw.rooms }
  end

  def test_rooms
    cw = ChatworkNotifications::Chatwork.new "validheadertoken"
    res = cw.rooms
    assert_equal({1=>"foo", 2=>"bar", 3=>"baz"}, res)
  end

  def test_rooms_with_invalid_token
    cw = ChatworkNotifications::Chatwork.new "invalidheadertoken"
    assert_raise(ChatworkNotifications::ChatworkApiResponseError) { cw.rooms }
  end

  def test_put_message
    cw = ChatworkNotifications::Chatwork.new "validheadertoken"
    res = cw.put_message "1", "Hello World"
    assert_equal({"message_id" => 204215742}, res)
  end

  def test_put_message_with_invalid_room_id
    cw = ChatworkNotifications::Chatwork.new "validheadertoken"
    assert_raise(ChatworkNotifications::ChatworkApiResponseError) { cw.put_message "2", "Hello World" }
  end

  def test_put_message_with_invalid_token
    cw = ChatworkNotifications::Chatwork.new "invalidheadertoken"
    assert_raise(ChatworkNotifications::ChatworkApiResponseError) { cw.put_message "1", "Hello World" }
  end
end

