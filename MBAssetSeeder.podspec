#
# Be sure to run `pod lib lint NAME.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = "MBAssestSeeder"
  s.version          = "0.1.0"
  s.summary          = "A short description of MBAssestSeeder."
  s.description      = <<-DESC
                       An optional longer description of MBAssestSeeder

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.license          = 'MIT'
  s.author           = { "Matt Baker" => "matthew.baker@lookout.com" }
  s.source           = { :git => "https://github.com/mrbaker4/MBAssetSeeder", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/baker'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'MBAssestSeeder/*'
  s.resources = 'Assets/*.png'
  
  s.dependency 'RHAddressBook', '1.1.1'
  s.dependency 'MBFaker', '0.1.2'
  
end