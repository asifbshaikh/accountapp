SimpleCaptcha.setup do |sc|
  #sc.image_magick_path = '/usr/bin/convert' # you can check this from console by running: which convert
  #The below path is for MacOS
  sc.image_magick_path = '/usr/local/bin/' # you can check this from console by running: which convert
  #the below path is for Ubuntu
  #sc.image_magick_path = '/usr/bin/' # you can check this from console by running: which convert
end
