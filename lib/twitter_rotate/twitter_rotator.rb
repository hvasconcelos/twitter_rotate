require "rubygems"
require "twitter"
require "colorize"
require "oauth"
require "yaml"

module TwitterRotate
  class TwitterRotator

    attr_writer :tweet_func
    
    AUTH_FILE=File.join(ENV["HOME"],".tweet_rotator")

    SEARCH_HASH_TAG = -> (client,options) {
      search = "\#"+options[:hashtag]+" -rt"
      puts "Hashtag "+search+"...."
      client.search( search, :options => options[:count] ).results
    }
    
    HOME_TIME_LINE = -> (client,options) {
      #puts "Getting Home Timeline ..."
      client.home_timeline :count => options[:tweet_count]
    }

    def initialize( opts = {} )
      authorize unless File.exists? AUTH_FILE  
      @auth = YAML.load(File.open(AUTH_FILE)) 
      @options = { 
        :refresh_rate => 300 , 
        :rotate_time => 10 ,
        :tweet_count => 30 ,
        :tweet_func => HOME_TIME_LINE
      }.merge(opts)
      @client = Twitter::Client.new(
       :consumer_key => @auth["consumer_key"] ,
       :consumer_secret => @auth["consumer_secret"]  ,
       :oauth_token => @auth["token"]  , 
       :oauth_token_secret => @auth["token_secret"]  )
      @tweets = []
      @ci = -1
    end

    def run() 
      @sl = Thread.new do
        get_tweets() 
      end
      @rt = Thread.new do 
        rotate
      end
    end


    def get_tweets()
      while 1
        @tweets.clear
        @tweets = @options[:tweet_func].call(@client,@options)        
        sleep(@options[:refresh_rate])
      end
    end

    def authorize
      auth={} 
      puts "First, go register a new application at "
      puts "https://dev.twitter.com/apps/new"
      puts "Enter the consumer key you are assigned:"  
      auth["consumer_key"] = gets.strip
      puts "Enter the consumer secret you are assigned:"  
      auth["consumer_secret"] = gets.strip
      puts "Your application is now set up, but you need to register"  
      puts "this instance of it with your user account."
      consumer=OAuth::Consumer.new auth["consumer_key"], auth["consumer_secret"], {:site=>"https://api.twitter.com"}  
      request_token = consumer.get_request_token
      puts "Visit the following URL, log in if you need to, and authorize the app"
      puts request_token.authorize_url
      puts "When you've authorized that token, enter the verifier code you are assigned:"
      verifier = gets.strip   
      puts "Converting request token into access token..."  
      access_token=request_token.get_access_token(:oauth_verifier => verifier)   
      auth["token"] = access_token.token
      auth["token_secret"] = access_token.secret
      File.open(AUTH_FILE, 'w') {|f| YAML.dump(auth, f)}
      puts "Done. Have a look at #{AUTH_FILE} to see what's there."
    end

    def stop
      @sl.exit
      @rt.exit
    end

    def next_tweet
      if @tweets.count > 0
         @ci = (@ci < (@tweets.count-1))? @ci+1 : 0
         return @tweets[@ci]
      end
      return nil
    end

    def rotate
      puts "Starting wait for tweet stream..."
      while 1
        tweet = next_tweet
        if tweet!=nil
          puts "  "+tweet[:user][:name].colorize(:yellow)
          puts "  "+tweet[:text].gsub(/[\s\t\r\n\f]/, ' ')+"\n"*2
        end 
        sleep( @options[:rotate_time] )
      end
    end
  end
end
