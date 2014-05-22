require 'ostruct'

class String
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr(" ", "_").
    tr("-", "_").
    downcase
  end
end

class Object
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end
end

class DeepOpenStruct < OpenStruct
  def initialize(hash=nil)

    @table = {}
    @hash_table = {}

    if hash
      hash.each do |k,v|

        if v.is_a?(Array)
          other = Array.new()
          v.each { | entry |
            other.push(self.class.new(entry))
          }
          v = other
        end

        @table[k.to_sym] = (v.is_a?(Hash) ? self.class.new(v) : v)
        @hash_table[k.to_sym] = v
        new_ostruct_member(k)

      end
    end
  end

  def to_h
    @hash_table
  end
end

class Hash
  def to_deep_ostruct
    DeepOpenStruct.new self
  end
end

