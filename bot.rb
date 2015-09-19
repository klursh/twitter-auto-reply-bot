#coding: utf-8

require "twitter"

CONSUMER_KEY          = "your consumer key"
CONSUMER_SECRET       = "your consumer secret"
ACCESS_TOKEN          = "your access token"
ACCESS_TOKEN_SECRET   = "your access token secret"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end

stream = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = CONSUMER_KEY
  config.consumer_secret     = CONSUMER_SECRET
  config.access_token        = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end

my_screen_name = client.user.screen_name
stream.user do |tweet|
  # DMとか入ってくるので
  next unless tweet.is_a?(Twitter::Tweet)
  # 無限ループになるので自分のツイートには何もしない
  next if tweet.user.screen_name == my_screen_name

  if tweet.text.include?("てょーん")
    client.favorite(tweet)
    status = "@#{tweet.user.screen_name} ٩( ๑╹ ꇴ╹)۶てょーん"
    client.update(status, in_reply_to_status: tweet)
  end
end

