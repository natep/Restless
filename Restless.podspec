Pod::Spec.new do |spec|
	spec.name         = 'Restless'
	spec.version      = '0.0.1'
	spec.license      = { :type => 'BSD' }
	spec.homepage     = 'https://github.com/natep/Restless'
	spec.authors      = { 'Nate Petersen' => 'nate@digitalrickshaw.com' }
	spec.summary      = 'A type-safe HTTP client for Objective-C, inspired by Retrofit.'
	spec.source       = { :git => 'https://github.com/natep/Restless', :tag => "#{spec.version}" }
	spec.source_files = 'Restless/Classes/*.{h,m}', 'Restless/Restless.h'
	spec.public_header_files = 'Restless/Restless.h', 'Restless/Classes/DRWebService.h', 'Restless/Classes/DRRestAdapter.h'
	spec.framework    = 'SystemConfiguration'
	spec.preserve_paths = 'Restless/Scripts/*'
end