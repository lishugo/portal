require 'feed-normalizer'

class PortalController < ApplicationController
  layout 'site', :except => ['everything_feed']
  
  # main page of the site
  # are there better ways of doing this? probably. do many ways work? no.
  # be very afraid of messing with the data returned by FeedNormalizer
  # and render_to_string of the RSS rxml doesn't work either
  def index
    feed_descriptions = [
          { :type => "flickr", :text => "Flickr image:", :url => "http://simonwoodside.com:8080/feed-temp/flickr.xml" },
          { :type => "semacode", :text => "Semacode blog:", :url => "http://simonwoodside.com:8080/feed-temp/semacode.xml" },
          { :type => "simonwoodside", :text => "Simon Says:", :url => "http://simonwoodside.com:8080/feed-temp/swc.xml" }
          # Add any other feeds that you want here
          # TODO: change this to scan the public/feed-temp directory and open any file that is there
        ]
    @all = aggregate_feeds feed_descriptions
  end
  
  def everything_feed
    list # compiles the complete list into @all which is an array
    # use @all[0]['obj'] to get the 1st FeedNormalizer entry etc.
    render :template => 'feeds/everything'
  end

private
  # Fails quietly
  # Returns an array of hashes, each hash is { :type, :text, :obj }
  # Where type, text are strings, and obj is a FeedNormalizer object
  # You might have the read the code to understand FeedNormalizer, sorry.
  def aggregate_feeds( feed_descriptions )
    result = feed_descriptions.map do |desc|
      get_feed( desc[:type], desc[:text], desc[:url] )
    end
    result = result.flatten
    result = result.sort_by { |x| x[:obj].date_published }.reverse
  end
  def get_feed( type, text, url )
    feed = FeedNormalizer::FeedNormalizer.parse open( url )
    if feed.nil?
      logger.warn "**** Got a nil when using FeedNormalizer.parse open( #{url} )" 
      return []
    end
    feed.entries.map do |story|
      { :type => type, :text => text, :obj => story }
    end
  end
  
end






