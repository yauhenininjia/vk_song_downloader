class CallbacksController < ApplicationController
  def vkontakte
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in @user
    redirect_to root_path
  end
end
