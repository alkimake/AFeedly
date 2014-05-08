Pod::Spec.new do |s|
  s.name         = "AFeedly"
  s.version      = "0.0.1"
  s.summary      = "Feedly API Client"
  s.description  = <<-DESC
                   A client connecting to Feedly API for authenticating and fetching all feeds, tags and etc.
                   DESC
  s.homepage     = "https://github.com/alkimake/AFeedly"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "Alkim Gozen" => "alkimake@gmail.com" }
  s.platform     = :ios, '6.0'
  s.source       = { :git => "https://github.com/alkimake/AFeedly.git", :tag => s.version.to_s }
  s.source_files  = 'Source/**/*.{h,m}'
  s.exclude_files = 'Classes/Exclude'
  s.requires_arc = true
  
  s.dependency 'AFNetworking', '~> 1.0'
  s.dependency 'LROAuth2Client', '~> 0.0'
  s.dependency 'JSONModel', '~> 0.13'

end
