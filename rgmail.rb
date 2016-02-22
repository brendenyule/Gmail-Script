require 'open-uri'
require 'rexml/document'
#require 'net/http'
#require 'json'

# TODO class Account
class User
  def initialize(username, password)
    @username = username
    @password = password
  end

  attr_accessor :username
  attr_accessor :password
end

class Request
  BASE_URL = 'https://mail.google.com/mail/feed/atom/'
  def initialize(user)
    @user = user
  end

  def request(category = "%5Esmartlabel_personal")
    # Gmail tabs follow this naming convention: %5Esmartlabel_social
    # ^smartlabel_promo, ^smartlabel_notification, ^smartlabel_group
    # example url: https://username:pass@mail.google.com/mail/feed/atom
    url = BASE_URL+category

    response = open(url, http_basic_authentication: [@user.username,
                                                     @user.password])
    @response = REXML::Document.new response
  end

  def get_count
    @response.elements.each("feed/fullcount") { |e| puts e.get_text() }
  end

  def get_sender_name
    @response.elements.each("feed/entry/author/name") { |e| puts e.get_text() }
  end

  def get_author_email
  end

  def method_missing (method, *args, &block)
    # TODO validate and return wrong methods
    self.class.send(:define_method, method) do
      strng = method.to_s
      path = strng.sub("get_", '').sub("email", "entry").gsub('_', '/')
      @response.elements.each("feed/"+path) { |e| return e.get_text() }
    end
    self.send(method, *args, &block)
  end
end

me = User.new("testmailtestertesting", "foobarbaz")
req = Request.new(me)

req.request
#req.get_count
#req.get_sender
#req.get_email_author_name
#req.get_fullcount
#req.get_count
#puts req.get_email_author_email
puts req.get_email_summary

