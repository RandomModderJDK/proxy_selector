import Flutter
import UIKit

/**
 Wrapper of QCFNetworkCopySystemProxySettings and QCFNetworkCopyProxiesForURL to retrieve proxy settings for a specific URL.
 For PAC URL/Script it will evaluate it and adds the returned proxy settings.
 Return a jso list of all retrieved proxies.
 */
public class SwiftProxySelectorPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "proxy_selector", binaryMessenger: registrar.messenger())
        let instance = SwiftProxySelectorPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getSystemProxyForUri" {
            guard let args = call.arguments else {
                return
            }
            if let myArgs = args as? [String: Any],
               let urlAsString = myArgs["uri"] as? String,
               let url = URL(string:urlAsString){
                let service = ProxieService(url: url);
                service.applyProxiesToURL();
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try! encoder.encode(service.proxies)
                if let ret = String(data: data, encoding: .utf8){
                    result(ret)
                }
                
            }
            
        }
    }
}

/**
 Simple Proxy model which extends from Codable to allow easy json ser/des
 Maps kCFProxyTypeKey to FTP, HTTP, HTTPS, SOCKS or NONE.
 */
public struct Proxy: Codable{
    
    var host: String?;
    var port: String?;
    var user: String?;
    var password: String?;
    var type: String;
    
    init(host:String?,port:String?,user:String?,password:String?,type:String){
        self.host = host;
        self.port = port;
        self.user = user;
        self.password = password;
        
        if(type == kCFProxyTypeFTP as String){
            self.type = "FTP"
        }else if(type == kCFProxyTypeHTTP as String){
            self.type = "HTTP"
        }else if(type == kCFProxyTypeHTTPS as String){
            self.type = "HTTPS"
        }else if(type == kCFProxyTypeSOCKS as String){
            self.type = "SOCKS"
        }else if(type == kCFProxyTypeAutoConfigurationJavaScript as String){
            self.type = "NONE"
        }else if(type == kCFProxyTypeAutoConfigurationURL as String){
            self.type = "NONE"
        }else if(type == kCFProxyTypeNone as String){
            self.type = "NONE"
        }else {
            self.type = "NONE"
        }
    }
    
}

/**
 Retrives for given URL proxies.
 After calling applyProiesToURL you can get proxies over the property proxies. Which is an array<Proxy>
 */
public class ProxieService {
    
    var proxies = [Proxy]();
    var url: URL;
    
    init(url:URL){
        self.url = url;
    }
    
    
    func applyProxiesToURL(){
        // get system proxy settings
        if let systemProxySettings = QCFNetworkCopySystemProxySettings(){
            // get proxy settings for this url
            let proxiesForURL = QCFNetworkCopyProxiesForURL(url,systemProxySettings);
            // iterate over all proxies for this url and evaluate the Proxy
            for proxy in proxiesForURL {
                if let type = proxy[kCFProxyTypeKey as String] as? String {
                    if(type == kCFProxyTypeFTP as String){
                        addFTPProxy(systemProxySettings, proxy);
                    }else if(type == kCFProxyTypeHTTP as String){
                        addHTTPProxy(systemProxySettings,proxy);
                    }else if(type == kCFProxyTypeHTTPS as String){
                        addHTTPSProxy(systemProxySettings  as! Dictionary<String,AnyObject>, proxy);
                    }else if(type == kCFProxyTypeSOCKS as String){
                        addSOCKSProxy(systemProxySettings, proxy);
                    }else if(type == kCFProxyTypeAutoConfigurationJavaScript as String){
                        addPACScriptProxy(systemProxySettings, proxy);
                    }else if(type == kCFProxyTypeAutoConfigurationURL as String){
                        addPACURLProxy(systemProxySettings, proxy);
                    }else if(type == kCFProxyTypeNone as String){
                        addNONEProxy(systemProxySettings, proxy);
                    }
                }
            }
        }
    }
    
    
    private func addFTPProxy(_ settings: CFDictionary, _ proxy: [String:AnyObject] ){
        if let server = proxy[kCFProxyHostNameKey as String] as? String{
            if let port = proxy[kCFProxyPortNumberKey as String]  as? Int{
                
                proxies.append(Proxy(host: server, port: String(port), user: nil, password: nil, type: proxy[kCFProxyTypeKey as String] as! String));
                
            }
        }
    }
    
    private func addHTTPProxy(_ settings: CFDictionary, _ proxy: [String:AnyObject] ){
        
        if let server = proxy[kCFProxyHostNameKey as String] as? String{
            if let port = proxy[kCFProxyPortNumberKey as String]  as? Int{
                //let user  = (settings as NSDictionary)["HTTPUser"] as? String;
                proxies.append(Proxy(host: server, port: String(port), user: nil, password: nil, type: proxy[kCFProxyTypeKey as String] as! String));
                
            }
        }
    }
    
