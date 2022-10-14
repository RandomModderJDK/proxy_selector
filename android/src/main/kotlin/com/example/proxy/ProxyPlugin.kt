package com.example.proxy

import android.content.Context
import android.net.ConnectivityManager
import android.net.ProxyInfo
import androidx.annotation.NonNull
import androidx.core.content.ContextCompat.getSystemService
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.net.InetSocketAddress
import java.net.Proxy
import java.net.ProxySelector
import java.net.URI


/** ProxyPlugin
 * Simple wrapper of ProxySelector (java.net.ProxySelector)
 * Will convert List<Proxy> to a custom json representation of proxies. Check convertProxyListToJson method
 */
class ProxyPlugin: FlutterPlugin, MethodCallHandler {

  private val methodChannelName:String = "proxy"
  private val getSystemProxyForUriMethodName:String = "getSystemProxyForUri"
  private var manager: ConnectivityManager? = null
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, methodChannelName)
    channel.setMethodCallHandler(this)
    manager =
      flutterPluginBinding.applicationContext.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == getSystemProxyForUriMethodName) {
      val uriAsString: String? = call.argument<String>("uri")
      if(!uriAsString.isNullOrBlank()){
        // convert to UIR
        val uri: URI = URI.create(uriAsString)
        // retrieve Proxies  from OS
        val proxies: List<Proxy?>? = getProxiesForThisUri(uri)
        // check if exists
        if(!proxies.isNullOrEmpty()){
          // convert list to json representation and return back to dart
          result.success(convertProxyListToJson(uri,proxies))
          return
        }
      }
      // fallback empty list
      result.success("[]")
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  /**
   * Calls ProxySelector.select with uri which return a List of Proxy
   */
  private fun getProxiesForThisUri(uri: URI): List<Proxy?>? {
    return ProxySelector.getDefault().select(uri)
  }

  /**
   * Converts List<Proxy> to a json representation. Checks for each Proxy if it a
   * NONE, HTTP/HTTPS or SOCKS Proxy. Then add an item to a json list ->
   * {host,port,type, user, password}
   * type = [HTTP,HTTPS,SOCKS,NONE]
   * user/password not supported at the moment
   */
  private fun convertProxyListToJson(uri: URI, proxies: List<Proxy?>): String? {
    val builder = StringBuilder()
    builder.append("[")
    val iterator: Iterator<Proxy?> = proxies.iterator()
    while (iterator.hasNext()) {
      val proxy = iterator.next() ?: continue

      if (proxy.type() == Proxy.Type.DIRECT) {
        builder.append("{\"host\":\"\", \"port\":\"\",\"type\":\"NONE\",\"user\":\"\",\"password\":\"\"}")
      } else if (proxy.type() == Proxy.Type.HTTP && proxy.address() is InetSocketAddress) {
        val address: InetSocketAddress = proxy.address() as InetSocketAddress
        if ("http" == uri.scheme) {
          builder.append(
            java.lang.String.format(
              "{\"host\":\"%s\", \"port\":\"%s\",\"type\":\"HTTP\",\"user\":\"\",\"password\":\"\"}",
              address.getHostName(),
              address.getPort()
            )
          )
        } else if ("https" == uri.scheme) {
          builder.append(
            java.lang.String.format(
              "{\"host\":\"%s\", \"port\":\"%s\",\"type\":\"HTTPS\",\"user\":\"\",\"password\":\"\"}",
              address.getHostName(),
              address.getPort()
            )
          )
        }
      }
      else if (proxy.type() == Proxy.Type.SOCKS && proxy.address() is InetSocketAddress) {
        val address: InetSocketAddress = proxy.address() as InetSocketAddress
          builder.append(
            java.lang.String.format(
              "{\"host\":\"%s\", \"port\":\"%s\",\"type\":\"SOCKS\",\"user\":\"\",\"password\":\"\"}",
              address.getHostName(),
              address.getPort()
            )
          )
      }
      if (iterator.hasNext()) {
        builder.append(",")
      }
    }
    builder.append("]")
    return builder.toString()
  }
}
