# Encapuslates the parameters to use for basic HTTP authentication
#
# @see https://docs.ruby-lang.org/en/2.7.0/Net/HTTP.html#class-Net::HTTP-label-Basic+Authentication
class HTTPBasicAuth
  attr_reader :user
  attr_reader :password

  # A new instance of +HTTPBasicAuth+
  #
  # @param user [String] the username
  # @param password [String] the password
  def initialize(user:, password:)
    @user = user
    @password = password
  end
end
