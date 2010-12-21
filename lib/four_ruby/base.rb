require 'rubygems'
require 'httparty'
require 'oauth2'
require 'hashie'

Hash.send :include, Hashie::HashExtensions

module FourRuby
  class Base
    BASE_URL = 'https://api.foursquare.com/v2'
    ENDPOINTS = [:users, :venues, :tips, :settings, :multi]
    
    def initialize(oauth2)
      @oauth2 = oauth2
      @query = Hashie::Clash.new
      @endpoint = nil
      @result = nil
    end
    
    def method_missing(method_name, params={})
      if ENDPOINTS.include?(method_name)
        @endpoint = method_name
        @query.send(@endpoint, params)
      elsif @endpoint
        if @query[@endpoint][method_name]
          @query[@endpoint].merge!( {method_name => params.merge(@query[@endpoint][method_name])})
        else
          @query[@endpoint].merge!({ method_name => params })
        end
      else
        raise BadRequest, 'You must specify an endpoint.'
      end
      @result = nil
      
      self
    end
  
    def to_url
      return BASE_URL if @endpoint.nil?
      url = "#{BASE_URL}/#{@endpoint.to_s}#{@query[@endpoint][:id].nil? ? "" : "/" + @query[@endpoint][:id].to_s}"
      @query[@endpoint].each do |k,v|
        next if k == :id
        url += "/#{k}?"
        url += stringify_keys(v)
      end
      # TODO: allow access via an oauth_token
      url += url[-1..url.length] == "?" ? "" : "&"
      url += "client_id=#{@oauth2.id}&client_secret=#{@oauth2.secret}"
      url = URI.escape(url)
      url
    end

    def [](i)
      self.to_json[i]
    end
    
    def to_json
      return {} if @query.blank?
      @result ||= send
    end
    
    def send
      parse_response(@oauth2.get(self.to_url))
    end

    def parse_response(response)
      raise_errors(response)
      Crack::JSON.parse(response.body)
    end

    private
    
    def stringify_keys(h)
      result = ""
      return unless h.is_a? Hash
      h.each do |k,v|
        result += "#{k}=#{v}&"
      end
      result.chomp("&")
    end

    def raise_errors(response)
      message = "(#{response.code}): #{response.message} - #{response.inspect} - #{response.body}"

      case response.code.to_i
        when 400
          raise BadRequest, message
        when 401
          raise Unauthorized, message
        when 403
          raise General, message
        when 404
          raise NotFound, message
        when 500
          raise InternalError, "Foursquare had an internal error. Please let them know in the group.\n#{message}"
        when 502..503
          raise Unavailable, message
      end
    end
  end


  class BadRequest        < StandardError; end
  class Unauthorized      < StandardError; end
  class General           < StandardError; end
  class Unavailable       < StandardError; end
  class InternalError     < StandardError; end
  class NotFound          < StandardError; end
end