class MuseumsController < ApplicationController
  def search
    # 1- pegar os inputs do user de lat e lng
    coordinates = validate_params(params[:lat], params[:lng])
    # se coordenadas forem validas, criar request
    if coordinates[:valid]
      @museums = build_museum_response(coordinates[:lat], coordinates[:lng])
      render json: @museums.to_json, status: coordinates[:status]
    else
      render json: { errors: coordinates[:errors] }, status: coordinates[:status]
    end
  end

  private

    # 2- validar aos dados inseridos
    def validate_params(lat, lng)
      valid_lat = lat.present? && lat.to_f.between?(-90, 90)
      valid_lng = lng.present? && lat.to_f.between?(-180, 180)
      return { valid: true, lat: lat, lng: lng, status: :ok } if valid_lat && valid_lng

      return_error_messages(lat, lng, valid_lat, valid_lng)
    end

    def return_error_messages(lat, lng, valid_lat, valid_lng)
      errors = []
      # 3.a - sem input
      if lat.nil? || lng.nil?
        status = :bad_request
        errors << 'Please provide a lat and long'
      else
        status = :unprocessable_entity
        errors << 'Lat must be between -90 and 90' unless valid_lat
        errors << 'Long must be between -180 and 180' unless valid_lng
      end
      { valid: false, errors: errors, status: status}
    end
    # 3- retornar erros caso o input esteja incorreto
    # 3.b - lat e long com valores invalidos


    def fetch_data(lat, lng)
      # 4- pegar os dados e enviar uma requisicao get para API do mapbox usando HTTP Party
      request = HTTParty.get("https://api.mapbox.com/geocoding/v5/mapbox.places/museum.json?types=poi&proximity=#{lng},#{lat}&access_token=#{ENV['MAPBOX_API_KEY']}")
      # 5 - pegar a response da API mapbox e fazer um parse do JSON retornado
      JSON.parse(request.parsed_response)
    end

    # 6- Filtrando o response e agrupando os nomes dos museus por postcode:
    def parse_data(data)
      data['features'].each_with_object({}) do |museum, hsh|
        hsh[museum['context'][0]['text']] = [] unless hsh[museum['context'][0]['text']]
        hsh[museum['context'][0]['text']] << hsh[museum]['text']
      end
    end

    def build_museum_response(lat, lng)
      museum_data = fetch_data(lat, lng)
      parse_data(museum_data)
    end
end
