class HTTPBasicAuth
  attr_reader :user
  attr_reader :password

  def initialize(user:, password:)
    @user = user
    @password = password
  end
end
