require "elasticsearch"
require "httpclient"

TestClient = Elasticsearch::Client.new(
  url: "http://localhost:9200"
)

StreemClient = Elasticsearch::Client.new(
  url: "https://sample.es.streem.com.au:443",
  http: {
      user: 'elastic', 
      password: 'streem'
  }
)





