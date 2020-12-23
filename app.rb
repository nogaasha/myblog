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

		@db.execute 'CREATE TABLE IF NOT EXISTS  
		Comments
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT,
			post_id INTEGER
		)'
end	
get '/' do

	@results = @db.execute 'select * from Posts order by id desc'
	erb :index			
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

	redirect to '/'		
end

get '/details/:post_id' do
	#получаем переменную из url
	post_id= params[:post_id]
	#Выбираем список постов с определенным id (один пост)
  results = @db.execute 'select * from Posts where id = ?', [post_id]
  #выбираем этот пост в переменную row
	@row = results[0]
	# выбираем комментарии для поста
	@comments =  @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details 
end	

post '/details/:post_id' do
 	#получаем переменную из url
	 post_id= params[:post_id]
	 content = params[:content]
	 @db.execute 'insert into Comments (content, created_date, post_id) 
	 values (?, datetime(), ?)',
	 [content, post_id]	
   # перенаправляем на страницу с постом
	 redirect to ('/details/' + post_id)

end	