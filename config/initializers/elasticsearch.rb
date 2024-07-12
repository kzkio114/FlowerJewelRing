# config/initializers/elasticsearch.rb
require 'elasticsearch/model'

if Rails.env.production?
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: ENV['BONSAI_URL'], log: true)
else
  Elasticsearch::Model.client = Elasticsearch::Client.new(url: 'http://localhost:9200', log: true)
end
