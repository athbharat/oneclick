class PlacesController < TravelerAwareController

  # include the Leaflet helper into the controller and view
  helper LeafletHelper
  
  CACHED_ADDRESSES_SESSION_KEY = 'places_address_cache'
  MAX_POIS_FOR_SEARCH = Rails.application.config.ui_search_poi_items

  # set the @traveler variable for actions that are not supported by teh super class controller
  before_filter :get_traveler, :only => [:index, :add_place, :add_poi, :create, :destroy, :change]
  # set the @place variable before any actions are invoked
  before_filter :get_place, :only => [:show, :destroy, :edit]
  
  def index
    
    # set the basic form variables
    set_form_variables

  end

  # Called when a user has selected a place
  def add_place

    addresses = session[CACHED_ADDRESSES_SESSION_KEY]
    if addresses.nil?
      # we cant get the addresses from the session so they might have posted this address using
      # some other service.
      flash[:alert] = t(:error_updating_addresses)
      redirect_to user_places_path(@traveler)
      return
    end
    # get the index of the cached address they selected
    id = params[:ref].to_i
    address = addresses[id]
    # create the place from this address
    place = Place.new
    place.user = @traveler
    place.creator = current_user
    place.name = address[:name]
    place.raw_address = address[:street_address]
    place.address1 = address[:name]
    place.city = address[:city]
    place.state = address[:state]
    place.zip = address[:zip]
    place.lat = address[:lat]
    place.lon = address[:lon]
    place.active = true
    if place.save
      flash[:notice] = t(:place_added, :place_name => place.name)
    else
      flash[:alert] = t(:error_updating_addresses)
    end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      format.js {render "update_form_and_map"}
    end
  end

  # handles the user changing a place name from the form
  def change
    place = @traveler.places.find(params[:place][:id])
    if place
      place.name = params[:place][:name]
      if place.save
        flash[:notice] = t(:address_book_updated)
      else
        flash[:alert] = t(:error_updating_addresses)
      end
    else
      flash[:alert] = t(:error_updating_addresses)
    end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      format.js {render "update_form_and_map"}
    end
    
  end

  # not really a destroy -- just hides the place by setting active = false
  def destroy
    place = @traveler.places.find(params[:id])
    if place
      place.active = false
      if place.save
        flash[:notice] = t(:address_book_updated)
      else
        flash[:alert] = t(:error_updating_addresses)
      end
    end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      format.js {render "update_form_and_map"}
    end
  end

  # the user has entered an address and we need to validate it
  # by geocoding it. The results are returned to the view but are
  # also cached so we don't need to re-geocode if they decide to use
  # one
  def create

    @place_proxy = PlaceProxy.new(params[:place_proxy])

    # See if we got an existing address or POI
    if ! @place_proxy.place_id.blank? && ! @place_proxy.place_type_id.blank?
      # get this row from the database and add it to the table
      if @place_proxy.place_type_id == POI_TYPE
        poi = Poi.find(@place_proxy.place_id)
        if poi
          @place = Place.new
          @place.user = @traveler
          @place.creator = current_user
          @place.poi = poi
          @place.name = poi.name      
          @place.active = true
        end
      elsif @place_proxy.place_type_id == CACHED_ADDRESS_TYPE
        trip_place = @traveler.trip_places.find(@place_proxy.place_id)
        if trip_place
          @place = Place.new
          @place.user = @traveler
          @place.creator = current_user
          @place.raw_address = trip_place.raw_address
          @place.name = trip_place.raw_address 
          @place.lat = trip_place.lat
          @place.lon = trip_place.lon
          @place.active = true
        end
      end
      if @place.save
        flash[:notice] = t(:place_added, :place_name => place.name)
      else
        flash[:alert] = t(:error_updating_addresses)
      end
      # if we added to the places list we need to update the places form and the map
      @place_proxy = PlaceProxy.new
      view = "update_form_and_map"
    else
      # if we are geocoding just update the alt addresses panel
      view = "show_geocoding_results"
      # attempt to geocode this place
      geocoder = OneclickGeocoder.new
      geocoder.geocode(@place_proxy.raw_address)
      
      # cache the results in the session
      if geocoder.has_errors
        session[CACHED_ADDRESSES_SESSION_KEY] = []
        @alternative_places = []
      else
        session[CACHED_ADDRESSES_SESSION_KEY] = geocoder.results
        @alternative_places = geocoder.results
      end
    end

    # set the basic form variables
    set_form_variables

    respond_to do |format|
      format.js {render view}
    end
  end

  # Search for existing addresses or POIs based on a partial POI name
  def search
    
    Rails.logger.info "SEARCH"

    get_traveler
    
    query = params[:query]
    query_str = query + "%"
    
    counter = 0
    
    # First search for POIs
    # Need this to get correct case-insensitive search for postgresql without breaking mysql
    rel = Poi.arel_table[:name].matches(query_str)
    pois = Poi.where(rel).limit(MAX_POIS_FOR_SEARCH)
    Rails.logger.info pois.ai
    matches = []
    pois.each do |poi|
      matches << {
        "index" => counter,
        "type" => POI_TYPE,
        "name" => poi.name,
        "id" => poi.id,
        "lat" => poi.lat,
        "lon" => poi.lon,
        "address" => poi.address
      }
      counter += 1
    end
    
    # now search for existing trip ends. We manually filter these to find unique addresses
    rel = TripPlace.arel_table[:raw_address].matches(query_str)
    tps = @traveler.trip_places.where(rel).order("raw_address")
    old_addr = ""
    tps.each do |tp|
      if old_addr != tp.raw_address
        matches << {
          "index" => counter,
          "type" => CACHED_ADDRESS_TYPE,
          "name" => tp.raw_address,
          "id" => tp.id,
          "lat" => tp.lat,
          "lon" => tp.lon,
          "address" => tp.raw_address
        }
        counter += 1
        old_addr = tp.raw_address
      end      
    end
    respond_to do |format|
      format.js { render :json => matches.to_json }
    end
  end

protected

  def set_form_variables
    
    @places = @traveler.places
    if @place_proxy.nil?
      @place_proxy = PlaceProxy.new 
    end
    if @alternative_places.nil?
      @alternative_places = []
    end
    @markers = generate_map_markers(@places)
    
  end

  def get_place
    if user_signed_in?
      # limit places to those owned by the user unless an admin
      if current_user.has_role? :admin
        @place = Place.find(params[:id])
      else
        @place = @traveler.places.find(params[:id])
      end
    end
  end

  #
  # generate an array of map markers for use with the leaflet plugin
  #
  def generate_map_markers(places)
    objs = []
    places.each do |place|
      objs << get_map_marker(place)
    end
    return objs.to_json
  end

  # create an place map marker
  def get_map_marker(place)
    location = place.location
    {
      "id" => place.id,
      "lat" => location.first,
      "lng" => location.last,
      "name" => place.name,
      "iconClass" => 'greenIcon',
      "title" => place.name,
      "description" => render_to_string(:partial => "/places/place_popup", :locals => { :place => place })
    }
  end

end