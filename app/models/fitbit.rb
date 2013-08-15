class Fitbit
	CONSUMER_KEY = '517875fb6c0947c6adec3b854f821bb8'
	CONSUMER_SECRET = 'e49344c9558741d8baf085f3592f65de'
  SITE = 'https://api.fitbit.com'

  CONSUMER = OAuth::Consumer.new(CONSUMER_KEY, CONSUMER_SECRET,
                                 :site => SITE)

  class BadToken < Exception
  end

  class BadHTTPStatus < Exception
  end

  class NotFound < Exception
  end

  def self.from_access_token(access_token)
    Fitbit.new(access_token.token, access_token.secret)
  end

  @@logger = nil

  def self.logger=(l)
    @@logger = l
  end

  def initialize(token, secret)
    @access_token = OAuth::AccessToken.new(CONSUMER, token, secret)
  end

  def token
    @access_token.token
  end

  def secret
    @access_token.secret
  end

  def user
    get("/1/user/-/profile.json")['user']
  end

  def devices
    get '/1/user/-/devices.json'
  end

  def weights(start_date, end_date)
    get "/1/user/-/body/log/weight/date/#{start_date}/#{end_date}.json"
  end

  def fats(start_date, end_date)
    get "/1/user/-/body/log/fat/date/#{start_date}/#{end_date}.json"
  end

  def delete_weight(log_id)
    delete "/1/user/-/body/log/weight/#{log_id}.json"
    delete "/1/user/-/body/log/fat/#{log_id}.json"
  end

  private
    def get(path)
      request :get, path
    end

    def delete(path)
      begin
        request :delete, path
      rescue NotFound
        nil
      end
    end

    def request(method, path)
      res = @access_token.request(method, path, 'Accept-Language' => 'en_US')
      code = res.code
      body = res.body
      if @@logger
        @@logger.debug "FitBit HTTP status #{code}"
        @@logger.debug body
      end
      if res.is_a? Net::HTTPOK
        JSON.parse(body)
      elsif res.is_a? Net::HTTPNoContent
        nil
      elsif res.is_a? Net::HTTPNotFound
        raise NotFound
      elsif res.is_a? Net::HTTPUnauthorized
        raise BadToken
      else
        raise BadHTTPStatus.new("#{code}\n#{body}")
      end
    end
end
