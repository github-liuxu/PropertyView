//
//  PropertyViewer.h
//  PropertyView
//
//  Created by Mac-Mini on 2024/12/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PropertyViewer : NSObject

- (void)setViewerObject:(NSString *)objectName;

- (NSString *)infoString;

@end

NS_ASSUME_NONNULL_END
