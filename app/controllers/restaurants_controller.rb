class RestaurantsController < ApplicationController
  def search
    # pegar os inputs
    coordinates = validate_params(params[:lat], params[:lng])

    if coordinates[:valid]
      @restaurants = build_api__response(coordinates[:lat], coordinates[:lng])
      render json: @restaurants.to_json, status: coordinates[:status]
    end
  end

  # validar os inputs
  def validate_params(lat, lng)
    valid_lat = lat.present? && lat.to_f.between?(-90,90)
    valid_lng = lng.present? && lng.to_f.between?(-180,180)
    return { valid: true, lat: lat, lng: lng, status: :ok } if valid_lat && valid_lng
  end
    # fazer o fetch na api do mapbox
  def fetch_data(lat, lng)
    url = "https://api.mapbox.com/geocoding/v5/mapbox.places/restaurant.json?type=poi&proximity=#{lng},#{lat}&access_token=#{ENV['MAPBOX_API_KEY']}"
    request = HTTParty.get(url)
    # parse na response e filtrar o que quero exibir
    JSON.parse(request.parsed_response)
  end

  # filtrando o response e agrupando os nomes do restaurantes por postcode:
  def parse_data(data)
    data['features'].each_with_object({}) do |restaurant, hash|
      hash[restaurant]['context'][1]['text'] = [] unless hash[restaurant]['context'][1]['text']
      hash[restaurant]['context'][1]['text'] << hash[restaurant]['place_name']
    end
  end
  # construir o response
  def build_api__response(lat, lng)
    restaurant_data = fetch_data(lat, lng)
    parse_data(restaurant_data)
  end
end