    private func addHTTPSProxy(_ settings: Dictionary<String, AnyObject>, _ proxy: [String:AnyObject] ){
        if let server = proxy[kCFProxyHostNameKey as String] as? String{
            if let port = proxy[kCFProxyPortNumberKey as String]  as? Int{
                //let user  = settings["HTTPProxyUsername"] as? String;
                proxies.append(Proxy(host: server, port: String(port), user: nil, password: nil, type: proxy[kCFProxyTypeKey as String] as! String));
                
            }
        }
    }
    
    private func addSOCKSProxy(_ settings: CFDictionary, _ proxy: [String:AnyObject] ){
        if let server = proxy[kCFProxyHostNameKey as String] as? String{
            if let port = proxy[kCFProxyPortNumberKey as String]  as? Int{
                
                proxies.append(Proxy(host: server, port: String(port), user: nil, password: nil, type: proxy[kCFProxyTypeKey as String] as! String));
                
            }
        }
    }
    
    /**
     Calls PACResolver to resolve the given script for this URL
     Check fo more comment in PACURLResolver and addPACURLProxy as they nearly the same
     */
    private func addPACScriptProxy(_ settings: CFDictionary, _ proxy: [String:AnyObject] ){
        if let pacScript =  proxy["kCFProxyTypeAutoConfigurationJavaScript"] as? String{
            let resolver = PACResolver(script: pacScript);
            if let result = resolver.resolve(targetURL: url) as? Array<CFDictionary>{
                for proxy in result {
                    if let dic = proxy as? Dictionary<String, AnyObject> {
                        if(dic[kCFProxyTypeKey as String] as! CFString == kCFProxyTypeHTTPS){
                            
                            if let host = dic[kCFProxyHostNameKey as String] as? String,
                               let port = dic[kCFProxyPortNumberKey as String] as? Int{
                                proxies.append(Proxy(host: host, port: String(port), user: nil, password: nil, type: dic[kCFProxyTypeKey as String] as! String));
                            }
                        }else if(dic[kCFProxyTypeKey as String] as! CFString == kCFProxyTypeHTTP) {
                            
                            if let host = dic[kCFProxyHostNameKey as String] as? String,
                               let port = dic[kCFProxyPortNumberKey as String] as? Int{
                                proxies.append(Proxy(host: host, port: String(port), user: nil, password: nil, type: dic[kCFProxyTypeKey as String] as! String));
                            }
                        }else if(dic[kCFProxyTypeKey as String] as! CFString == kCFProxyTypeNone){
                            
                            
                            proxies.append(Proxy(host: nil, port: nil, user: nil, password: nil, type: dic[kCFProxyTypeKey as String] as! String));
                        }}
                }
                
            }
        }
        
    }
    
    /**
     Calls PACURLResolver to resolve the given PAC URL  for this URL
     */
    private func addPACURLProxy(_ settings: CFDictionary, _ proxy: [String:AnyObject] ){
        // get url of PAC
        if let pacUrl =  proxy["kCFProxyAutoConfigurationURLKey"] as? NSURL{
            //init resolver
            let resolver = PACURLResolver(url: pacUrl as CFURL);
            // resolve
            if let result = resolver.resolve(targetURL: url) as? Array<CFDictionary>{
                // iterate over result and add proxies
                for proxy in result {
                    if let dic = proxy as? Dictionary<String, AnyObject> {
                        if(dic[kCFProxyTypeKey as String] as! CFString == kCFProxyTypeHTTPS){
                            
                            if let host = dic[kCFProxyHostNameKey as String] as? String,
                               let port = dic[kCFProxyPortNumberKey as String] as? Int{
                                proxies.append(Proxy(host: host, port: String(port), user: nil, password: nil, type: dic[kCFProxyTypeKey as String] as! String));
                            }
                        }else if(dic[kCFProxyTypeKey as String] as! CFString == kCFProxyTypeHTTP) {
                            
                            if let host = dic[kCFProxyHostNameKey as String] as? String,
                               let port = dic[kCFProxyPortNumberKey as String] as? Int{
                                proxies.append(Proxy(host: host, port: String(port), user: nil, password: nil, type: dic[kCFProxyTypeKey as String] as! String));
                            }
                        }else if(dic[kCFProxyTypeKey as String] as! CFString == kCFProxyTypeNone){
                            proxies.append(Proxy(host: nil, port: nil, user: nil, password: nil, type: dic[kCFProxyTypeKey as String] as! String));
                            
                        }}
                }
                
            }
        }
    }
    
    private func addNONEProxy(_ settings: CFDictionary, _ proxy: [String:AnyObject] ){
        proxies.append(Proxy(host: nil, port: nil, user: nil, password: nil, type: proxy[kCFProxyTypeKey as String] as! String));
    }
    
    func QCFNetworkCopySystemProxySettings() -> CFDictionary? {
        guard let proxiesSettingsUnmanaged = CFNetworkCopySystemProxySettings() else {
            return nil
        }
        return proxiesSettingsUnmanaged.takeRetainedValue()
    }
    
