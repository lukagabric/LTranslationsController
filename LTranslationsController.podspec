Pod::Spec.new do |s|
  s.name         = "LTranslationsController"
  s.version      = "1.0"
  s.platform     = :ios, '6.0'
  s.author       = 'Luka Gabric'
  s.source       = { :git => 'git://github.com/lukagabric/LTranslationsController' }
  s.source_files = "LTranslationsControllerSample/Classes/LTranslationsController/*.{h,m}"
  s.dependency 'ASIHTTPRequest'
  s.requires_arc = true
end
