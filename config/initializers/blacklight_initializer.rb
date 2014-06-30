# A secret token used to encrypt user_id's in the Bookmarks#export callback URL
# functionality, for example in Refworks export of Bookmarks. In Rails 4, Blacklight
# will use the application's secret key base instead.
#

# Blacklight.secret_key = '0ea8e39b0c5ef081c6d465794f5ce26dacb1f9e70d4bd671c57f9149f1b9da8b74b681232d51da594583ede1920cd6ea73312dd4044b05f97ca0c233d0ce7e75'
Blacklight.secret_key = Rails.application.secrets.blacklight_secret_key
