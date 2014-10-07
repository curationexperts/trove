class User < ActiveRecord::Base
  # Connects this user object to Hydra behaviors.
  include Hydra::User
  # Connects this user object to Blacklights Bookmarks.
  include Blacklight::User
  include Tufts::User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Method added by Blacklight; Blacklight uses #to_s on your
  # user class to get a user-displayable login/identifier for
  # the account.
  def to_s
    user_key
  end

  def personal_collection_proxy
    root = PersonalCollectionSolrProxy.new(id: root_pid)
    return root if root.exists?
    PersonalCollectionSolrProxy.new(id: root_pid, title: collection_title)
  end

  def root_pid
    # escape invalid chars in pids
    # https://wiki.duraspace.org/display/FEDORA37/Fedora+Identifiers#FedoraIdentifiers-PIDspids
    escaped_user_key = user_key.gsub(/[^([A-Za-z0-9])|\-|\.|~]/){|c| '_' + c.ord.to_s(16)}
    "tufts.uc:personal_#{escaped_user_key}"
  end

end
