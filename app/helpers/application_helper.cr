module ApplicationHelper
  alias AnyKey = String | Symbol
  alias AnyValue = String | Symbol | Int32 | Int64 | Nil
  alias ParamsHash = Hash(AnyKey, AnyValue)
  alias ParamsArray = Array(Tuple(AnyKey, AnyValue))
  alias AnyHash = Hash(AnyKey, AnyValue)
  alias NormalizedHash = Hash(String, String)

  protected def normalize_hash(inital : AnyHash | NamedTuple)
    ans = NormalizedHash.new
    inital.to_a.each do |pair|
      ans[pair[0].to_s] = pair[1].to_s
    end
    ans
  end

  protected def user_signed_in?
    context.request.session.try(&.user?)
  end

  protected def current_user
    context.request.session.try(&.user)
  end

  protected def status_code!(status_code : Int32 = 200)
    @context.response.status_code = status_code
  end

  protected def redirect_to(path : String, status_code : Int32 = 302)
    @context.response.headers.add("Location", path)
    @context.response.status_code = status_code
    @context.response.close
  end
end
