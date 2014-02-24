Gem::Specification.new do |s|
  s.name        = 'gdrive_app_poster'
  s.version     = '0.0.1'
  s.date        = '2014-02-23'
  s.summary     = 'This gem posts files to google drive.'
  s.description = '' 
  s.authors     = ['Chris Kleeschulte']
  s.email       = 'rubygems@kleetus.33mail.com'
  s.files       = ['lib/drive.rb']
  s.required_ruby_version = '>= 2.0.0'
  s.homepage    = 'http://kleetus.org'
  s.executables << 'gdrive_app_poster'
  s.add_dependency('google-api-client')
end
