require 'sinatra'
require 'httparty'
require 'pry-debugger'

API_KEY = 'your_key'
SHARED_SECRET = 'your_secret'

def sign_request(url, params)
  signed_request = Digest::MD5.hexdigest(SHARED_SECRET + params.tr('=&', ''))
  url + params + "&api_sig=#{signed_request}"
end

def request_token
  url = "https://www.rememberthemilk.com/services/auth/?"
  redirect sign_request(url, "api_key=#{API_KEY}&perms=read")
end

get '/' do
  request_token
end

def get_tasks
  url = "https://api.rememberthemilk.com/services/rest/?"
  params = "api_key=#{API_KEY}&auth_token=#{@token}&format=json&method=rtm.tasks.getList"
  tasks_url = sign_request(url, params)
  response = HTTParty.get(tasks_url)
  logger.info(response.inspect)
  JSON.parse(response)

end

get '/rtm' do
  frob = request[:frob]
  get_auth = "api_key=#{API_KEY}&format=json&frob=#{frob}&method=rtm.auth.getToken"
  sign_url = "https://api.rememberthemilk.com/services/rest/?"

  response = HTTParty.get(sign_request(sign_url, get_auth))

  @token = JSON.parse(response)["rsp"]["auth"]["token"]
  @tasks = get_tasks

  erb :index
end

__END__
@@ index
<html>
<head>
<title>Tasks</title>
</head>
<body>
<%= @tasks["rsp"]["tasks"]["list"][0]["taskseries"].each { |t| t } %>
</body>

