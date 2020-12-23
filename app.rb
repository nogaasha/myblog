#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db 
  @db =SQLite3::Database.new 'myblog.db'
  @db.results_as_hash = true
end  

before do       # вызывается каждый раз когда перезагрузилась страница
   init_db      # инициализация БД
end

configure do               #создаем таблицы в БД
	init_db
	 # создает таблицу если она не существует
  @db.execute 'CREATE TABLE IF NOT EXISTS  
		Posts
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT
		)'
end	
get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"			
end

get '/new' do
	erb :new			
end

post '/new' do
	content = params[:content]    # :content - это атрибут name = "content" for textarea

	if content.length <= 0
		@error= 'Введите текст'
		return erb :new
	end
	
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())',[content]	

	erb "Your typed: #{content}"			
end