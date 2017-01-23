--[[ 
CeNer Team ;) 
By @mrcliapi 
]]
do

local function run(msg, matches)
  if matches[1] == '??' then
    if is_sudo(msg) then
    send_document(get_receiver(msg), "./data/me/sudo.webp", ok_cb, false)
      return "<code>???? ????</code>"
    elseif is_admin1(msg) then
    send_document(get_receiver(msg), "./data/me/admin.webp", ok_cb, false)
      return "<i>YoU Admin</i>"
    elseif is_owner(msg) then
    send_document(get_receiver(msg), "./data/me/owner.webp", ok_cb, false)
      return "<i>YoU Owner</i>"
    elseif is_momod(msg) then
    send_document(get_receiver(msg), "./data/me/mod.webp", ok_cb, false)
      return "<i>YoU Moderator</i>"
    else
    send_document(get_receiver(msg), "./data/me/mmber.webp", ok_cb, false)
      return "<i>YoU member</i>"
    end
  end
end

return {
  patterns = {
    "^(??)$",
    "^(??)$"
    },
  run = run
}
end
--[[
CerNer Team
by @mrcliapi
]]
