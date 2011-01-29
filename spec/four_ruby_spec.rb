require 'spec_helper'

describe FourRuby do
  before(:each) do
    @four = FourRuby::Base.new(FourRuby::OAuth2.new('config/foursquare_keys.yml'))
  end
  
  describe 'url generation' do
    def oauth2_url_pattern
      "client_id=\\w*&client_secret=\\w*"
    end
  
    it 'should have a base url of https://api.foursquare.com/v2' do
      FourRuby::Base::BASE_URL.should == "https://api.foursquare.com/v2"
    end
  
    describe 'to_url' do
      it 'should return the BASE_URL when first created' do
        @four.to_url.should == FourRuby::Base::BASE_URL
      end
    
      it 'should raise an error when passed an invalid endpoint' do
        begin
          @four.bogus_endpoint
        rescue FourRuby::BadRequest
          0.should == 0
        else
          0.should == 1
        end
      end
      
      # This spec is more or less useless, since this isn't a valid query against the 4s api
      it 'should add an endpoint to the url' do
        @four.venues
        @four.to_url.should match /#{FourRuby::Base::BASE_URL}\/venues\?#{oauth2_url_pattern}/
      end
      
      it 'should add an id to an endpoint' do
        @four.venues(:id => '123')
        @four.to_url.should match /#{FourRuby::Base::BASE_URL}\/venues\/123\?#{oauth2_url_pattern}/
      end
      
      it 'should add an action to an endpoint' do
        @four.venues.search
        @four.to_url.should match /#{FourRuby::Base::BASE_URL}\/venues\/search\?#{oauth2_url_pattern}/
      end
      
      it 'should add parameters' do
        @four.venues.search(:ll => '123,123')
        @four.to_url.should match /#{FourRuby::Base::BASE_URL}\/venues\/search\?ll=123,123\&#{oauth2_url_pattern}/
      end
      
      it 'should allow multiple parameters' do
        @four.venues.search(:ll => '123,123', :query => 'donuts')
        @four.to_url.should match /#{FourRuby::Base::BASE_URL}\/venues\/search\?ll=123,123\&query=donuts\&#{oauth2_url_pattern}/
      end
      
      it 'should allow multiple parameters through multiple calls' do
        @four.venues.search(:ll => '123,123').search(:query => 'donuts')
        @four.to_url.should match /#{FourRuby::Base::BASE_URL}\/venues\/search\?ll=123,123\&query=donuts\&#{oauth2_url_pattern}/
      end
    end
  end
  
  describe 'getting from the API' do
    before(:each) do
      @four = FourRuby::Base.new(FourRuby::OAuth2.new('config/foursquare_keys.yml'))
      @four.venues.search(:ll => '31.794872,-106.290592', :query => 'coffee')
    end
    
    after(:each) do
      @four.clear
      @four = nil
    end
    
    it 'should query the api when to_json is called' do
      @four.to_json.should_not == {}
    end
    
    it 'should query the api when [] is called' do
      @four["response"].should_not == nil
    end
  end
  
  describe 'posting to the API' do  
    describe 'oauth2 integration' do
      it 'should integrate with oauth2'

      describe OAuth2 do
        it 'should allow client_id and client_secret to be passed directly' do
          o = FourRuby::OAuth2.new('ID', 'SECRET')
          o.id.should == 'ID'
          o.secret.should == 'SECRET'
        end

        it 'should get client_id and client_secret from a yaml file, if passed' do
          o = FourRuby::OAuth2.new('config/foursquare_keys.yml')
          o.id.should_not be_nil
          o.secret.should_not be_nil
        end
      end
    end
  end
end