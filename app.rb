require 'rubygems'
require 'sinatra'

$path_to_goods = './public/goods.txt'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] || 'Hello stranger'
  end
end

get '/' do
  begin
    file = File.open($path_to_goods)
    @data = file.read
    file.close
  rescue StandardError
    puts 'File read error'
  end

  unless @data.nil?
    @data = @data.split(';').map do |str|
      name, price = str.split('|')

      next if name.chomp.empty?

      item =  '<div class="goods_item">'\
                '<div class="goods_name">Name: '\
                "#{name}"\
                '</div>'\
                '<div class="price">Price: '\
                "#{price}"\
                '</div>'\
                '<div class="buy"' << 'onclick="get_buy('\
                "'#{name}', '#{price}'"\
                ')">BUY</div>'\
                '</div>'\

      item.delete!("\n")
      item
    end

    @data = @data.join if @data.is_a?(Array)
  end

  erb :shop
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

get '/about' do
  erb :about
end

get '/shopping-cart' do
  erb :shopping_cart
end

get '/shopping-cart' do
  erb '<h2>Shopping Cart</h2>'
end

get '/logout' do
  session.delete(:identity)
  redirect to '/'
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/admin-panel' do
  redirect to '/login/form' unless session[:identity]
  erb :admin_panel
end

post '/add-item' do
  delimeter = ';'
  goods_name, price = params.values_at(:goods_name, :price)

  begin
    file = File.open($path_to_goods)
    file.close
  rescue StandardError
    File.write($path_to_goods, '')
  end

  file = File.open($path_to_goods, 'a')
  file.puts("#{goods_name}|#{price}#{delimeter}")
  file.close

  redirect to '/admin-panel'
end
