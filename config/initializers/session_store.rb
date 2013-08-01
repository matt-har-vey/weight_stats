# Be sure to restart your server when you modify this file.
WeightStats::Application.config.session_store :active_record_store, key: '_weight_stats_session',
  expire_after: 30.days
