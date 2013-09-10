class View < ActiveRecord::Base
  belongs_to :user
  belongs_to :viewer, class_name: 'User', foreign_key: 'viewer_id'

  def self.async_create(user, viewer_id, aggregation)
    logger.debug 'in async create'
    Thread.new do
      logger.debug 'in new thread'
      begin
        v = View.new
        v.viewer_id = viewer_id
        v.user = user
        v.viewed_at = Time.now
        v.aggregation = aggregation
        v.save!
      rescue
        logger.error $!
      ensure
        ActiveRecord::Base.connection.close
      end
    end
  end
end
