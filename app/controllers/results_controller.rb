class ResultsController < ApplicationController
  require 'json'
  require 'elasticsearch'
  require 'multi_json'
  require 'faraday'
  require 'elasticsearch/api'
  require 'active_support'

  def index
    # params[:query]
    # params[:duration] = [
    #   0: 30sec,
    #   1: 1min,
    #   2: 1min30sec,
    #   3: 2min,
    # ]
    elasticsearch_data = call_elastic_search(params)
    parsed_data = parse_elasticsearch_data(elasticsearch_data, params)

    render :json => parsed_data, :status => 200
  end
end

def call_elastic_search(params)
  streemClient = Elasticsearch::Client.new url: 'http://localhost:9200', log: true
  elasticsearch_response = create_a_request(streemClient, params)

  return if !elasticsearch_response

  return attach_meta_info(streemClient, elasticsearch_response)
end

def create_a_request(streemClient, params)
  return streemClient.search(index: 'podcasts', body: create_query(params))
end

def create_query(params)
  return '{
    "query": {
      "nested": {
        "path": "clips",
        "query": {
          "bool": {
            "must": [
              {
                "match_phrase": {
                  "clips.transcript": "' + params[:query] + '"
                }
              }
            ]
          }
        },
        "inner_hits": {}
      }
    }
  }'
end

def attach_meta_info(streemClient, elasticsearch_clips)
  elasticsearch_clips['hits']['hits'].each do |hit|
    show_uri = hit['_source']['title'].split('/').second_to_last.split('_').last
    episode_uri = hit['_source']['title'].split('/').last.split('.').first

    elastic_metadata = streemClient.search(index: 'metadata', body: create_query_meta(show_uri, episode_uri))
    hit['meta'] = elastic_metadata['hits']['hits'].first['_source']
  end

  return elasticsearch_clips
end

def create_query_meta(show_uri, episode_uri)
  return '{
    "size": 1,
    "query": {
      "bool": {
        "must": [
          {
            "match": {
              "show_uri": "spotify:show:' + show_uri + '"
            }
          },
          {
            "match": {
              "episode_uri": "spotify:episode:' + episode_uri + '"
            }
          }
        ]
      }
    }
  }'
end

def parse_elasticsearch_data(elasticsearch_data, params)
  result = []
  matches = JSON.parse('{"matches": []}')

  elasticsearch_data['hits']['hits'].each do |hit|
    hit['inner_hits']['clips']['hits']['hits'].each do |inner_hit|
  
      if params[:duration].to_i == 0
        matches['matches'] = [inner_hit['_source']]
      else
        offset = inner_hit['_source']['offset']

        lower_limit = offset.to_i
        upper_limit = offset.to_i + params[:duration].to_i

        matches['matches'] = matches_upon_duration(hit['_source']['clips'], lower_limit, upper_limit)
      end

      merged = hit['meta'].merge(matches)
      result.push(merged)
    end
  end

  return result
end

def matches_upon_duration(clips, lower_limit, upper_limit)
  matches = []

  i = lower_limit
  while i <= upper_limit
    clip = clips.find {|u| u['offset'].to_i == i }
    matches.push(clip)
    i += 1
  end

  return matches
end

# def matches_upon_duration_both_ways(clips, lower_limit, upper_limit)
#   result = []

#   if lower_limit >= 0 && upper_limit <= clips.length
#     x = lower_limit
#     while x < upper_limit
      
#       x += 1
#     end
#     clips.find {|u| u.offset == 50 }
#   end
  
# end


#PERFECT
#This is the method call elasticSearch and return the JSON Response.
#params[:query]
#params[:before]
#params[:after]
#params[:interval]
# def call_elastic_search(params)
#   streemClient = Elasticsearch::Client.new url: 'https://elastic:streem@sample.es.streem.com.au:443', log: true
#   elasticsearch_response = create_a_request(streemClient, params)

#   return elasticsearch_response
# end

#PERFECT
# def create_a_request(streemClient, params)
#   return streemClient.search(index: 'news_201908', body: create_query(params))
# end

#PERFECT
# def create_query(params)
  # return '{
  #   "size": 0,
  #   "query": {
  #     "bool": {
  #       "must": [
  #         {
  #           "match_phrase": {
  #             "text": "' + params[:query] + '"
  #           }
  #         },
  #         {
  #           "range": {
  #             "timestamp": {
  #               "gte": ' + params[:before] + ',
  #               "lte": ' + params[:after] + '
  #             }
  #           }
  #         }
  #       ]
  #     }
  #   },
  #   "aggs":{
  #     "first_agg":{
  #       "date_histogram": {
  #         "field": "timestamp",
  #         "calendar_interval": "' + params[:interval] + '", 
  #         "order": {
  #           "_key": "asc"
  #         }
  #       },
  #       "aggs": {
  #         "second_agg": {
  #           "terms": {
  #             "field": "medium",
  #             "order": {
  #               "_key": "asc"
  #             }
  #           }
  #         }
  #       }
  #     }
  #   }
  # }
  # {
  #   "size": 0,
  #   "query": {
  #     "bool": {
  #       "must": [
  #         {
  #           "match_phrase": {
  #             "text": "Michael Jackson"
  #           }
  #         }
  #       ]
  #     }
  #   }
  # }'
# end

#PERFECT
# Obtain group by date (key), the Category & DocCount.
# return [
#  { timestamp: [{TV: 48265}, {Online: 26716}, {Radio: 95794}, ...] },
#  { timestamp: [{TV: 12239}, {Online: 49348}, {Radio: 34398}, ...] }
#  ]
# def  parse_elasticsearch_data(elasticsearch_data)
#   result ={}
#   elasticsearch_data['aggregations']['first_agg']['buckets'].each do |buckets| 
#     new_hash = { buckets['key_as_string'] => buckets['second_agg']['buckets']}
#     result.merge!(new_hash)    
#   end
#   return result   
# end