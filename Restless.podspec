Pod::Spec.new do |spec|
	spec.name         = 'Restless'
	spec.version      = '0.1.1'
	spec.license      = { :type => 'MIT' }
	spec.homepage     = 'https://github.com/natep/Restless'
	spec.authors      = { 'Nate Petersen' => 'nate@digitalrickshaw.com', 'Aldrin Lenny' =>  'captalvins@gmail.com' }
	spec.summary      = 'A type-safe HTTP client for iOS and OS X, inspired by Retrofit.'
	spec.source       = { :git => 'https://github.com/natep/Restless.git', :tag => "#{spec.version}" }
	spec.source_files = 'Restless/Classes/*.{h,m}', 'Restless/Restless.h'
	spec.public_header_files = 'Restless/Restless.h', 'Restless/Classes/DRWebService.h', 'Restless/Classes/DRRestAdapter.h', 'Restless/Classes/DRConverterFactory.h', 'Restless/Classes/DRDictionaryConvertable.h', 'Restless/Classes/DRJsonConverterFactory.h', 'Restless/Classes/DRJsonConverter.h', 'Restless/Classes/NSURLSessionTask+DRProgressHandler.h'
	spec.preserve_paths = 'Restless/Scripts/*'
end
