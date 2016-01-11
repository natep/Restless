//
//  DRJsonConverter.h
//  Restless
//
//  Created by Nate Petersen on 9/8/15.
//  Copyright © 2015 Digital Rickshaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRConverterFactory.h"

@interface DRJsonConverter : NSObject <DRConverter>

- (id)convertJSONObject:(id)jsonObject toObjectOfClass:(Class)cls error:(NSError**)error;

@end
