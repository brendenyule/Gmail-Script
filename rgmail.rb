require 'open-uri'
require 'rexml/document'

class Email
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
    url = BASE_URL+category

    response = open(url, http_basic_authentication: [@user.username,
                                                     @user.password])
    @response = REXML::Document.new response
  end

  def method_missing (method, *args, &block)
    # TODO validate and return wrong methods
    self.class.send(:define_method, method) do
      path = method.to_s.sub("get_", '').sub("email", "entry").gsub('_', '/')
      test = []
      @response.elements.each("feed/"+path) { |e| test << e.get_text() }
      return test
    end
    self.send(method, *args, &block)
  end
end

users = []
format = []
ARGV.each do |arg|
  arg.include?('#') ? users.push( Email.new(*arg.split('#'))) : format.push(arg)
end

abbrevs = {"c" => "get_fullcount",
           "a" => "get_email_author_name",
           "e" => "get_email_author_email",
           "s" => "get_email_summary"}

users.each do |account|
  request = Request.new(account)
  request.request

  format.each do |element|
    puts request.send(abbrevs[element])
  end
end

