require "json"

abstract class BaseSerializer
  abstract def as_json

  alias AnyKey = String | Symbol
  alias AnyPrimitive = String | Symbol | Float32 | Float64 | Int32 | Int64 | Nil
  alias AnyValue = Array(AnyPrimitive) | Hash(AnyKey, AnyPrimitive) | Enumerable(AnyPrimitive) | JSON::Any::Type

  def to_json
    as_json.to_json
  end

  def to_s
    as_json.to_s
  end

  def self.to_h(value)
    value.to_a.map { |e| [e.first.to_s, e.last] }.to_h
  end

  def to_h
    as_json.to_a.map { |e| [e.first.to_s, e.last] }.to_h
  end

  def merge(value)
    return as_json unless value.responds_to?(:to_a)
    to_h.merge(self.class.to_h(value))
  end
end
