module StaticPagesHelper
	def find_favs
		@find_favs ||= session[:names] if session[:names]
	#raise @find_favs
	end

	def find_karma
		@find_karma ||= session[:karma] if session[:karma]
	end

	def find_matches
		@find_matches ||= session[:matches] if session[:matches]
	end
end
