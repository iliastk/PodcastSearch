class ResultsController < ApplicationController
  require 'json'
  require 'elasticsearch'
  require 'multi_json'
  require 'faraday'
  require 'elasticsearch/api'
  require 'active_support'

  def index
    #puts params
    elasticsearch_data = call_elastic_search(params)
    parsed_data = parse_elasticsearch_data(elasticsearch_data)

    render :json => parsed_data, :status => 200
  end
end

#PERFECT
#This is the method call elasticSearch and return the JSON Response.
#params[:query]
#params[:before]
#params[:after]
#params[:interval]
def call_elastic_search(params)
  streemClient = Elasticsearch::Client.new url: 'https://elastic:streem@sample.es.streem.com.au:443', log: true
  elasticsearch_response = create_a_request(streemClient, params)

  #return elasticsearch_response = '{ "aggregations": { "first_agg": { "buckets": [ { "doc_count": 106177, "key": 1551358800000, "key_as_string": "2019-03-01T00:00:00.000+11:00", "second_agg": { "buckets": [ { "doc_count": 35572, "key": "TV" }, { "doc_count": 30859, "key": "Online" }, { "doc_count": 29773, "key": "Radio" }, { "doc_count": 9941, "key": "Social" }, { "doc_count": 31, "key": "Print" }, { "doc_count": 1, "key": "Magazine" } ] } }, { "doc_count": 119013, "key": 1551445200000, "key_as_string": "2019-03-02T00:00:00.000+11:00", "second_agg": { "buckets": [ { "doc_count": 48265, "key": "TV" }, { "doc_count": 26716, "key": "Online" }, { "doc_count": 19858, "key": "Social" }, { "doc_count": 17877, "key": "Radio" }, { "doc_count": 6297, "key": "Print" } ] } } ] } } }'
  #return elasticsearch_response = '{"aggregations":{"first_agg":{"buckets":[{"doc_count":106177,"key":1551358800000,"key_as_string":"2019-03-01T00:00:00.000+11:00","second_agg":{"buckets":[{"doc_count":35572,"key":"TV"},{"doc_count":30859,"key":"Online"},{"doc_count":29773,"key":"Radio"},{"doc_count":9941,"key":"Social"},{"doc_count":31,"key":"Print"},{"doc_count":1,"key":"Magazine"}]}},{"doc_count":119013,"key":1551445200000,"key_as_string":"2019-03-02T00:00:00.000+11:00","second_agg":{"buckets":[{"doc_count":48265,"key":"TV"},{"doc_count":26716,"key":"Online"},{"doc_count":19858,"key":"Social"},{"doc_count":17877,"key":"Radio"},{"doc_count":6297,"key":"Print"}]}},{"doc_count":119013,"key":1551445200000,"key_as_string":"2019-03-03T00:00:00.000+11:00","second_agg":{"buckets":[{"doc_count":58265,"key":"TV"},{"doc_count":6467,"key":"Online"},{"doc_count":50028,"key":"Social"},{"doc_count":1877,"key":"Radio"},{"doc_count":297,"key":"Print"}]}},{"doc_count":119013,"key":1551445200000,"key_as_string":"2019-03-04T00:00:00.000+11:00","second_agg":{"buckets":[{"doc_count":8265,"key":"TV"},{"doc_count":46716,"key":"Online"},{"doc_count":19458,"key":"Social"},{"doc_count":7877,"key":"Radio"},{"doc_count":1297,"key":"Print"}]}},{"doc_count":119013,"key":1551445200000,"key_as_string":"2019-03-05T00:00:00.000+11:00","second_agg":{"buckets":[{"doc_count":20265,"key":"TV"},{"doc_count":30946,"key":"Online"},{"doc_count":10858,"key":"Social"},{"doc_count":3877,"key":"Radio"},{"doc_count":437,"key":"Print"}]}},{"doc_count":119013,"key":1551445200000,"key_as_string":"2019-03-06T00:00:00.000+11:00","second_agg":{"buckets":[{"doc_count":38265,"key":"TV"},{"doc_count":50716,"key":"Online"},{"doc_count":2858,"key":"Social"},{"doc_count":877,"key":"Radio"},{"doc_count":297,"key":"Print"}]}}]}}}'
  return elasticsearch_response
end


#PERFECT
def create_a_request(streemClient, params)
  return streemClient.search(index: 'news_201908', body: create_query(params))
end

#PERFECT
def create_query(params)
  return '{
    "size": 0,
    "query": {
      "bool": {
        "must": [
          {
            "match_phrase": {
              "text": "' + params[:query] + '"
            }
          },
          {
            "range": {
              "timestamp": {
                "gte": ' + params[:before] + ',
                "lte": ' + params[:after] + '
              }
            }
          }
        ]
      }
    }, 
    "aggs":{
      "first_agg":{
        "date_histogram": {
          "field": "timestamp",
          "calendar_interval": "' + params[:interval] + '", 
          "order": {
            "_key": "asc"
          }
        },
        "aggs": {
          "second_agg": {
            "terms": {
              "field": "medium",
              "order": {
                "_key": "asc"
              }
            }
          }
        }
      }
    }
  }'
end

#PERFECT
# Obtain group by date (key), the Category & DocCount.
# return [
#  { timestamp: [{TV: 48265}, {Online: 26716}, {Radio: 95794}, ...] },
#  { timestamp: [{TV: 12239}, {Online: 49348}, {Radio: 34398}, ...] }
#  ]
def  parse_elasticsearch_data(elasticsearch_data)
  result ={}
  elasticsearch_data['aggregations']['first_agg']['buckets'].each do |buckets| 
    new_hash = { buckets['key_as_string'] => buckets['second_agg']['buckets']}
    result.merge!(new_hash)    
  end
  return result   
end