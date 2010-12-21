require 'rubygems'
require 'httparty'
require 'oauth2'
require 'hashie'

Hash.send :include, Hashie::HashExtensions

class FourRuby::Base
  BASE_URL = 'https://api.foursquare.com/v2'
  
  def initialize(oauth2)
    @oauth2 = oauth2
  end
  
  def method_missing(name, params={})
    method_name = method_symbol.to_s.split(/\.|_/).join('/')

    if (method_name[-1,1]) == '='
      method = method_name[0..-2]
      result = post(api_url(method), params)
      params.replace(result[method] || result)
    else
      result = get(api_url(method_name, params))
      result[method_name] || result
    end
  end
  
  def api(method_symbol, params = {})
    Hashie::Mash.new(method_missing(method_symbol, params))
  end
  
  def api_url(method_name, options = nil)
    params = options.is_a?(Hash) ? to_query_params(options) : options
    params = nil if params and params.blank?
    url = BASE_URL + '/' + method_name.split('.').join('/')
    if access_token.nil?
      url += "?client_id=#{oauth.app_id}&client_secret=#{oauth.app_secret}"
    else
      url += "?oauth_token=#{access_token}"
    end
    url += "&#{params}" if params
    url = URI.escape(url)
    url
  end
  
  def parse_response(response)
    raise_errors(response)
    Crack::JSON.parse(response.body)
  end

  def to_query_params(options)
    options.collect { |key, value| "#{key}=#{value}" }.join('&')
  end

  def get(url)
    parse_response(@oauth2.get(url))
  end

  def post(url, body)
    parse_response(@oauth2.post(url, body))
  end

  # API method wrappers

  def checkin(params = {})
    api(:checkin=, params).checkin
  end

  def history(params = {})
    api(:history, params).checkins
  end

  def addvenue(params = {})
    api(:addvenue=, params).venue
  end

  def venue_proposeedit(params = {})
    api(:venue_proposeedit=, params)
  end

  def venue_flagclosed(params = {})
    api(:venue_flagclosed=, params)
  end

  def addtip(params = {})
    api(:addtip=, params).tip
  end

  def tip_marktodo(params = {})
    api(:tip_marktodo=, params).tip
  end

  def tip_markdone(params = {})
    api(:tip_markdone=, params).tip
  end

  def friend_requests
    api(:friend_requests).requests
  end

  def friend_approve(params = {})
    api(:friend_approve=, params).user
  end

  def friend_deny(params = {})
    api(:friend_deny=, params).user
  end

  def friend_sendrequest(params = {})
    api(:friend_sendrequest=, params).user
  end

  def findfriends_byname(params = {})
    api(:findfriends_byname, params).users
  end

  def findfriends_byphone(params = {})
    api(:findfriends_byphone, params).users
  end

  def findfriends_bytwitter(params = {})
    api(:findfriends_bytwitter, params).users
  end

  def settings_setpings(params = {})
    api(:settings_setpings=, params).settings
  end

  private

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


class FourRuby::BadRequest        < StandardError; end
class FourRuby::Unauthorized      < StandardError; end
class FourRuby::General           < StandardError; end
class FourRuby::Unavailable       < StandardError; end
class FourRuby::InternalError     < StandardError; end
class FourRuby::NotFound          < StandardError; end