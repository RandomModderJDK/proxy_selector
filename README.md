# proxy_selector

This plugin lets you retrieve proxy settings for specific URL.

Currently iOS and Android supported.

On Android it uses `ProxySelector` from `java.net`.
On iOS it uses `CFNetworkCopySystemProxySettings`/`CFNetworkCopyProxiesForURL` and for PAC (Script/Url) `CFNetworkExecuteProxyAutoConfigurationURL`/`CFNetworkExecuteProxyAutoConfigurationScript` to resolve PAC script.

FTP (iOS only) and SOCKS not tested.
Credentials (iOS) not supported.
## How to test

You can use your own proxy server or any other proxy tools for testing purpose. I used Proxyman.

1. Install Proxyman
2. Set up your physical device with Proxyman. Goal is to be able track all traffic in Proxyman
3. Open browser and enter some random address
4. Proxyman displays all requests
5. Run example project on your device
6. Execute entered URL
7. No proxy displayed in Proxyman
8. Enable Proxy
9. Execute entered URL
10. Proxy settings displayed

### To test pac.

You need nginx on your device and a pac file.
For easy set up i used this PAC which points to Proxyman proxy

```javascript
function FindProxyForURL (url, host) {

    // return 'PROXY 1111.1111.1111.1111:9999; DIRECT';
    return 'PROXY [Enter here ip address of Proxyman and port]; DIRECT';
  }
```

and nginx.conf with root as path to dir ith contained pac file.

```
events {}
http {
    include       mime.types;
    default_type   application/x-ns-proxy-autoconfig;

    server {
        location / {
            # path to root where testfile.pac located
            root /../../../;
        }
    }
}
```
After this reload or start nginx. Your PAC should now be accessible under your local ip address (localhost). Care that the file returned with the mime type: `application/x-ns-proxy-autoconfig`

Enter your ip address as URL in your proxy setting of the device. After this you can test PAC with the example.

```
Example:
1111.1111.1111.1111/testfile.pac
```
## Source 

Following sources were used to implement this plugin.

https://yamsergey.medium.com/flutter-and-proxy-1e2b6acd24f5

iOS:

https://developer.apple.com/forums/thread/65416
https://developer.apple.com/documentation/cfnetwork/1426639-cfnetworkcopyproxiesforurl
https://developer.apple.com/forums/thread/669346

Android:

https://developer.android.com/reference/java/net/ProxySelector