//
//  DRDictionaryConvertable.h
//  WebServiceProtocol
//
//  Created by Nate Petersen on 9/8/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#ifndef DRDictionaryConvertable_h
#define DRDictionaryConvertable_h

@protocol DRDictionaryConvertable <NSObject>

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

- (NSDictionary*)toDictionary;

@end


#endif /* DRDictionaryConvertable_h */
