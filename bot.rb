#coding: utf-8

require "twitter"


CONSUMER_KEY          = "your consumer key"
CONSUMER_SECRET       = "your consumer secret"
ACCESS_TOKEN          = "your access token"
ACCESS_TOKEN_SECRET   = "your access token secret"

# フォローしてる人がすべて入ってるリスト（5000人超えると使えなくなるので注意）
LIST_ID = 1028961406517829632


$client = Twitter::REST::Client.new do |config|
  config.consumer_key = CONSUMER_KEY
  config.consumer_secret = CONSUMER_SECRET
  config.access_token = ACCESS_TOKEN
  config.access_token_secret = ACCESS_TOKEN_SECRET
end
$my_screen_name = $client.user.screen_name

def thon_if_required(tweet)
  # DMとかは除外
  return unless tweet.is_a?(Twitter::Tweet)
  # RTは除外
  return unless tweet.retweeted_status.nil?
  # 無限ループになるので自分のツイートには何もしない
  return if tweet.user.screen_name == $my_screen_name

  if tweet.text.include?("てょーん")
    $client.favorite(tweet)
    status = "@#{tweet.user.screen_name} ٩( ๑╹ ꇴ╹)۶てょーん"
    $client.update(status, in_reply_to_status: tweet)
  end
end

last_id = nil
loop do
  sleep(1)

  if last_id.nil?
    last_id = $client.list_timeline(LIST_ID, count: 1, include_rts: false).first.id
    next
  end
  list_tweets = $client.list_timeline(LIST_ID, count: 200, include_rts: false, since_id: last_id)
  next if list_tweets.empty?

  list_tweets.each do |tw|
    thon_if_required(tw)
  end
  last_id = list_tweets.map(&:id).max
end
