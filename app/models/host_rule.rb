class HostRule < ActiveRecord::Base
  establish_connection :rule
  scope :host, ->(host) { where(:host => host) }
  scope :port, ->(port) { where(:port => port) }
  scope :no_port, -> { where(:port => nil) }
  scope :include_sub, -> { where(:include_sub => true) }
  scope :ord_order, -> { order(:ord) }

  def self.matched_rules(host, port)
    parent_host = self.get_parent_host host
    (self.host(host).port(port).ord_order + self.host(host).no_port.ord_order +
        (parent_host ? self.host(parent_host).no_port.include_sub.ord_order : []))
  end

  private

  def self.get_parent_host(host)
    s = host.split('.')
    s.size < 3 ? nil : s[1..-1].join('.')
  end
end
