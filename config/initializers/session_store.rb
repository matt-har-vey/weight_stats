# Be sure to restart your server when you modify this file.
WeightStats::Application.config.session_store :cookie_store, key: '_weight_stats_session',
  http_only: false, expire_after: 10.years
