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

  def self.get_json(access_token, path)
    res = access_token.get(path, 'Accept-Language' => 'en_US')
    if res.is_a? Net::HTTPOK
      JSON.parse(res.body)
    elsif res.is_a? Net::HTTPUnauthorized
      raise BadToken
    else
      raise BadHTTPStatus.new(res.body)
    end
  end
end
