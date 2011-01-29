# FourRuby

FourRuby is a super-simple Ruby API wrapper for Foursquare. 

# Examples

    # You can pass in a path to OAuth2 to a YAML file, or you can pass in the id/secret directly.
    @four = FourRuby::Base.new(FourRuby::OAuth2.new('config/foursquare_keys.yml'))
    @four.venues.search(:ll => '31.794872,-106.290592') # find 4sq locations near my hometown
    @four.to_json # => run the above query, and return the json response as a hash
    # Add query=coffeee to the query
    @four.venues.search(:query => 'coffee')
    @four.to_json
    # You can also treat the FourRuby::Base object like a hash directly, without calling to_json
    @four["response"] 

# Caveats

FourRuby doesn't support any calls that require post or an OAuth2 token. That severely diminishes its usefulness, I know, but I haven't had the time to add that in yet.

# License

FourRuby is released under the MIT license.