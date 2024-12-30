//
//  PropertyViewer.m
//  PropertyView
//
//  Created by Mac-Mini on 2024/12/27.
//

#import "PropertyViewer.h"
#import <objc/runtime.h>

@interface PropertyViewer ()

@property (nonatomic, strong) NSString *text;

@end

@implementation PropertyViewer

- (void)setViewerObject:(NSString *)objectName {
    //    self.classInfo = [self.classInfo ];
    Class cls = NSClassFromString(objectName);
    if (cls == nil) {
        self.text = [NSString stringWithFormat:@"class %@ 不存在",objectName];
        return;
    }
    self.text = @"变量：\n";
    NSArray *ivarList = [self getIvarList:cls];
    for (NSString* name in ivarList) {
        self.text = [self.text stringByAppendingFormat:@"%@\n",name];
    }
    self.text = [self.text stringByAppendingString:@"\n属性：\n"];
    NSArray *propertyList = [self getPropertyList:cls];
    for (NSString* name in propertyList) {
        self.text = [self.text stringByAppendingFormat:@"%@\n",name];
    }
    self.text = [self.text stringByAppendingString:@"\n委托协议：\n"];
    NSArray *protocolList = [self getProtocolList:cls];
    for (NSString* name in protocolList) {
        self.text = [self.text stringByAppendingFormat:@"%@\n",name];
    }
    self.text = [self.text stringByAppendingString:@"\n类方法：\n"];
    NSArray *methodList = [self getClassMethodList:cls];
    for (NSString* name in methodList) {
        self.text = [self.text stringByAppendingFormat:@"%@\n",name];
    }
    self.text = [self.text stringByAppendingString:@"\n实例方法：\n"];
    NSArray *instanceMethodList = [self getInstanceMethodList:cls];
    for (NSString* name in instanceMethodList) {
        self.text = [self.text stringByAppendingFormat:@"%@\n",name];
    }
}

- (NSString *)infoString {
    return self.text;
}

//获取类的成员变量
- (NSMutableArray *)getIvarList:(Class)cls {
    unsigned int count;
    Ivar *ivarList = class_copyIvarList(cls, &count);
    NSMutableArray *result = [NSMutableArray array];
    for (int i =0; i < count; i++) {
        const char *name =ivar_getName(ivarList[i]);
        const char *type = ivar_getTypeEncoding(ivarList[i]);
        NSString *nameStr = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        NSString *typeStr = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        typeStr = [typeStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        typeStr = [typeStr stringByReplacingOccurrencesOfString:@"@" withString:@""];
        NSString *fullName = [NSString stringWithFormat:@"-(%@)%@",typeStr, nameStr];
        [result addObject:fullName];
    }
    free(ivarList);
    return result;
}

//获取类的属性
- (NSMutableArray *)getPropertyList:(Class)cls {
    //属性个数
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(cls, &count);
    NSMutableArray *result = [NSMutableArray array];
    for (int i =0; i < count; i++) {
        objc_property_t property = properties[i];
        const char *name =property_getName(property);
        const char *nameAttri =property_getAttributes(property);
        NSString *nameAttrStr = [NSString stringWithCString:nameAttri encoding:NSUTF8StringEncoding];
        NSString *nameStr = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        [result addObject:[NSString stringWithFormat:@"-(%@) %@",nameAttrStr, nameStr]];
    }
    free(properties);
    return result;
}

//获取一个类的协议方法列表
- (NSMutableArray *)getProtocolList:(Class)cls {
    unsigned int count;
    __unsafe_unretained Protocol **protocals = class_copyProtocolList(cls, &count);
    NSMutableArray *result = [NSMutableArray array];
    for (int i =0; i < count; i++) {
        const char *protocolName = protocol_getName(protocals[i]);
        NSString *proName = [NSString stringWithCString:protocolName encoding:NSUTF8StringEncoding];
        // 获取实例方法列表
        unsigned int instanceMethodCount = 0;
        struct objc_method_description *instanceMethods = protocol_copyMethodDescriptionList(protocals[i], YES, YES, &instanceMethodCount);
        if (instanceMethods) {
            proName = [proName stringByAppendingString:@"\nInstance Methods:\n"];
            for (unsigned int j = 0; j < instanceMethodCount; j++) {
                proName = [proName stringByAppendingFormat:@"%s\n",sel_getName(instanceMethods[i].name)];
            }
            free(instanceMethods); // 释放内存
        }
        
        // 获取类方法列表
        unsigned int classMethodCount = 0;
        struct objc_method_description *classMethods = protocol_copyMethodDescriptionList(protocals[i], YES, NO, &classMethodCount);
        if (classMethods) {
            proName = [proName stringByAppendingString:@"\nClass Methods:\n"];
            for (unsigned int j = 0; j < classMethodCount; j++) {
                proName = [proName stringByAppendingFormat:@"%s\n",sel_getName(classMethods[i].name)];
            }
            free(classMethods); // 释放内存
        }
        
        [result addObject:proName];
    }
    free(protocals);
    return result;
}

//获取一个类的类方法列表
- (NSMutableArray *)getClassMethodList:(Class)cls {
    unsigned int count;
    Method *methods =class_copyMethodList(object_getClass(cls), &count);
    NSMutableArray *result = [NSMutableArray array];
    for (int i =0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        char *returnType = method_copyReturnType(methods[i]);
        NSString *returnTypeStr = [NSString stringWithCString:returnType encoding:NSUTF8StringEncoding];
        returnTypeStr = [returnTypeStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        returnTypeStr = [returnTypeStr stringByReplacingOccurrencesOfString:@"@" withString:@""];
        NSString *fullName = [NSString stringWithFormat:@"-(%@)%@",returnTypeStr, NSStringFromSelector(name)];
        
        [result addObject:fullName];
    }
    free(methods);
    return result;
}

//获取一个类的实例方法列表
- (NSMutableArray *)getInstanceMethodList:(Class)cls {
    unsigned int count;
    Method *methods = class_copyMethodList(cls, &count);
    NSMutableArray *result = [NSMutableArray array];
    for (int i =0; i < count; i++) {
        SEL name = method_getName(methods[i]);
        char *returnType = method_copyReturnType(methods[i]);
        NSString *returnTypeStr = [NSString stringWithCString:returnType encoding:NSUTF8StringEncoding];
        returnTypeStr = [returnTypeStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        returnTypeStr = [returnTypeStr stringByReplacingOccurrencesOfString:@"@" withString:@""];
        NSString *fullName = [NSString stringWithFormat:@"-(%@)%@",returnTypeStr, NSStringFromSelector(name)];
        [result addObject:fullName];
    }
    free(methods);
    return result;
}

@end
