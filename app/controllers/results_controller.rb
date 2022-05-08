class ResultsController < ApplicationController
  require 'json'
  require 'elasticsearch'
  require 'multi_json'
  require 'faraday'
  require 'elasticsearch/api'
  require 'active_support'

  # params[:query]
    # params[:duration] = [
    #   0: 30sec,
    #   1: 1min,
    #   2: 1min30sec,
    #   3: 2min,
    # ]
    # params[:search] = [
    #   match_phrase,
    #   must_contain,
    #   fuzzy_search,
    # ]

  def index
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
  if params[:search] == 'match_phrase'
    return streemClient.search(index: 'podcasts_test', body: create_query_match_phrase(params))
  elsif params[:search] == 'must_contain'
    return streemClient.search(index: 'podcasts_test', body: create_query_must_contain(params))
  elsif params[:search] == 'fuzzy_search'
    return streemClient.search(index: 'podcasts_test', body: create_query_fuzzy(params))
  end
end

def create_query_match_phrase(params)
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

def create_query_fuzzy(params)
  return '{
    "query": {
      "nested": {
        "path": "clips",
        "query": {
          "bool": {
            "should": [
              {
                "match": {
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

def create_query_must_contain(params)
  return '{
    "query": {
      "nested": {
        "path": "clips",
        "query": {
          "bool": {
            "must": [
              '+ must_include_query(params[:query]) +'
            ]
          }
        },
        "inner_hits": {}
      }
    }
  }'
end

#QUERY => cornavirus spread pandemic
#OUTPUT => 
# {"term":{"clips.transcript": "coronavirus" } }, i=0
# {"term":{"clips.transcript": "pandemic" } }, i=1
# {"term":{"clips.transcript": "spread" } } i=2

def must_include_query(query)
  terms = query.split(" ")
  result = ''

  terms.each_with_index do |term, index|
    if index == (terms.length - 1)
      result.concat('{"term":{"clips.transcript": "' + term + '" } }')
    else
      result.concat('{"term":{"clips.transcript": "' + term + '" } },')
    end
  end

  result
end

def attach_meta_info(streemClient, elasticsearch_clips)
  elasticsearch_clips['hits']['hits'].each do |hit|
    show_uri = hit['_source']['title'].split('/').second_to_last
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
              "show_filename_prefix": "' + show_uri + '"
            }
          },
          {
            "match": {
              "episode_filename_prefix": "' + episode_uri + '"
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

