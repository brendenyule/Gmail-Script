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

  def get_sender_email
end

me = User.new("testmailtestertesting", "foobarbaz")
req = Request.new(me)

req.request
req.get_count
req.get_sender

