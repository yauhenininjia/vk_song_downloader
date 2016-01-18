VkontakteApi.configure do |config|
  config.app_id       = '123'      # ID приложения
  config.app_secret   = 'AbCdE654' # защищенный ключ
  config.redirect_uri = 'http://vkontakte-on-rails.herokuapp.com/callback'
end