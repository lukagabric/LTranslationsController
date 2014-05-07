Pod::Spec.new do |s|
  s.name         = "LTranslationsController"
  s.version      = "1.0"
  s.platform     = :ios, '6.0'
  s.source       = { :git => 'https://github.com/lukagabric/LTranslationsController'}
  s.source_files = "LTranslationsControllerSample/Classes/LTranslationsController.*"
  s.dependency 'ASIHTTPRequest'
  s.requires_arc = true
end