    func QCFNetworkCopyProxiesForURL(_ url: URL, _ proxiesSettings: CFDictionary) -> [[String:AnyObject]] {
        let proxiesUnmanaged = CFNetworkCopyProxiesForURL(url as CFURL, proxiesSettings)
        let proxies = proxiesUnmanaged.takeRetainedValue()
        return proxies as! [[String:AnyObject]]
    }
    
    
    /*
     TODO maybe usefull
     func readPasswordOfUser(user: String, server: String, port: String,isHttps:  Bool ) -> String? {
     let query: [String: AnyObject] = [
     kSecClass as String: kSecClassInternetPassword,
     kSecAttrServer as String: server as CFString,
     kSecAttrProtocolHTTPS as String: (isHttps) ? kCFBooleanTrue : kCFBooleanFalse,
     kSecAttrProtocolHTTP as String: (isHttps) ? kCFBooleanFalse : kCFBooleanTrue,
     kSecAttrPort as String: port as CFString,
     kSecAttrAccount as String: user  as CFString,
     
     // kSecMatchLimitOne indicates keychain should read
     // only the most recent item matching this query
     kSecMatchLimit as String: kSecMatchLimitOne,
     
     // kSecReturnData is set to kCFBooleanTrue in order
     // to retrieve the data for the item
     kSecReturnData as String: kCFBooleanTrue,
     kSecReturnAttributes as String: kCFBooleanTrue
     
     
     ]
     
     // SecItemCopyMatching will attempt to copy the item
     // identified by query to the reference itemCopy
     var itemCopy: AnyObject?
     let status = SecItemCopyMatching(
     query as CFDictionary,
     &itemCopy
     )
     
     // errSecItemNotFound is a special status indicating the
     // read item does not exist. Throw itemNotFound so the
     // client can determine whether or not to handle
     // this case
     guard status == errSecItemNotFound else {
     return nil;
     }
     
     // Any status other than errSecSuccess indicates the
     // read operation failed.
     guard status != errSecSuccess else {
     return nil;
     }
     
     // This implementation of KeychainInterface requires all
     // items to be saved and read as Data.
     guard let password = itemCopy as? Data else {
     return nil;
     }
     
     return String(decoding: password, as: UTF8.self)
     }*/
    
}

/**
 PACResolver to resolve PAC script located in a specif URL for a specific URL
 */
class PACURLResolver {
    
    /**
     url is the url of the PAC
     */
    init(url: CFURL) {
        self.url = url
    }
    
    /**
     url is the url of the PAC
     */
    let url: CFURL
    
    /**
     storage for retrieved proxies
     */
    var proxies : CFArray?;
    
    enum Result {
        case error(error: CFError?)
        case proxies(proxies: CFArray)
    }
    typealias Callback = (_ result: Result) -> Void
    
    private var runLoopSource: CFRunLoopSource?
    
    func resolve(targetURL: URL)-> CFArray?{
        
        return startNextRequest(targetUrl: targetURL)
        
    }
    
    /**
     Calls CFNetworkExecuteProxyAutoConfigurationURL which create a RunLoop.
     Ths Runloop will be executed and result stored
     */
    private func startNextRequest(targetUrl: URL) -> CFArray?{
        
        var context = CFStreamClientContext()
        context.info = Unmanaged.passRetained(self).toOpaque()
        let rls = CFNetworkExecuteProxyAutoConfigurationURL(
            self.url,
            targetUrl as CFURL,
            { (info, proxies, error) in
                let obj = Unmanaged<PACURLResolver>.fromOpaque(info).takeRetainedValue()
                if let error = error {
                    print(error);
                } else {
                    obj.proxies = proxies;
                }
                CFRunLoopStop(CFRunLoopGetCurrent());
            },
            &context
        )
        assert(self.runLoopSource == nil)
        self.runLoopSource = rls
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, CFRunLoopMode.defaultMode)
        CFRunLoopRun();
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, CFRunLoopMode.defaultMode);
        return proxies;
    }
}

class PACResolver {
    
    init(script: String) {
        self.script = script
    }
    
    let script: String
    var proxies : CFArray?;
    
    enum Result {
        case error(error: CFError?)
        case proxies(proxies: CFArray)
    }
    typealias Callback = (_ result: Result) -> Void
    
    private var runLoopSource: CFRunLoopSource?
    
    func resolve(targetURL: URL)-> CFArray?{
        
        return startNextRequest(targetUrl: targetURL)
        
    }
    
    private func startNextRequest(targetUrl: URL) -> CFArray?{
        
        var context = CFStreamClientContext()
        context.info = Unmanaged.passRetained(self).toOpaque()
        let rls = CFNetworkExecuteProxyAutoConfigurationScript(
            self.script as CFString,
            targetUrl as CFURL,
            { (info, proxies, error) in
                let obj = Unmanaged<PACURLResolver>.fromOpaque(info).takeRetainedValue()
                if let error = error {
                    print(error);
                } else {
                    obj.proxies = proxies;
                }
                CFRunLoopStop(CFRunLoopGetCurrent());
            },
            &context
        )
        assert(self.runLoopSource == nil)
        self.runLoopSource = rls
        CFRunLoopAddSource(CFRunLoopGetCurrent(), rls, CFRunLoopMode.defaultMode)
        CFRunLoopRun();
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), rls, CFRunLoopMode.defaultMode);
        return proxies;
    }
}
