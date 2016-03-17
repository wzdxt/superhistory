module SplitTable
  def self.included(base)
    base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
      self.abstract_class=true
      class_attribute :model_scopes

      def self.scope(name, body, &block)
        return super if self.is_subclass?
        self.model_scopes ||= {}
        self.model_scopes[name] = body
        name = "\#{name}_scope".to_sym
        super
      end

# def self.find(*ids)
#   res = self.all.find(ids)
  # ids.map do |id|
  #   self.find_by_id id
  # end.flatten.reject{|i|i.nil?}
# end

      def self.is_subclass?
        #{base.name}.subclasses.include? self
      end

      def self.method_missing(name, *arguments, &block)
        if self.model_scopes and self.model_scopes.include? name
          body = self.model_scopes[name]
          self.sub_classes.map do |sub|
            sub.instance_exec(*arguments, &body)
          end.split_tables
        elsif name.to_s.ends_with? '_self'
          name = name.to_s[0...-'_self'.size]
          self.send(name, *arguments, &block)
        else
          if self.is_subclass?
            super(name, *arguments, &block)
          else
            self.all.send(name, *arguments, &block)
          end
        end
      end

      def self.array_class
        #{base.name}Array
      end

      class #{base.name}Array < Array
        def method_missing(name, *arguments, &block)
          if #{base.name}.model_scopes.include? name
            body = #{base.name}.model_scopes[name]
            self.map do |v|
              v.instance_exec(*arguments, &body)
            end.split_tables

          elsif name.to_s.ends_with? '_self'
            name = name.to_s[0...-'_self'.size]
            self.send(name, *arguments, &block)

          elsif self.first.model.methods.include? name
            self.map do |v|
              v.send(name, *arguments, &block)
            end.split_tables
          else
            self.map do |v|
              v.send(name, *arguments, &block)
            end.flatten.reject{|i|i.nil?}
          end
        end
      end

      def self.sub_classes
        unless Object.const_defined? '#{base.name}::#{base.name}0'
          self.split_tables
        end
        (0...self.table_number).to_a.map do |idx|
          "#{base.name}::#{base.name}\#{idx}".constantize
        end
      end

      def self.table_number=(v)
        @@table_number = v
      end

      # to be override
      def self.table_number
        @@table_number ||= 100
      end

      # to be override
      def self.number_per_table
        1000000
      end

      # to be override
      def index_identifier
        self.id
      end

      # to be override
      def self.table_index(n)
        n/self.number_per_table
      end

      def table_index
        #{base.name}.table_index(self.index_identifier)
      end

      def self.indexed_class(n)
        #{base.name}.split_tables
        "#{base.name}::#{base.name}\#{self.table_index(n)}".constantize
      end

      def indexed_class
        #{base.name}.indexed_class(self.index_identifier)
      end

      def self.split_tables
        (0...self.table_number).to_a.each do |idx|
          if self.configurations.keys.include? "#{base.name.underscore}\#{idx}"
            self.table_number = idx + 1
            eval <<-DYNAMIC
            class #{base.name}\#{idx} < Visit
              establish_connection :#{base.name.underscore}\#{idx}
              self.table_name=:#{base.name.underscore.pluralize}
            end
            DYNAMIC
          end
        end
      end

      def initialize(attributes = nil, options = {})
        self.class.is_subclass? ? super : raise('use create! or create')
      end
    RUBY

    #可继续查询
    %w(all).each do |method|
      base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{method}(*arguments, &block)
          return super if self.is_subclass?
          self.sub_classes.map do |sub|
            sub.#{method}(*arguments, &block)
          end.split_tables
        end
      RUBY
    end

    #不可继续查询,返回普通数组
    %w(find_by).each do |method|
      base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.#{method}(*arguments, &block)
          return super if self.is_subclass?
          self.sub_classes.map do |sub|
            sub.#{method}(*arguments, &block)
          end.flatten.reject{|i|i.nil?}.first
        end
      RUBY
    end

    %w(each size count length).each do |method|
      "#{base.name}::#{base.name}Array".constantize.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*arguments, &block)
          self.map do |v|
            v.#{method}(*arguments, &block)
          end.reduce :+
        end
      RUBY
    end

    %w(find_by).each do |method|
      "#{base.name}::#{base.name}Array".constantize.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{method}(*arguments, &block)
          self.map do |v|
            v.#{method}(*arguments, &block)
          end.flatten.reject{|i|i.nil?}.first
        end
      RUBY
    end

  end

  if Array.instance_methods.exclude? :split_tables
    Array.class_eval <<-RUBY, __FILE__, __LINE__ + 1
    def split_tables
      self.first.model.array_class.new self
    end
    RUBY
  end
end