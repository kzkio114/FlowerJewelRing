require 'elasticsearch/model'

Elasticsearch::Model.client = if Rails.env.production?
  Elasticsearch::Client.new(
    url: ENV['BONSAI_URL'],
    log: true,
    transport_options: { ssl: { verify: false } }
  )
else
  Elasticsearch::Client.new(
    url: ENV['ELASTICSEARCH_URL'],
    log: true,
    transport_options: { ssl: { verify: false } }
  )
end