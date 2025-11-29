# frozen_string_literal: true

class ApplicationInteraction < ActiveInteraction::Base
  include ActionView::Helpers::TranslationHelper

  set_callback :execute, :after, :save_object_errors, if: :object_invalid?

  def valid?(*)
    return @_interaction_valid if instance_variable_defined?(:@_interaction_valid)
    return @_interaction_valid = false if errors.any?

    super
  end

  def invalid?
    !valid?
  end

  def to_model
    respond_to?(:object) ? object : {}
  end

  def transactional_create!(klass, attributes)
    record = klass.new(attributes)
    record.save!
    record
  rescue ActiveRecord::RecordInvalid
    errors.merge!(record.errors)
    raise ActiveRecord::Rollback
  end

  def transactional_update!(record, attributes)
    record.update!(attributes)
    record
  rescue ActiveRecord::RecordInvalid
    errors.merge!(record.errors)
    raise ActiveRecord::Rollback
  end

  private

  def object_invalid?
    respond_to?(:object) && object&.invalid?
  end

  def save_object_errors
    errors.merge!(object.errors)
  end
end
