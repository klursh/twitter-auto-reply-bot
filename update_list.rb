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


# https://developer.twitter.com/en/docs/basics/rate-limits.html
# 900回/15分、max 件数5000
list_members = $client.list_members(LIST_ID, count: 5000, skip_status: true, include_entities: false).to_h[:users]
listing_ids = list_members.map {|m| m[:id]}

# 15回/15分、max 件数5000
# 自分へのリプライが届くように自分もリストに入れる
following_ids = $client.friend_ids(count: 5000).to_h[:ids] + [$client.user.id]

# リミット明記なし、15回/15分かな
# 1回100ユーザーまで行けるので気にせずやってしまう
(following_ids - listing_ids).each_slice(100) do |add_ids|
  $client.add_list_members(LIST_ID, add_ids)
end
(listing_ids - following_ids).each_slice(100) do |remove_ids|
  $client.remove_list_members(LIST_ID, remove_ids)
end
