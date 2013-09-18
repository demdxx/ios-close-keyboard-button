Pod::Spec.new do |s|
  s.name            = 'ios-close-keyboard-button'
  s.author          = { "Dmitry Ponomarev" => "demdxx@gmail.com" }
  s.version         = '0.0.1'
  s.license         = 'CC BY 3.0'
  s.homepage        = 'https://github.com/demdxx/ios-close-keyboard-button'
  s.source          = {
    :git => 'https://github.com/demdxx/ios-close-keyboard-button.git',
    :tag => 'v0.0.1'
  }
  
  s.source_files    = '*.{m,h}'
  s.resources       = 'edit*.png'
  
  s.frameworks      = 'UIKit'
end