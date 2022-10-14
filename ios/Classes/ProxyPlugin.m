#import "ProxyPlugin.h"
#if __has_include(<proxy/proxy-Swift.h>)
#import <proxy/proxy-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "proxy-Swift.h"
#endif

@implementation ProxyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftProxyPlugin registerWithRegistrar:registrar];
}
@end
