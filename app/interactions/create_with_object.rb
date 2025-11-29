# frozen_string_literal: true

module CreateWithObject
  attr_reader :object

  private

  # Create an object with the given class and hash
  # @param [Class] klass
  # @param [Hash] hash
  # @return [Object]
  def simple_create(klass, hash = inputs)
    @object = klass.create(hash)
  end

  def create_with_block
    @object = yield
  end
end
