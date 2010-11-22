module AWeber
  class Base

    def initialize(oauth)
      @oauth = oauth
    end

    def account
      accounts.first.last
    end

  private

    def get(uri)
      response = oauth.get(expand(uri))
      handle_errors(response, uri)
      parse(response) if response
    end
    
    def handle_errors(response, uri)
      if response.is_a? Net::HTTPNotFound
        raise NotFoundError, "Invalid resource uri.", caller
      elsif response && response.body == "NotAuthorizedError"
        raise OAuthError, "Could not authorize OAuth credentials.", caller
      end
    end

    def accounts
      @accounts ||= Collection.new(self, Resources::Account, get("/accounts"))
    end

    def expand(uri)
      parsed = URI.parse(uri)
      url = []
      url << AWeber.api_endpoint unless parsed.host
      url << API_VERSION unless parsed.path.include? API_VERSION
      url << uri
      File.join(*url)
    end

    def parse(response)
      JSON.parse(response.body)
    end

    def oauth
      @oauth
    end
  end
end