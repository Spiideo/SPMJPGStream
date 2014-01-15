
Pod::Spec.new do |s|
  s.name         = "SPMJPGStream"
  s.version      = "0.0.1"
  s.summary      = "Fetch a MJPG stream from an Axis camera. For iOS and OS X."
  s.description  = <<-DESC
                   SPMJPEG makes it easy to stream an MJPEG stream from any Axis camera.
                   Supports Basic Auth and a few parameters like fps and resolution.
                   DESC
  s.homepage     = "https://github.com/Spiideo/SPMJPGStream"
  s.license      = 'MIT (example)'
  # s.license      = { :type => 'MIT', :file => 'FILE_LICENSE' }
  s.author       = { "Gustaf Lindqvist" => "gustaf@spiideo.com" }
  s.ios.deployment_target = '6.0'
  s.osx.deployment_target = '10.8'
  s.source       = { :git => "https://github.com/Spiideo/SPMJPGStream.git", :commit => "9cee75b9a4f506b20f5798c36aa4e58204ff9792" }
  s.source_files  = 'Classes/*.{h,m}'
  # s.exclude_files = 'Classes/Exclude'
  s.public_header_files = 'Classes/*.h'
  s.requires_arc = true
  s.dependency 'ReactiveCocoa'
  s.dependency 'libextobjc/EXTScope'
end
