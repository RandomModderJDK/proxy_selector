#import "ProxySelectorPlugin.h"
#if __has_include(<proxy_selector/proxy_selector-Swift.h>)
#import <proxy_selector/proxy_selector-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "proxy_selector-Swift.h"
#endif

@implementation ProxySelectorPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftProxySelectorPlugin registerWithRegistrar:registrar];
}
@end
