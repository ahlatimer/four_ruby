require 'rubygems'
require 'hashie'
require 'httparty'
require 'oauth2'

Hash.send :include, Hashie::HashExtensions

module FourRuby
  class OAuth2
    attr_accessor :client, :id, :secret
  
    def initialize(id, secret=nil, options={})
      if secret
        @id = id
        @secret = secret
      else
        require 'yaml'
        yml = YAML::load(File.open(id))
        raise StandardError, "Foursquare config file does not exist" if yml['foursquare'].nil? 
        @id = yml['foursquare']['client_id']
        @secret = yml['foursquare']['client_secret']
      end
    end
  
    def client
      return @client if @client
      ::OAuth2::Client.new(@id, @secret, :site => 'https://graph.facebook.com')
    end

    def access_token(code, options={})
      @access_token ||= client.get_access_token(code, options)
    end
  
    def authorize_url(redirect_uri)
      client.web_server.authorize_url(
        :redirect_uri => redirect_uri,
        :scope => 'email,offline_access'
      )
    end
  
    def get(url)
      if @access_token
        @access_token.get(url)
      else
        HTTParty.get(url)
      end
    end
  
    def post(url, body)
      HTTParty.post(url, body)
    end
  end 
end