Searchkick.client = Elasticsearch::Client.new(
  url: ENV['BONSAI_URL'],
  log: true,
  transport_options: { ssl: { verify: false } }
)
