class MuseumsController < ApplicationController
  def search
    # 1- pegar os inputs do user de lat e lng
    coordinates = validate_params(params[:lat], params[:lng])
    # se coordenadas forem validas, criar request
    # 6 - filtrar apenas as infos de nome do museu e postcode
    # 7 - agrupar os museus por postcode
  end

  private

  # 2- validar aos dados inseridos
  def validate_params(lat, lng)
    valid_lat = lat.present? && lat.between?(-90, 90)
    valid_lng = lng.present? && lat.between?(-180, 180)
    return { valid: true, lat: lng:, status: :ok } if valid_lat && valid_lng

    return_error_messages(lat, lng, valid_lat, valid_lng)
  end

  # 3- retornar erros caso o input esteja incorreto
  # 3.a - sem input
  # 3.b - lat e long com valores invalidos


  # 4- pegar os dados e enviar uma requisicao get para API do mapbox -> HTTP Party
  def fetch_data(lat, lng)
    request = HTTParty.get("https://api.mapbox.com/geocoding/v5/mapbox.places/museum.json?types=poi&proximity=#{lng},#{lat}&access_token=#{ENV['MAPBOX_API_KEY']}")
    puts request
  end
  # 5 - pegar a response da API mapbox e fazer um parse no JSON retornado
end
