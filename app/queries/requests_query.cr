require "../models/user"
require "../models/request_item"

class RequestsQuery
  def initialize(@uuid : String)
  end

  def total_count
    cnt = 0
    RequestItem.scalar("
      SELECT COUNT(*)
      FROM request_items
      WHERE client_uuid='#{@uuid}'
    ") do |count|
      cnt = count.try(&.to_s.to_i) || 0
    end
    cnt
  end

  def last(before : RequestItem | String | Int64 | Nil = nil, limit : Int32 = 5)
    if before
      if before.is_a?(String)
        before = RequestItem.first(
          "WHERE client_uuid = ? AND uuid = ?",
          [@uuid, before]
        )
      elsif before.is_a?(Int64)
        before = RequestItem.first(
          "WHERE client_uuid = ? AND id = ",
          [@uuid, before]
        )
      end

      if before_id = before.try(&.id)
        return RequestItem.all("
          WHERE client_uuid = ? AND id < ?
          ORDER BY created_at DESC, id DESC
          LIMIT ?
        ", [@uuid, before_id, limit])
      end
    end

    RequestItem.all("
      WHERE client_uuid = ?
      ORDER BY created_at DESC, id DESC
      LIMIT ?
    ", [@uuid, limit])
  end

  def list(page : Int32 = 1, per : Int32 = 5)
    page = 1 if page < 1
    per = 5 if per < 1 || per > 100
    RequestItem.all("
      WHERE client_uuid=?
      OFFSET ?
      LIMIT ?
    ", [@uuid, (page - 1) * 2, per])
  end
end
