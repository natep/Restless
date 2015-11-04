//
//  DRTypeEncoding.h
//  Restless
//
//  Created by Nate Petersen on 9/4/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DRObjectTypeEncodingClass,
	DRIntegerNumberTypeEncodingClass,
	DRFloatingNumberTypeEncodingClass,
	DROtherTypeEncodingClass
} DRTypeEncodingClass;

@interface DRTypeEncoding : NSObject

- (instancetype)initWithTypeEncoding:(const char*)encoding;

- (DRTypeEncodingClass)encodingClass;

- (NSString*)formatSpecifier;

@end
