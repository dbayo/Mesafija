class ApiMesafijaMailer < ActionMailer::Base
	def usuario_regpswd(user)
		@user = user
		mail :to => user.email, :from => "info@mesafija.com", :subject => "Regeneración de contraseña"
	end
end