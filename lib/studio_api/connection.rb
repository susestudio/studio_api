#
#  Copyright (c) 2010 Novell, Inc.
#  All Rights Reserved.
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public License as
#  published by the Free Software Foundation; version 2.1 of the license.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.   See the
#  GNU Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public License
#  along with this library; if not, contact Novell, Inc.
#
#  To contact Novell about this file by physical or electronic mail,
#  you may find current contact information at www.novell.com

require 'uri'
require 'openssl'

module StudioApi
  class Connection
    attr_accessor :user, :password, :uri, :proxy, :timeout, :verify_mode, :ca_path
    def initialize(user, password, uri, options={})
      @user = user
      @password = password
      self.uri = uri
      self.proxy = options[:proxy] #nil as default is OK
      self.timeout = options[:timeout] || 45
#FIXME solve better SSL attributes. e.g. by separate hash and instance_eval it
      @ca_path = options[:ca_path] #nil as default is OK
      @verify_mode = options[:verify_mode] || OpenSSL::SSL::VERIFY_NONE #nil as default is OK
    end

    def uri=(value)
      if value.is_a? String
        @uri = URI.parse value
      else
        @uri = value
      end
    end

    def proxy=(value)
      if value.is_a? String
        @proxy = URI.parse value
      else
        @proxy = value
      end
    end
  end
end
