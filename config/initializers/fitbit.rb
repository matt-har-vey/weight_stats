module FitBit
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

  def self.access_token(token, secret)
    OAuth::AccessToken.new(CONSUMER, token, secret)
  end

  def self.get_json(access_token, path)
    request :get, access_token, path
  end

  def self.delete_json(access_token, path)
    begin
      request :delete, access_token, path
    rescue NotFound
      nil
    end
  end

  def self.request(method, access_token, path)
    res = access_token.request(method, path, 'Accept-Language' => 'en_US')
    if res.is_a? Net::HTTPOK
      JSON.parse(res.body)
    elsif res.is_a? Net::HTTPNoContent
      nil
    elsif res.is_a? Net::HTTPNotFound
      raise NotFound
    elsif res.is_a? Net::HTTPUnauthorized
      raise BadToken
    else
      raise BadHTTPStatus.new(res.body)
    end
  end
end
