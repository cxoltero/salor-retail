# ------------------- Salor Point of Sale ----------------------- 
# An innovative multi-user, multi-store application for managing
# small to medium sized retail stores.
# Copyright (C) 2011-2012  Jason Martin <jason@jolierouge.net>
# Visit us on the web at http://salorpos.com
# 
# This program is commercial software (All provided plugins, source code, 
# compiled bytecode and configuration files, hereby referred to as the software). 
# You may not in any way modify the software, nor use any part of it in a 
# derivative work.
# 
# You are hereby granted the permission to use this software only on the system 
# (the particular hardware configuration including monitor, server, and all hardware 
# peripherals, hereby referred to as the system) which it was installed upon by a duly 
# appointed representative of Salor, or on the system whose ownership was lawfully 
# transferred to you by a legal owner (a person, company, or legal entity who is licensed 
# to own this system and software as per this license). 
#
# You are hereby granted the permission to interface with this software and
# interact with the user data (Contents of the Database) contained in this software.
#
# You are hereby granted permission to export the user data contained in this software,
# and use that data any way that you see fit.
#
# You are hereby granted the right to resell this software only when all of these conditions are met:
#   1. You have not modified the source code, or compiled code in any way, nor induced, encouraged, 
#      or compensated a third party to modify the source code, or compiled code.
#   2. You have purchased this system from a legal owner.
#   3. You are selling the hardware system and peripherals along with the software. They may not be sold
#      separately under any circumstances.
#   4. You have not copied the software, and maintain no sourcecode backups or copies.
#   5. You did not install, or induce, encourage, or compensate a third party not permitted to install 
#      this software on the device being sold.
#   6. You have obtained written permission from Salor to transfer ownership of the software and system.
#
# YOU MAY NOT, UNDER ANY CIRCUMSTANCES
#   1. Transmit any part of the software via any telecommunications medium to another system.
#   2. Transmit any part of the software via a hardware peripheral, such as, but not limited to,
#      USB Pendrive, or external storage medium, Bluetooth, or SSD device.
#   3. Provide the software, in whole, or in part, to any thrid party unless you are exercising your
#      rights to resell a lawfully purchased system as detailed above.
#
# All other rights are reserved, and may be granted only with direct written permission from Salor. By using
# this software, you agree to adhere to the rights, terms, and stipulations as detailed above in this license, 
# and you further agree to seek to clarify any right not directly spelled out herein. Any right, not directly 
# covered by this license is assumed to be reserved by Salor, and you agree to contact an official Salor repre-
# sentative to clarify any rights that you infer from this license or believe you will need for the proper 
# functioning of your business.
require 'digest/sha2'
class Employee < ActiveRecord::Base
	include SalorScope
	include SalorBase
  include SalorModel
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  include UserEmployeeMethods
  
  validates_uniqueness_of :username
  validate :validify
  belongs_to :user
  belongs_to :vendor
  has_many :orders
  has_many :vendors, :through => :user
  has_many :paylife_structs, :as => :owner
  has_many :cash_register_dailies
  has_and_belongs_to_many :roles
  has_one :meta, :as => :ownable
  has_one :drawer, :as => :owner
  has_many :drawer_transactions, :as => :owner
  # Setup accessible (or protected) attributes for your model
  attr_accessible :uses_drawer_id,:apitoken,:js_keyboard,:role_ids,:language,:vendor_id,:user_id,:first_name,:last_name,:username, :email, :password, :password_confirmation, :remember_me
  attr_accessible :auth_code
  def self.find_for_authentication(conditions={})
    conditions[:hidden] = false
      find(:first, :conditions => conditions)
    end 
  def validify
    if self.email.blank? then
      e = Digest::SHA256.hexdigest(Time.now.to_s)[0..12]
      self.email = "#{e}@salorpos.com"
    end
  end
  
  
  def make_token
    if self.apitoken.blank? then
      self.apitoken = ''
      t= rand(36**24).to_s(36)
      m = ['!','@','#','$','%','^','&','*','(','/','{','"$5%','/#!5','3&^','10%*@','z&6$!`']
      ls = ''
      t.each_char do |c|
        if rand(100) < 48 then
          c = c.upcase
        end
        if rand(100) < 67 then
          self.apitoken << m[rand(m.length-1)]
        end
        if c == ls then
          self.apitoken << m[rand(m.length-1)]
        end
        self.apitoken << c
        ls = c
      end
    end
    self.apitoken
  end

  def name_with_username
    "#{ first_name } #{ last_name } (#{ username })"
  end
end