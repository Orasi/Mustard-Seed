Apipie.configure do |config|
  config.app_name                = "Mustard"
  config.app_info                = 'API documentation for the Mustard Results Server'
  config.validate                = false
  config.api_base_url            = ""
  config.doc_base_url            = "/docs"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  # config.use_cache = Rails.env.production?
end
