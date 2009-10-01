class Admin::SystemUser < Admin::User
  set_table_name :admin_users
  attr_protected :type
  validates_presence_of     :login, :email
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => true
  has_one     :photo, :as=>:pictureable, :dependent=>:destroy,:class_name=>"Media::ImageFile"

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    user = self.find_by_login(login) # need to get the salt
    user && user.authenticated?(password)  ? user : false
  end

  def self.authenticate_by_any(login, password)
    login.to_s =~ /(^2\d{7}$)|(^[a-z0-9_\.\-]+)@((?:[-a-z0-9]+\.)+[a-z]{2,}$)/i
    if $&.to_s.include? "@"
      self.authenticate_by_email($&, password)
    else
      self.authenticate(login.to_s, password)
    end
  end

#  def has_access? controller_name
#    return !all_accesses(controller_name).empty?
#  end

  def is_real_user?
    real_user=Admin::SystemUser.find_by_login(self.login)
    real_user==self
  end

end
