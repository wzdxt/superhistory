class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  def new
    if session_id = cookies[:dist_session_id]
      if dist_session = DistSession.find_by(:session_id => session_id)
        data = JSON.parse dist_session.data, :symbolize_names => true
        if user = User.find_by_id(data[:user_id])
          return auth_sign_in(user)
        end
      end
    end
    redirect_to dist_sign_in_path
  end

  def auth_sign_in(resource)
    sign_in(resource_name, resource)
    yield resource if block_given?
    redirect_to after_sign_in_path_for(resource)
  end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  def destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    redirect_to dist_sign_out_path
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.for(:sign_in) << :attribute
  # end

  def dist_sign_in_path
    "#{Settings.hosts.auth.url}/users/sign_in/?return_to=#{request.url}"
  end

  def dist_sign_out_path
    # "#{Settings.hosts.auth.url}/users/sign_out/?return_to=#{Settings.hosts.web.url}"
    "#{Settings.hosts.auth.url}/users/sign_out/?return_to=#{root_url}"
  end
end
