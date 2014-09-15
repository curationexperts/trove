class CustomFailure < Devise::FailureApp
  def skip_format?
    # when redirected to sign_in after trying to access a pptx file,
    # this makes us not add the .pptx extension onto the sign_in path
    # More info here: https://stackoverflow.com/questions/7996773/devise-authentication-when-accessing-directly-to-a-pdf-file-unauthenticated#8570489
    super || request_format == :pptx
  end
end
