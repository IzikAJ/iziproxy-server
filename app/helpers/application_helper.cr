require "../forms/application_form"

module ApplicationHelper
  alias AnyKey = String | Symbol
  alias AnyValue = String | Symbol | Int32 | Int64 | Nil
  alias ParamsHash = Hash(AnyKey, AnyValue)
  alias ParamsArray = Array(Tuple(AnyKey, AnyValue))
  alias AnyHash = Hash(AnyKey, AnyValue)
  alias NormalizedHash = Hash(String, String)

  class FormBuilder
    include ApplicationHelper
    property namespace : String

    def initialize(@object : ApplicationForm, @params : NormalizedHash)
      @namespace = params["as"]? || @object.class.name
    end

    def input(name : AnyKey, params : NormalizedHash)
      if params["value"]?.nil? && (val = @object[name.to_s])
        params["value"] = val
      end
      input_tag @object, "#{@namespace}[#{name}]", params
    end

    def input(name : AnyKey, **params)
      input name, normalize_hash(params)
    end

    def submit(params : NormalizedHash)
      submit_tag params
    end

    def submit(**params)
      submit_tag normalize_hash(params)
    end
  end

  def normalize_hash(inital : AnyHash | NamedTuple)
    ans = NormalizedHash.new
    inital.to_a.each do |pair|
      ans[pair[0].to_s] = pair[1].to_s
    end
    ans
  end

  def tag(name : AnyKey, params : NormalizedHash)
    attributes = params.map { |key, val| "#{key}=\"#{val}\"" }.join(" ")
    "<#{name} #{attributes}>"
  end

  def tag(name : AnyKey, **params)
    tag name, normalize_hash(params)
  end

  def content_tag(name : AnyKey, content : String, params : NormalizedHash)
    "#{tag(name, params)}#{content}</#{name}>"
  end

  def content_tag(name : AnyKey, content : String, **params)
    content_tag name, content, normalize_hash(params)
  end

  def content_tag(name : AnyKey, **params)
    content_tag name, "#{yield}", normalize_hash(params)
  end

  def link_to(title : String, path : String, params : NormalizedHash)
    params["href"] = path
    content_tag :a, title, params
  end

  def link_to(title : String, path : String, **params)
    link_to title, path, normalize_hash(params)
  end

  def link_to(path : String, **params)
    link_to "#{yield}", path, normalize_hash(params)
  end

  def form_for(form : ApplicationForm, params : NormalizedHash)
    params["action"] = "" unless params["action"]?
    params["method"] = "POST" unless params["method"]?
    builder = FormBuilder.new(form, params)
    content_tag :form, "#{yield builder}", params
  end

  def form_for(form : ApplicationForm, **params)
    form_for form, normalize_hash(params) do |form|
      yield form
    end
  end

  def input_tag(form : ApplicationForm, name : AnyKey, params : NormalizedHash)
    params["type"] = "text" unless params["type"]?
    params["name"] = name.to_s unless params["name"]?
    unless params["id"]?
      params["id"] = params["name"].gsub(/[^\w\d]+/, "_") if params["name"]?
    end
    tag :input, params
  end

  def input_tag(form : ApplicationForm, name : AnyKey, **params)
    input_tag form, name, normalize_hash(params)
  end

  def submit_tag(params : NormalizedHash)
    params["type"] = "submit" unless params["type"]?
    params["value"] = "Submit" unless params["value"]?
    tag :input, params
  end

  def submit_tag(**params)
    submit_tag normalize_hash(params)
  end
end
