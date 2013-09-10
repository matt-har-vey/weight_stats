require 'csv'
require 'stat_functions'

class WeightsController < ApplicationController
  before_filter :find_user

  def index
    @aggregation_level = params[:aggregate] && params[:aggregate].to_sym
    View.async_create(@user, session[:user_id], @aggregation_level)

    @user.update_weights_if_stale!
    @last_update = @user.weights_updated_at

    stale_time = @user.updated_at > @last_update ? @user.updated_at : @last_update
    if stale?(last_modified: stale_time)

      @weights = @aggregation_level ?
                   @user.averages_in_range(level: @aggregation_level)
                 : @user.weights_in_range

      @series = series(@weights)

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
          render :json => @series
        end
      end
    end
  end

  def force_update
    @user.update_weights!
    redirect_to user_weights_url(@user)
  end

  def destroy
    @weight = Weight.find(params[:id])
    @weight.fitbit_destroy
    user = @weight.user
    user.weights_updated_at = Time.now
    user.save!
    redirect_to user_weights_url(user)
  end

  private
    def find_user
      @user = User.find(params[:user_id])
    end

    def series(weights)
      series = {}
      time_fun = lambda { |w| w.time.to_i }

      [:fat_percent, :weight, :fat_mass, :lean_mass ].each do |attr|
        fit_unscaled = StatFunctions.map_and_fit(weights, time_fun, lambda { |w| w.send(attr) })

        # Scaling by 1000 (seconds to milliseconds) for highcarts dates
        series[attr] =
          { :data => weights.select { |w| !w.send(attr).nil? }.map { |w| [ w.time.to_i * 1000, w.send(attr) ] },
            :fit => { :coeff => [ fit_unscaled[:coeff][0], fit_unscaled[:coeff][1] / 1000],
                      :endpoints => fit_unscaled[:endpoints].map { |p| [ 1000 * p[0], p[1]] },
                      :rmse => fit_unscaled[:rmse] },
            :per_day => fit_unscaled[:coeff][1] * 3600 * 24 }
      end

      series
    end
end
