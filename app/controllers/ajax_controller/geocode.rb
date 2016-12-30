# encoding: utf-8
class AjaxController
  # ajax/geocode
  module Geocode
    require_dependency "geocoder"

    # Get extents of a location using Geocoder. Renders ???.
    # name::   Location name.
    # format:: 'scientific' or not.
    def geocode
      name   = params[:name].to_s
      format = params[:format] || users_default_format
      name   = Location.reverse_name(name) if format == "scientific"
      render(inline: Geocoder.new(name).ajax_response)
    end

    private

    def users_default_format
      @user = session_user!
      @user.location_format
    end
  end
end
