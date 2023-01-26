# frozen_string_literal: true

require 'net/http'
require 'json'
require 'date'
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
  current_time = DateTime.now.new_offset(Rational(0, 24))
  # NOTE: 今日を含めて直近3日の結果を検索するため2日前の0時の日時オブジェクトを作成。
  before_2_days = (current_time.to_date - 2).to_datetime
  # NOTE: RubyのDateTimeは時差の表記が「+00:00」となるが、
  # YouTube Data APIではRFC3339形式かつ「Z」表記しか受け付けないためRFC3339形式にして「Z」に置き換える。
  current_time_rfc3339 = current_time.rfc3339.chomp('+00:00') + 'Z'
  before_2_days_rfc3339 = before_2_days.rfc3339.chomp('+00:00') + 'Z'
  # NOTE: YouTube Data APIはタグでの検索はサポートしていないようなのでキーワード検索を行う。
  search_word = 'Apex+Legends'
  max_results = 10
  base_uri = 'https://www.googleapis.com/youtube/v3/search'
  api_key_query = "?key=#{ENV['YOUTUBE_API_KEY']}"
  search_query = '&type=video&order=viewCount' +
                 "&q=#{search_word}" +
                 "&publishedAfter=#{before_2_days_rfc3339}" +
                 "&publishedBefore=#{current_time_rfc3339}" +
                 "&maxResults=#{max_results}"
  uri = base_uri + api_key_query + search_query
  URI.parse(uri)
end

# NOTE: APIで動画の検索を行った結果から、動画の視聴用URLを作成
def puts_video_uris(response)
  items = response['items']
  base_uri = 'https://www.youtube.com/watch?v='
  p '人気TOP10(再生回数順)'
  items.each_with_index do |item, i|
    video_id = item['id']['videoId']
    video_uri = base_uri + video_id
    p "#{i + 1}位: #{video_uri}"
  end
end

main
