### CoffeeScript version of the browser detection from MooTools ###

ua = navigator.userAgent.toLowerCase()
platform = navigator.platform.toLowerCase()
UA = ua.match(/(opera|ie|firefox|chrome|version)[\s\/:]([\w\d\.]+)?.*?(safari|version[\s\/:]([\w\d\.]+)|$)/) or [null, 'unknown', 0]
mode = UA[1] == 'ie' && document.documentMode

browser =
  name: if UA[1] is 'version' then UA[3] else UA[1]
  version: mode or parseFloat(if UA[1] is 'opera' && UA[4] then UA[4] else UA[2])

  platform:
    name: if ua.match(/ip(?:ad|od|hone)/) then 'ios' else (ua.match(/(?:webos|android)/) or platform.match(/mac|win|linux/) or ['other'])[0]

browser[browser.name] = true
browser[browser.name + parseInt(browser.version, 10)] = true
browser.platform[browser.platform.name] = true

module.exports = browser
