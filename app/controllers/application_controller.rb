class ApplicationController < ActionController::Base
  rescue_from ActionController::ParameterMissing do |e|
    redirect_back fallback_location: root_path, alert: "Missing required parameter: #{e.param}"
  end
end
