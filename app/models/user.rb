class User < ActiveRecord::Base
  attr_accessible :weights_start, :weights_end

  def self.find_or_create_authorized(access_token)
    uj = FitBit.get_json access_token, "/1/user/-/profile.json"
    User.where(fitbit_id: uj['user']['encodedId']).first_or_create
  end

  def weights_start=(s)
    super nil_blank(s)
  end

  def weights_end=(s)
    super nil_blank(s)
  end

  private
    def nil_blank(s)
      if s.blank?
        nil
      else
        s
      end
    end
end
