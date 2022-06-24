require 'rubygems'
require 'sinatra'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] || 'Hello stranger'
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

before '/secure/*' do
  @error = ''

  unless session[:identity]
    session[:previous_url] = request.path
    @error << "<div>Sorry, you need to be logged in to visit #{request.path}</div>"
    @error << '<div class="red-alert">Only admin can enter!</div>' if session[:identity] == false
    halt erb(:login_form)
  end

end

get '/login/form' do
  redirect to '/' if session[:identity]
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params[:username] == 'admin' ? 'admin' : false

  if session[:identity] == false
    @error = '<div class="red-alert">Only admin can enter!</div>'
    halt erb(:login_form)
  else
    redirect to '/'
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end
