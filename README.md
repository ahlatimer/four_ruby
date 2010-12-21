# FourRuby

FourRuby is a super-simple Ruby API wrapper for Foursquare. 

FourRuby supports method chaining, so you can do things like f.venues.search(:ll => '123,123'), and it'll issue the call to '/v2/venues/search?ll=123,123'.

# Caveats

FourRuby doesn't support any calls that require post or an Oauth token. That severely diminishes its usefulness, I know, but I haven't had the time to add that in yet.

# License

FourRuby is released under the MIT license.