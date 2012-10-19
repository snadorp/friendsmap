class HomeController < ActionController::Base
  include ApplicationHelper
  layout "application"
  protect_from_forgery
  @@earth_radius = 6371 #km

  def index
   	session[:oauth] = Koala::Facebook::OAuth.new(APP_ID, APP_SECRET, SITE_URL + '/home/callback')
    @auth_url =  session[:oauth].url_for_oauth_code(:permissions=>"read_stream")
    
  	respond_to do |format|
      format.html { }
	end
  end

  def callback
    if params[:code]
      # acknowledge code and get access token from FB
      session[:access_token] = session[:oauth].get_access_token(params[:code])
    end
		
    @api = Koala::Facebook::API.new(session[:access_token])
	begin
      @friends = Array.new
      @me = Hash.new

      graph_friends = @api.get_object("/me/friends", "fields"=>"name,location,picture") 
      graph_me = @api.get_object("me", "fields"=>"name,location,picture")
      
      @me['name'] = graph_me['name']
      @me['picture'] = graph_me['picture']['data']['url']

      if graph_me["location"].nil?
        #default location set to Berlin
        @message = "Sorry, but we can't get your location from Facebook. You are now living in Berlin! Enjoy! :)"
        city = find_city(111175118906315) 
      else
        city_id = graph_me["location"]["id"]
        city = find_city(city_id)
      end
      
      @me['place'] = city.attributes['name']
      @me['latitude'] = city.attributes['latitude'].to_f
      @me['longitude'] = city.attributes['longitude'].to_f
      @me['distance'] = 0

      graph_friends.each do |friend|
        #get location latitude and longitude
        unless friend["location"].nil?
          city_id = friend["location"]["id"]
          city = find_city(city_id)
          unless city.nil?
            _friend = Hash.new
            _friend['name'] = friend['name']
            _friend['picture'] = friend['picture']['data']['url']
            _friend['place'] = city.attributes['name']
            _friend['latitude'] = city.attributes['latitude'].to_f
            _friend['longitude'] = city.attributes['longitude'].to_f
            _friend['distance'] = calculate_distance(_friend['latitude'], _friend['longitude'])
            @friends << _friend
          end
        end
      end
 
      #put myself into the friendlist to be displayed as well
      @friends << @me
  
    rescue Exception=>ex
      logger.error ex.message
    end
	
    respond_to do |format|
      format.html { }
    end
  end
 
  def find_city(city_id)
    city = City.find_by_id(city_id)
    if(city.nil?)
      #Put the location into the database
      puts "City does not exist."
      api_city = @api.get_object(city_id)
      puts api_city
      if api_city['location'].nil?
        #Some cities don't have locations in their API body.
        #We're trying to find a match in the DB by using the name 
        puts 'location has no coordinates! Trying fuzzy search.'
        city = City.find_by_sql("SELECT * FROM cities WHERE name LIKE '%" + api_city['name'] + "%'").first
        if city.nil?
          logger.error "Can't find city: #{api_city['name']} with ID: #{api_city['id']}"
        end
      else
        #Create the city in the database
        city = City.create!(
                            :id => api_city['id'],
                            :name => api_city['name'],
                            :latitude => api_city['location']['latitude'],
                            :longitude => api_city['location']['longitude']
                            )
      end
    end
    city
  end

  def calculate_distance(latitude, longitude)
    # code ported from: http://www.movable-type.co.uk/scripts/latlong.html
    dLat = to_radians((latitude - @me['latitude']))
    dLon = to_radians((longitude - @me['longitude']))
    lat1 = to_radians(@me['latitude'])
    lat2 = to_radians(latitude)
    
    a = Math.sin((dLat/2) * Math.sin(dLat/2) + Math.sin(dLon/2) * Math.sin(dLon/2) * Math.cos(lat1) * Math.cos(lat2))
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    result = @@earth_radius * c
    '%.0f' % result
  end
  
  def to_radians angle
    angle/180 * Math::PI
  end
end
