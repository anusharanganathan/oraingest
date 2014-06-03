#require "net/http"
def isURI(string)
  uri = URI.parse(string)
  %w( http https ).include?(uri.scheme)
  #req = Net::HTTP.new(url.host, url.port)
  #res = req.request_head(url.path)
  #if res.code == "200"
  #  true
  #else
  #  false
rescue URI::BadURIError
  false
rescue URI::InvalidURIError
  false
end
