class User < ActiveRecord::Base
  WeightsRefreshInterval = 20.minutes
  Fitbit.logger = logger

  attr_accessible :weights_start, :weights_end

  has_many :weights, :order => 'time'

  def self.find_or_create_authorized(access_token)
    f = Fitbit.from_access_token(access_token)
    u = User.where(fitbit_id: f.user['encodedId']).first_or_create
    u.fitbit = f
    u.save
    u
  end

  def fitbit
    @fitbit ||= Fitbit.new(access_token_value, access_token_secret)
  end

  def fitbit=(fitbit)
    @fitbit = fitbit
    self.access_token_value = fitbit.token
    self.access_token_secret = fitbit.secret
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

  def averages_in_range(options = {})
    s = options[:start] || weights_start
    e = options[:end] || weights_end
    level = options[:level] || :daily

    keyer = nil
    if level == :daily
      keyer = ->(t) { t.beginning_of_day }
    elsif level == :weekly
      keyer = ->(t) { t.beginning_of_week }
    else
      raise ArgumentError.new('unknown aggregation level')
    end

    weights = weights_in_range(s,e)

    grouped = {}

    weights.each do |weight|
      group = keyer.call(weight.time)
      grouped[group] = [] if grouped[group].nil?
      grouped[group] << weight
    end

    grouped.map do |k,v|
      n = v.size
      average = Weight.new
      average.user = self
      average.time = k.to_time
      average.weight = (v.inject(0) { |s,w| s + w.weight } / n.to_f).round(2)
      average.fat_percent = (v.inject(0) { |s,w| s + w.fat_percent } / n.to_f).round(2)
      average
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
      wj = fitbit.weights(fetch_start, fetch_end)
			if wj && wj['weight']
				wj['weight'].each do |d|
          time = time(d)
					times << time
					weights[time] = d['weight']
          log_ids[time] = d['logId']
				end
			end

      fj = fitbit.fats(fetch_start, fetch_end)
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
end
