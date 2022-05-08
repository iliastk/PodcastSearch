class IndexingOfElastic
  require 'json'
  require 'elasticsearch'
  require 'multi_json'
  require 'faraday'
  require 'elasticsearch/api'
  require 'active_support'
  require 'csv'
  require 'find'

  def perform
    es = Elasticsearch::Client.new url: 'http://localhost:9200', log: true
    return if !check_connection(es)

    create_metadata_index(es) if true
    indexing_metadata_content(es) if true

    create_podcasts_index(es) if true
    indexing_podcasts_content(es) if true
  end

  private

  def check_connection(es)
    if es.ping()
      pp 'ES Connected, Up & Running'
      return true
    end
    
    pp 'ES Disconnected'
    return false
  end

  def create_metadata_index(es)
    if es.indices.exists(:index => "metadata_ruby")
      es.indices.delete(:index => 'metadata_ruby')
      pp 'Metadata Ruby Index Deleted'
    end

    body = {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0
      },
      "mappings": {
        "properties": {
          "show_uri": {"type": "text"},
          "show_name": {"type": "text"},
          "show_description": {"type": "text"},
          "publisher": {"type": "text"},
          "language": {"type": "text"},
          "rss_link": {"type": "text"},
          "episode_uri": {"type": "text"},
          "episode_name": {"type": "text"},
          "episode_description": {"type": "text"},
          "duration": {"type": "text"},
          "show_filename_prefix": {"type": "text"},
          "episode_filename_prefix": {"type": "text"},
        }
      }
    }

    if !es.indices.exists(:index => "metadata_ruby")
      es.indices.create(:index => "metadata_ruby", :body => body)
      pp 'Metadata Ruby Index Created'
    end
  end

  def indexing_metadata_content(es)
    file_name = '/Users/iliastalidi/Desktop/podcasts-no-audio-13GB/metadata.tsv'

    parsed_file = CSV.read(file_name, col_sep: "\t")
    headers = parsed_file[0]
    
    parsed_file.each_with_index do |row, index|
      next if index == 0
      body = {}
      ix = 0

      headers.each do |col|
        body[col] = row[ix]
        ix += 1
      end

      pp index
      es.index(:index => "metadata_ruby", :body => body)
    end
  end

  def create_podcasts_index(es)
    if es.indices.exists(:index => "podcasts_ruby")
      es.indices.delete(:index => 'podcasts_ruby')
      pp 'Podcasts Ruby Index Deleted'
    end

    body = {
      "settings": {
        "number_of_shards": 1,
        "number_of_replicas": 0,
        "index": {
          "mapping": {
            "nested_objects": {
              "limit": 50000
            }
          }
        },
      },
      "mappings": {
        "properties": {
          "title": {"type": "text"},
          "clips": {
            "type": "nested",
            "properties": {
              "transcript": {"type": "text"},
              "offset": {"type": "text"},
              "confidence": {"type": "double"},
              "words": {
                "type": "nested",
                "properties": {
                  "startTime": {"type": "text"},
                  "endTime": {"type": "text"},
                  "word": {"type": "keyword"}
                }
              }
            }
          },
        }
      }
    }

    if !es.indices.exists(:index => "podcasts_ruby")
      es.indices.create(:index => "podcasts_ruby", :body => body)
      pp 'Podcasts Ruby Index Created'
    end
  end

  def indexing_podcasts_content(es)
    path_name = '/Users/iliastalidi/Desktop/podcasts-no-audio-13GB/spotify-podcasts-2020/podcasts-transcripts-summarization-testset'

    Find.find(path_name) do |file_path|
      next if !file_path.end_with?(".json")

      file = File.open(file_path)
      parsed_file = JSON.load(file)
      clips = []

      parsed_file["results"].each_with_index do |data, index|
        data = data["alternatives"].first

        next if !data["transcript"].present?

        clip = {
          "transcript": data["transcript"],
          "offset": index,
          "confidence": data["confidence"], 
          "words": data["words"]
        }

        clips.append(clip)
      end

      body = {}
      body["title"] = file_path
      body["clips"] = clips

      es.index(:index => "podcasts_ruby", :body => body)
    end
  end

end

