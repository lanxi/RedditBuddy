module StaticPagesHelper
	def find_favs
		@find_favs ||= session[:names] if session[:names]
	#raise @find_favs
	end

	def find_karma
		@find_karma ||= session[:karma] if session[:karma]
	end

	def find_matches
		@find_matches ||= session[:subreddits] if session[:subreddits]
	end

	def find_matched
		@find_matched ||= session[:match] if session[:match]
	end	
end
