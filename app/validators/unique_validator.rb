class UniqueValidator < ActiveModel::EachValidator
  VALID_UNIQUE_REGEX = /\A[a-z0-9_]+\z/i
  def validate_each(record, attribute, value)
    unless value =~ VALID_UNIQUE_REGEX
      record.errors[attribute] << (options[:message] || "は正しいアカウント名ではありません。")
    end
  end
end
