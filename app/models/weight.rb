class Weight
  attr_reader :time, :weight, :fat_percent, :lean_mass, :fat_mass

  def initialize(time, weight, fat_percent)
    @time = time
    @weight = weight
    @fat_percent = fat_percent
    if fat_percent
      @fat_mass = (weight * fat_percent).round / 100.0
      @lean_mass = ((weight - @fat_mass) * 100.0).round / 100.0
    end
  end

  def self.all(options)
    all_weights = []

    access_token = options[:access_token]
    start_date = options[:start_date] || 3.months.ago.to_date
    end_date = options[:end_date] || 2.days.from_now.to_date

		fetch_start = start_date
		fetch_end = start_date.next_month

		times = []
		weights = {}
		fats = {}

		loop do
      wj = FitBit.get_json access_token, "/1/user/-/body/log/weight/date/#{fetch_start}/#{fetch_end}.json"
			if wj && wj['weight']
				wj['weight'].each do |d|
					times << time(d)
					weights[time(d)] = d['weight']
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
      w = Weight.new(s, weights[s], fats[s])
      if w.weight && w.fat_percent
        all_weights << w
      end
		end

    all_weights
  end

	private
		def self.time(d)
			Time.parse "#{d['date']} #{d['time']}"
		end
end
