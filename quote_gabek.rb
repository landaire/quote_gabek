require 'rubygems'
require 'active_support/all' # Too lazy to actually do date subtraction and stuff
require 'twitter'
require File.join(File.dirname(__FILE__), 'credentials.rb')

# Create and add the "credentials.rb" file in the same directory as this script, containing:

# @client = Twitter::REST::Client.new do |config|
#   config.consumer_key = "CONSUMER_KEY"
#   config.consumer_secret = "CONSUMER_SECRET"
#   config.access_token = "ACCESS_TOKEN"
#   config.access_token_secret = "ACCESS_TOKEN_SECRET"
# end

trailing_words = ["So trill", "Trill", "True", "Real talk", "If only he loved bots", "Oh",
                  "#realtalk", "#lovehim", "#trill", "Sexy", "#random",
                  "#myboo", "#sosexy", "SENDING OUT AN SOS", "So that's what sank the Titanic?", "Whores these days...",
                  "#foreverandever", "I wonder if he's a local single in my area..."
]

while true do
  # If the last tweet was within an hour, sleep for an hour
  if @client.user_timeline("QuotesGabek", :count => 1).first.created_at > (Time.now - 1.hour)
    sleep 60 * 60
  end

  # Randomize the trailing words
  trailing_words.shuffle!

  # This file holds the last tweet we tweeted. Since tweeting duplicates isn't cool, let's just store the
  # last tweet ID
  last_tweet = if !File.exists?("last_tweet_id.txt") || File.size("last_tweet_id.txt") == 0 then
                 285040048573927428
               else
                 File.open("last_tweet_id.txt", "r") { |f| f.read.to_i }
               end

  # Fetch gabe_k's timeline
  tweets = @client.user_timeline("gabe_k", :count => 30, :include_rts => false)

  tweet_text = nil
  # Randomize the tweets so that we aren't always picking the most recent tweet
  tweets.shuffle!
  tweets.each do |tweet|
    if tweet.id > last_tweet && tweet.text.length <= 115
      # 115 for the "As @gabe_k once said, "." part"
      # If there's a trailing period, remove it. We're adding one, so yeah
      tweet_text = "As @gabe_k once said, \"#{tweet.text.gsub(/.$/, "")}.\""
      max_string = 140 - tweet_text.length
      trailing_words.each do |word|
        # If a trailing word will fit at the end of the tweet, add one
        if word.length + 1 <= max_string
          tweet_text = "#{tweet_text} #{word}#{if word[-1] != "." && word.length + 2 <= max_string then "." end }"
          break
        end
      end
      client.update(tweet_text)
      puts "#{Time.now} Tweeted: #{tweet_text}"
      File.open("last_tweet_id.txt", "w") { |f| f.truncate(0); f.print tweet.id }
      break
    end
  end

  sleep 3 * 60 * 60
end
