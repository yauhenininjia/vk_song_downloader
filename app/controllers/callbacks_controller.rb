class CallbacksController < ApplicationController
  def vkontakte
    #binding.pry
    @user = User.from_omniauth(request.env["omniauth.auth"])
    sign_in_and_redirect @user
  end
end
