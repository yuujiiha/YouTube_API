# frozen_string_literal: true

require 'net/http'
require 'json'
require 'dotenv'
Dotenv.load

def main
  response = send_request
  puts_video_uris(response)
end

# NOTE: YouTube Data APIにリクエストを送信。
def send_request
  uri = make_request_uri
  response = Net::HTTP.get_response(uri)
  JSON.parse(response.body)
end

# NOTE: YouTube Data APIへのリクエスト送信用URIを作成
def make_request_uri
  search_word = 'SHOWROOM'
  # NOTE: 問題では100件取得するとあるが、公式のドキュメントでは最大50件との記載があり、実際に返ってくる結果は50件。
  max_results = 100
  base_uri = 'https://www.googleapis.com/youtube/v3/search'
  api_key_query = "?key=#{ENV['YOUTUBE_API_KEY']}"
  search_query = "&q=#{search_word}&type=video&order=date&maxResults=#{max_results}"
  uri = base_uri + api_key_query + search_query
  URI.parse(uri)
end

# NOTE: APIで動画の検索を行った結果から、動画の視聴用URLを作成
def puts_video_uris(response)
  items = response['items']
  base_uri = 'https://www.youtube.com/watch?v='
  items.each do |item|
    video_id = item['id']['videoId']
    video_uri = base_uri + video_id
    p video_uri
  end
end

main
