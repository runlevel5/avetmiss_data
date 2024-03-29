# A store represents a line in a NAT file.
class AvetmissData::Stores::Base
  class_attribute :file_name, :parser, :builder, :attribute_names
  attr_accessor :line_number, :package

  def self.nat_file(file_name, mapping)
    self.file_name = file_name
    self.parser = AvetmissData::Parser.new(mapping)
    self.builder = AvetmissData::Builder.new(mapping)
    self.attribute_names = mapping.keys
    attr_accessor *attribute_names
  end

  nat_file('', {
    identifier: 0..-1
  })

  def self.from_line(line, line_number = 0)
    new(parser.parse(line).merge(line_number: line_number))
  end

  def initialize(attributes = {})
    self.attributes = attributes
  end

  def attributes
    Hash[self.attribute_names.map { |attr| [attr, send(attr)] }]
  end

  def attributes=(attributes)
    attributes.each_pair do |attr, value|
      send("#{attr}=", value)
    end
  end

  def [](attr)
    send(attr)
  end

  def []=(attr, value)
    send("#{attr}=", value)
  end

  def to_line
    builder.build(attributes)
  end

  def package=(package)
    @package = package
    store_list = package.store_list_for(self)
    (store_list << self) unless store_list.include?(self)
    @package
  end

  def self.version
    raise "Subclass must implement"
  end

  def version
    self.class.version
  end

  def self.version_constant
    raise "Subclass must implement"
  end

  def version_constant
    self.class.version_constant
  end

  def self.v6?
    version == "6.1"
  end

  def v6?
    self.class.v6?
  end

  def self.v7?
    version == "7.0"
  end

  def v7?
    self.class.v7?
  end

  def self.store_name
    self.name.demodulize.underscore
  end

  def store_name
    self.class.store_name
  end

  def self.store_name_to_class(symbol, version = version_constant)
    store_name = symbol.to_s.gsub(/_stores?\Z/, '').camelize
    AvetmissData::Stores.const_get(version).const_get(store_name)
  end

  def store_name_to_class(symbol)
    self.class.store_name_to_class(symbol)
  end

  class_attribute :store_finders
  self.store_finders = {}

  def self.store_finder(kind, self_atttribute, foreign_attribute = self_atttribute)
    self.store_finders[kind] = {
      self_attribute: self_atttribute,
      foreign_attribute: foreign_attribute
    }

    # This is an example of what the define_method calls do:
    # store_finder :rto_delivery_location, 'delivery_location_identifier',
    #  'training_organisation_delivery_location_identifier'

    # def rto_delivery_location_store
    #   return nil unless package
    #
    #   if store_name == 'rto_delivery_location'
    #     self
    #   else
    #     package.rto_delivery_location_stores.find { |store| store.training_organisation_delivery_location_identifier
    #       == self.delivery_location_identifier
    #   end
    # end
    define_method("#{kind}_store") do
      return nil unless package

      if store_name == kind.to_s
        self
      else
        self_value = send(self_atttribute)
        package.send("#{kind}_stores").find { |store| store.send(foreign_attribute) == self_value }
      end
    end

    # def rto_delivery_location_store_exists?
    #   rto_delivery_location_store.exists?
    # end
    define_method("#{kind}_store_exists?") do
      send("#{kind}_store").present?
    end
  end

  store_finder :rto, :training_organisation_identifier
  store_finder :rto_delivery_location, :delivery_location_identifier,
    :training_organisation_delivery_location_identifier
  store_finder :course, :qualification_identifier
  store_finder :unit_of_competency, :unit_competency_identifier
  store_finder :client, :client_identifier
  store_finder :client_postal_detail, :client_identifier
  store_finder :disability, :client_identifier
  store_finder :achievement, :client_identifier
  store_finder :enrolment, :client_identifier
  store_finder :qual_completion, :client_identifier

end
