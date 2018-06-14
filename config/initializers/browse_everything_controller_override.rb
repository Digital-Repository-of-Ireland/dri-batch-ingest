
BrowseEverythingController.class_eval do
  private

  def browser
    url_options = BrowseEverything.config
    if url_options['sandbox_file_system'].present?
        url_options['sandbox_file_system'][:current_user] = current_user.email if current_user
    end
    
    BrowserFactory.build(session: session, url_options: url_options)
  end
end

