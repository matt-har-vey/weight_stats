class User < ActiveRecord::Base
  WeightsRefreshInterval = 20.minutes

  attr_accessible :weights_start, :weights_end

  has_many :weights, :order => 'time'

  def self.find_or_create_authorized(access_token)
    u = User.where(fitbit_id: User.user_json(access_token)['encodedId']).first_or_create
    u.access_token = access_token
    u.save
    u
  end

  def access_token
    @access_token ||= FitBit.access_token(access_token_value, access_token_secret)
  end

  def access_token=(at)
    @access_token = at
    self.access_token_value = at.token
    self.access_token_secret = at.secret
  end

  def weights_start=(s)
    super nil_blank(s)
  end

  def weights_end=(s)
    super nil_blank(s)
  end

  def weights_in_range(s = weights_start, e = weights_end)
    if s && e
      weights.where("time >= ? and time <= ?", s.to_time, e.to_time)
    elsif s
      weights.where("time >= ?", s.to_time)
    elsif e
      weights.where("time <= ?", e.to_time)
    else
      weights
    end
  end

  def update_weights_if_stale!
    if !weights_updated_at || weights_updated_at < WeightsRefreshInterval.ago
      update_weights!
      true
    else
      false
    end
  end

  def update_weights!
    w = weights.last

    start_date = w ? w.time.to_date : long_ago

    new_weights = fitbit_weights(start_date: start_date)
    if weights_updated_at
      new_weights.reject! do |w|
        w.time <= weights_updated_at
      end
    end

    weights << new_weights

    self.weights_updated_at = Time.now
    save
  end

  def fitbit_user_json
    User.user_json access_token
  end

  def fitbit_devices_json
    FitBit.get_json(access_token, '/1/user/-/devices.json')
  end

  def fitbit_weights(options = {})
    fitbit_weights = []

    start_date = options[:start_date] || long_ago
    end_date = options[:end_date] || 2.days.from_now.to_date

		fetch_start = start_date
		fetch_end = start_date.next_month

		times = []
		weights = {}
		fats = {}
    log_ids = {}

		loop do
      wj = FitBit.get_json access_token, "/1/user/-/body/log/weight/date/#{fetch_start}/#{fetch_end}.json"
			if wj && wj['weight']
				wj['weight'].each do |d|
          time = time(d)
					times << time
					weights[time] = d['weight']
          log_ids[time] = d['logId']
				end
			end

      fj = FitBit.get_json access_token, "/1/user/-/body/log/fat/date/#{fetch_start}/#{fetch_end}.json"
			if fj && fj['fat']
				fj['fat'].each do |d|
					fats[time(d)] = d['fat']
				end
			end

			fetch_start = fetch_end
			break if fetch_start > end_date
			fetch_end = fetch_end.next_month
		end

		times.uniq!
    times.sort!

		times.each do |s|
      w = Weight.new
      w.user = self
      w.time = s
      w.weight = weights[s]
      w.fat_percent = fats[s]
      w.log_id = log_ids[s]

      if w.weight && w.fat_percent
        fitbit_weights << w
      end
		end

    fitbit_weights
  end

  private
    def nil_blank(s)
      if s.blank?
        nil
      else
        s
      end
    end

    def long_ago
      3.months.ago.to_date
    end

		def time(d)
			Time.parse "#{d['date']} #{d['time']}"
		end

    def self.user_json(access_token)
      FitBit.get_json(access_token, "/1/user/-/profile.json")['user']
    end
end
