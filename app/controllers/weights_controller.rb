require 'csv'
require 'stat_functions'

class WeightsController < ApplicationController
  RefreshInterval = 20.minutes

  def index
    if session[:weights] && session[:weights_time] && session[:weights_time] > RefreshInterval.ago
      @weights = session[:weights]
    elsif authorized?
      @weights = Weight.all(session[:access_token])
      session[:weights] = @weights
      session[:weights_time] = Time.now
    else
      return authorize weights_url
    end

    @last_update = session[:weights_time]
    expires_in RefreshInterval - (Time.now - @last_update)

    if stale?(last_modified: @last_update)
      @series = {}
      time_fun = lambda { |w| w.time.to_i }
      [:fat_percent, :weight, :fat_mass, :lean_mass ].each do |attr|
        fit_unscaled = StatFunctions.map_and_fit(@weights, time_fun, lambda { |w| w.send(attr) })

        # Scaling by 1000 (seconds to milliseconds) for highcarts dates
        @series[attr] =
          { :data => @weights.select { |w| !w.send(attr).nil? }.map { |w| [ w.time.to_i * 1000, w.send(attr) ] },
            :fit => { :coeff => [ fit_unscaled[:coeff][0], fit_unscaled[:coeff][1] / 1000],
                      :endpoints => fit_unscaled[:endpoints].map { |p| [ 1000 * p[0], p[1]] },
                      :rmse => fit_unscaled[:rmse] },
            :per_day => fit_unscaled[:coeff][1] * 3600 * 24 }
      end

      respond_to do |format|
        format.html do
          render
        end
        format.csv do
          csv_string = CSV.generate do |csv|
            csv << [ 'time', 'weight', 'fat_percent', 'lean_mass', 'fat_mass' ]
            @weights.each do |weight|
              csv << [weight.time.strftime('%Y-%m-%d %H:%M:%S'), weight.weight, weight.fat_percent, weight.lean_mass, weight.fat_mass]
            end
          end

          send_data csv_string, :type => 'text/csv; charset=utf-8; header=present',
            :disposition => 'attachment; filename=weights.csv'
        end
        format.json do
          render  :json => @series
        end
      end
    end
  end

  def clear_cache
    session[:weights] = nil
    session[:weights_time] = nil
    redirect_to weights_url
  end
end
