class Partner < ActiveRecord::Base

    self.primary_key = :idpartner

    def self.generateIdCliente(id)
      id.to_s + OpenSSL::HMAC.hexdigest('sha256', 'colombia', id.to_s)
    end

end
