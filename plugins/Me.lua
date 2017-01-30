--[[ 
CeNer Team ;) 
By @mrcliapi 
]]
do

local function run(msg, matches)
  if matches[1] == 'من کی هستم' then
    if is_sudo(msg) then
    send_document(get_receiver(msg), "./man/sudo.webp", ok_cb, false)
      return "<code>سازنده ربات</code>"
    elseif is_admin1(msg) then
    send_document(get_receiver(msg), "./man/admin.webp", ok_cb, false)
      return "<i>ادمین</i>"
    elseif is_owner(msg) then
    send_document(get_receiver(msg), "./man/owner.webp", ok_cb, false)
      return "<i>مدیر گروه</i>"
    elseif is_momod(msg) then
    send_document(get_receiver(msg), "./man/mod.webp", ok_cb, false)
      return "<i>کمک مدیر</i>"
    else
    send_document(get_receiver(msg), "./man/mmber.webp", ok_cb, false)
      return "<i>چس ممبر</i>"
    end
  end
end

return {
  patterns = {
    "^(من کی هستم)$",
    },
  run = run
}
end
--[[
CerNer Team
by @mrcliapi
]]
