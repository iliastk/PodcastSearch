class IndexingOfElastic
  require 'json'
  require 'elasticsearch'
  require 'multi_json'
  require 'faraday'
  require 'elasticsearch/api'
  require 'active_support'

  def connect_elasticsearch
    es = Elasticsearch::Client.new url: 'http://localhost:9200', log: true
    if es.ping()
        puts 'Yay Connect'
    else
        puts 'Awww it could not connect!'
    end

    return es
  end


end