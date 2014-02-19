ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
	:address => "smtp.mesafija.com",
	:port => 587,
	:domain => "mesafija.com",
	:user_name => "username",
	:password => "password",
	:authentication => "plain",
	:enable_starttls_auto => true
}