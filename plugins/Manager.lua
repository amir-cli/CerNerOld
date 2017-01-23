--Begin supergrpup.lua
--Check members #Add supergroup
local function check_member_super(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  if success == 0 then
	send_large_msg(receiver, "‌<code>ابتدا ربات را مدیر کنید</code>")
  end
  for k,v in pairs(result) do
    local member_id = v.peer_id
    if member_id ~= our_id then
      -- SuperGroup configuration
      data[tostring(msg.to.id)] = {
        group_type = 'SuperGroup',
		long_id = msg.to.peer_id,
		moderators = {},
        set_owner = member_id ,
        settings = {
          set_name = string.gsub(msg.to.title, '_', ' '),
		  lock_arabic = 'no',
		  lock_link = "no",
          flood = 'yes',
		  lock_spam = 'yes',
		  lock_sticker = 'no',
		  member = 'no',
		  public = 'no',
		  lock_rtl = 'no',
		  lock_tgservice = 'yes',
		  lock_contacts = 'no',
		  strict = 'no'
        }
      }
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = {}
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = msg.to.id
      save_data(_config.moderation.data, data)
	  local text = '<code>سوپر گروه به لیست گروه های مدیریتی ربات اضافه شد!</code>'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Check Members #rem supergroup
local function check_member_superrem(cb_extra, success, result)
  local receiver = cb_extra.receiver
  local data = cb_extra.data
  local msg = cb_extra.msg
  for k,v in pairs(result) do
    local member_id = v.id
    if member_id ~= our_id then
	  -- Group configuration removal
      data[tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
      local groups = 'groups'
      if not data[tostring(groups)] then
        data[tostring(groups)] = nil
        save_data(_config.moderation.data, data)
      end
      data[tostring(groups)][tostring(msg.to.id)] = nil
      save_data(_config.moderation.data, data)
	  local text = '<code>سوپر گروه از لیست گروه های مدیریتی ربات حذف شد!</code>'
      return reply_msg(msg.id, text, ok_cb, false)
    end
  end
end

--Function to Add supergroup
local function superadd(msg)
	local data = load_data(_config.moderation.data)
	local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_super,{receiver = receiver, data = data, msg = msg})
end

--Function to remove supergroup
local function superrem(msg)
	local data = load_data(_config.moderation.data)
    local receiver = get_receiver(msg)
    channel_get_users(receiver, check_member_superrem,{receiver = receiver, data = data, msg = msg})
end

--Get and output admins and bots in supergroup
local function callback(cb_extra, success, result)
local i = 1
local chat_name = string.gsub(cb_extra.msg.to.print_name, "_", " ")
local member_type = cb_extra.member_type
local text = member_type.." for "..chat_name..":\n"
for k,v in pairsByKeys(result) do
if not v.first_name then
	name = " "
else
	vname = v.first_name:gsub("‮", "")
	name = vname:gsub("_", " ")
	end
		text = text.."\n"..i.." - "..name.."["..v.peer_id.."]"
		i = i + 1
	end
    send_large_msg(cb_extra.receiver, text)
end

--Get and output info about supergroup
local function callback_info(cb_extra, success, result)
local title ="اطلاعات سوپر گروه: ["..result.title.."]\n\n"
local admin_num = "تعداد مدیران:"..result.admins_count.."\n"
local user_num = "تعداد افراد: "..result.participants_count.."\n"
local kicked_num = "تعداد افراد اخراج شده "..result.kicked_count.."\n"
local channel_id = "ایدی :< "..result.peer_id.."\n"
if result.username then
	channel_username = "Username: @"..result.username
else
	channel_username = ""
end
local text = title..admin_num..user_num..kicked_num..channel_id..channel_username
    send_large_msg(cb_extra.receiver, text)
end

--Get and output members of supergroup
local function callback_who(cb_extra, success, result)
local text = "Members for "..cb_extra.receiver
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		username = " @"..v.username
	else
		username = ""
	end
	text = text.."\n"..i.." - "..name.." "..username.." [ "..v.peer_id.." ]\n"
	--text = text.."\n"..username
	i = i + 1
end
    local file = io.open("./CerNer/chat/lists/supergroups/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./CerNer/chat/lists/supergroups/"..cb_extra.receiver..".txt", ok_cb, false)
	post_msg(cb_extra.receiver, text, ok_cb, false)
end

--Get and output list of kicked users for supergroup
local function callback_kicked(cb_extra, success, result)
--vardump(result)
local text = "Kicked Members for SuperGroup "..cb_extra.receiver.."\n\n"
local i = 1
for k,v in pairsByKeys(result) do
if not v.print_name then
	name = " "
else
	vname = v.print_name:gsub("‮", "")
	name = vname:gsub("_", " ")
end
	if v.username then
		name = name.." @"..v.username
	end
	text = text.."\n"..i.." - "..name.." [ "..v.peer_id.." ]\n"
	i = i + 1
end
    local file = io.open("./CerNer/chat/lists/supergroups/kicked/"..cb_extra.receiver..".txt", "w")
    file:write(text)
    file:flush()
    file:close()
    send_document(cb_extra.receiver,"./CerNer/chat/lists/supergroups/kicked/"..cb_extra.receiver..".txt", ok_cb, false)
	--send_large_msg(cb_extra.receiver, text)
end

--Begin supergroup locks
local function lock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'yes' then
    return '<code>قفل لینک از قبل فعال بود</code>'
  else
    data[tostring(target)]['settings']['lock_link'] = 'yes'
    save_data(_config.moderation.data, data)
    return '<code>قفل لینک فعال شد</code>'
  end
end

local function unlock_group_links(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_link_lock = data[tostring(target)]['settings']['lock_link']
  if group_link_lock == 'no' then
    return '<code>قفل لینک غیرفعال بود</code>'
  else
    data[tostring(target)]['settings']['lock_link'] = 'no'
    save_data(_config.moderation.data, data)
    return '<code>قفل لینک غیر فعال شد</code>'
  end
end

local function lock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['all']
  if group_all_lock == 'yes' then
    return 'تنظیمات کلی از قبل فعال بود'
  else
    data[tostring(target)]['settings']['all'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'تنظیمات کلی فعال شد'
  end
end

local function unlock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['all']
  if group_all_lock == 'no' then
    return 'تنظیمات کلی غیر فعال بود‌'
  else
    data[tostring(target)]['settings']['all'] = 'no'
    save_data(_config.moderation.data, data)
    return 'تنظیمات کلی غیرفعال شد¡'
  end
end

local function lock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_leave_lock = data[tostring(target)]['settings']['leave']
  if group_leave_lock == 'yes' then
    return 'قفل بازگشت به گروه از قبل قفل بود!'
  else
    data[tostring(target)]['settings']['leave'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل بازگشت به گروه فعال شد!'
  end
end

local function unlock_group_leave(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_leave_lock = data[tostring(target)]['settings']['leave']
  if group_leave_lock == 'no' then
    return 'قفل بازگشت به گروه غیرفعال بود!'
  else
    data[tostring(target)]['settings']['leave'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل بازگشت به گروه غیرفعال شد!'
  end
end

local function lock_group_operator(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_operator_lock = data[tostring(target)]['settings']['operator']
  if group_operator_lock == 'yes' then
    return 'قفل اپراتور فعال بود‌'
  else
    data[tostring(target)]['settings']['operator'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل اپراتور فعال شد'
  end
end

local function unlock_group_operator(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_operator_lock = data[tostring(target)]['settings']['operator']
  if group_operator_lock == 'no' then
    return 'قفل اپراتور غیرفعال بود!'
  else
    data[tostring(target)]['settings']['operator'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل اپراتور غیرفعال شد!'
  end
end

local function lock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_reply_lock = data[tostring(target)]['settings']['reply']
  if group_reply_lock == 'yes' then
    return 'قفل ریپلی فعال بود!'
  else
    data[tostring(target)]['settings']['reply'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ریپلی فعال شد!'
  end
end

local function unlock_group_reply(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_reply_lock = data[tostring(target)]['settings']['reply']
  if group_reply_lock == 'no' then
    return 'قفل ریپلی غیرفعال بود'
  else
    data[tostring(target)]['settings']['reply'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ریپلی غیرفعال شد!'
  end
end

local function lock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['username']
  if group_username_lock == 'yes' then
    return 'قفل یوزرنیم فعال بود'
  else
    data[tostring(target)]['settings']['username'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل یوزر نیم فعال شد'
  end
end

local function unlock_group_username(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_username_lock = data[tostring(target)]['settings']['username']
  if group_username_lock == 'no' then
    return 'قفل یوزرنیم غیرفعال بود'
  else
    data[tostring(target)]['settings']['username'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل یوزرنیم غیرفعال شد'
  end
end

local function lock_group_media(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_media_lock = data[tostring(target)]['settings']['media']
  if group_media_lock == 'yes' then
    return 'قفل رسانه از قبل فعال بود!'
  else
    data[tostring(target)]['settings']['media'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل رسانه فعال شد'
  end
end

local function unlock_group_media(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_media_lock = data[tostring(target)]['settings']['media']
  if group_media_lock == 'no' then
    return 'قفل رسانه غیرفعال بود'
  else
    data[tostring(target)]['settings']['media'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل رسانه غیرفعال شد!'
  end
end

local function lock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['fosh']
  if group_fosh_lock == 'yes' then
    return 'قفل فخش فعال بود!'
  else
    data[tostring(target)]['settings']['fosh'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل فحش فعال شد!'
  end
end

local function unlock_group_fosh(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fosh_lock = data[tostring(target)]['settings']['fosh']
  if group_fosh_lock == 'no' then
    return 'قفل فحش غیرفعال بود!'
  else
    data[tostring(target)]['settings']['fosh'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل فحش غیرفعال شد!'
  end
end

local function lock_group_join(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_join_lock = data[tostring(target)]['settings']['join']
  if group_join_lock == 'yes' then
    return 'قفل ورود به گروه فعال بود!'
  else
    data[tostring(target)]['settings']['join'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ورود به گروه فعال شد!'
  end
end

local function unlock_group_join(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_join_lock = data[tostring(target)]['settings']['join']
  if group_join_lock == 'no' then
    return 'قفل ورود به گروه غیرفعال بود!'
  else
    data[tostring(target)]['settings']['join'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ورود به گروه غیر فعال شد!'
  end
end

local function lock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'yes' then
    return 'قفل فروارد فعال بود!'
  else
    data[tostring(target)]['settings']['lock_fwd'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل فروارد فعال شد!'
  end
end

local function unlock_group_fwd(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_fwd_lock = data[tostring(target)]['settings']['lock_fwd']
  if group_fwd_lock == 'no' then
    return 'قفل فروارد غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_fwd'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل فروارد غیرفعال شد!'
  end
end

local function lock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['english']
  if group_english_lock == 'yes' then
    return 'قفل زبان انگلیسی فعال بود!'
  else
    data[tostring(target)]['settings']['english'] = 'yes'
    save_data(_config.moderation.data, data)
    return  'انگلیسی فعال شد!'
  end
end

local function unlock_group_english(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_english_lock = data[tostring(target)]['settings']['english']
  if group_english_lock == 'no' then
    return 'قفل زبان انگلیسی غیرفعال بود!'
  else
    data[tostring(target)]['settings']['english'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل زبان انگلیسی غیرفعال شد!'
  end
end

local function lock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['emoji']
  if group_emoji_lock == 'yes' then
    return 'قفل ارسال شکلک فعال بود'
  else
    data[tostring(target)]['settings']['emoji'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال شکلک فعال شد!'
  end
end

local function unlock_group_emoji(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_emoji_lock = data[tostring(target)]['settings']['emoji']
  if group_emoji_lock == 'no' then
    return 'قفل ارسال شکلک غیرفعال بود'
  else
    data[tostring(target)]['settings']['emoji'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال شکلک غیرفعال شد!'
  end
end

local function lock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['tag']
  if group_tag_lock == 'yes' then
    return 'قفل ارسال تگ فعال بود!'
  else
    data[tostring(target)]['settings']['tag'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال تگ فعال شد!'
  end
end

local function unlock_group_tag(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tag_lock = data[tostring(target)]['settings']['tag']
  if group_tag_lock == 'no' then
    return 'قفل ارسال تگ غیرفعال بود!'
  else
    data[tostring(target)]['settings']['tag'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال تگ غیرفعال شد!'
  end
end

local function unlock_group_all(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_all_lock = data[tostring(target)]['settings']['all']
  if group_all_lock == 'no' then
    return 'تنظیمات کلی غیرفعال بود'
  else
    data[tostring(target)]['settings']['all'] = 'no'
    save_data(_config.moderation.data, data)
    return 'تنظیمات کلی غیرفعال شد'
  end
end

local function lock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  if not is_owner(msg) then
    return "فقط مدیران"
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'yes' then
    return 'قفل اسپم فعال بود!'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل اسپم فعال شد!'
  end
end

local function unlock_group_spam(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_spam_lock = data[tostring(target)]['settings']['lock_spam']
  if group_spam_lock == 'no' then
    return 'قفل اسپم غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_spam'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل اسپم غیرفعال شد؟؟!'
  end
end

local function lock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'yes' then
    return 'قفل فلود فعال بود!'
  else
    data[tostring(target)]['settings']['flood'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل فلود فعآل شد!'
  end
end

local function unlock_group_flood(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_flood_lock = data[tostring(target)]['settings']['flood']
  if group_flood_lock == 'no' then
    return 'قفل فلود غیرفعال بود'
  else
    data[tostring(target)]['settings']['flood'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل فلود غیرفعال شد!'
  end
end

local function lock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'yes' then
    return 'قفل زبان پارسی/عربی فعال بود!'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل زبان پارسی/عربی فعال شد!'
  end
end

local function unlock_group_arabic(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_arabic_lock = data[tostring(target)]['settings']['lock_arabic']
  if group_arabic_lock == 'no' then
    return 'قفل زبان پارسی/عربی غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_arabic'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل زبان پارسی/عربی غیرفعال شد!'
  end
end


local function lock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'yes' then
    return 'قفل افزودن عضو فعال بود!'
  else
    data[tostring(target)]['settings']['lock_member'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'قفل افزودن عضو فعال شد!'
end

local function unlock_group_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_member_lock = data[tostring(target)]['settings']['lock_member']
  if group_member_lock == 'no' then
    return 'قفل افزودن عضو غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_member'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل افزودن عضو غیرفعال شد!'
  end
end

local function lock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'yes' then
    return 'قفل لینک ار تی ال فعال بود'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل لینک ار تی ال فعال شد!'
  end
end

local function unlock_group_rtl(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_rtl']
  if group_rtl_lock == 'no' then
    return 'قفل لینک ار ای ال غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_rtl'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل لینک ار تی ال غیرفعال شد!'
  end
end

local function lock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'yes' then
    return 'قفل پیام ورود خروج فعال بود!'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل پیام خروج ورود فعال شد!'
  end
end

local function unlock_group_tgservice(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_tgservice_lock = data[tostring(target)]['settings']['lock_tgservice']
  if group_tgservice_lock == 'no' then
    return 'قفل پیام ورود خروج غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_tgservice'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل پیام ورود خروج غیرفعال شد!'
  end
end

local function lock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'yes' then
    return 'قفل ارسال استیکر فعال بود!'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال استیکر فعال شد!'
  end
end

local function unlock_group_sticker(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_sticker_lock = data[tostring(target)]['settings']['lock_sticker']
  if group_sticker_lock == 'no' then
    return 'قفل ارسال استیکر غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_sticker'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال استیکر ڠیرفعال شد!'
  end
end

local function lock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'yes' then
    return 'قفل ورود ربات فعال بود!'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ورود ربات فعال شد!'
  end
end

local function unlock_group_bots(msg, data, target)
  if not is_momod(msg) then
    return 
  end
  local group_bots_lock = data[tostring(target)]['settings']['lock_bots']
  if group_bots_lock == 'no' then
    return 'قفل ورود ربات غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_bots'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ورود ربات غیرفعال شد!'
  end
end

local function lock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_inline_lock = data[tostring(target)]['settings']['inline']
  if group_inline_lock == 'yes' then
    return 'قفل ارسال پیام درون خطی فعال بود!'
  else
    data[tostring(target)]['settings']['inline'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال پیام درون خطی فعال شد!'
  end
end

local function unlock_group_inline(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_inline_lock = data[tostring(target)]['settings']['inline']
  if group_inline_lock == 'no' then
    return 'قفل ارسال پیام درون خطی غیرفعال بود!'
  else
    data[tostring(target)]['settings']['inline'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال پیام درون خطی غیرفعال شد!'
  end
end

local function lock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_rtl_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'yes' then
    return 'قفل ارسال مخاطب فعال بود!'
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال مخاطب فعال شد!'
  end
end

local function unlock_group_contacts(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_contacts_lock = data[tostring(target)]['settings']['lock_contacts']
  if group_contacts_lock == 'no' then
    return 'قفل ارسال مخاطب غیرفعال بود!'
  else
    data[tostring(target)]['settings']['lock_contacts'] = 'no'
    save_data(_config.moderation.data, data)
    return 'قفل ارسال مخاطب غیرفعال شد!'
  end
end

local function enable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'yes' then
    return 'تنظیمات سخت گیرانه فعال بود!'
  else
    data[tostring(target)]['settings']['strict'] = 'yes'
    save_data(_config.moderation.data, data)
    return 'تنظیمات سخت گیرانه فعال شد!'
  end
end

local function disable_strict_rules(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_strict_lock = data[tostring(target)]['settings']['strict']
  if group_strict_lock == 'no' then
    return 'تنظیمات سخت گیرانه غیرفعال بود!'
  else
    data[tostring(target)]['settings']['strict'] = 'no'
    save_data(_config.moderation.data, data)
    return 'تنظیمات سخت گیرانه غیرفعال شد!'
  end
end
--End supergroup locks

--'Set supergroup rules' function
local function set_rulesmod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local data_cat = 'قوانین'
  data[tostring(target)][data_cat] = rules
  save_data(_config.moderation.data, data)
  return 'قوانین سوپرگپ ثبت نشده است!'
end

--'Get supergroup rules' function
local function get_rules(msg, data)
  local data_cat = 'قوانین'
  if not data[tostring(msg.to.id)][data_cat] then
    return 'قوانین موجود نیست'
  end
  local rules = data[tostring(msg.to.id)][data_cat]
  local group_name = data[tostring(msg.to.id)]['settings']['set_name']
  local rules = group_name..' قوانین:\n\n'..rules:gsub("/n", " ")
  return rules
end

--Set supergroup to public or not public function
local function set_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return "فقط مدیران"
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'yes' then
    return 'حالت عمومی فعال بود'
  else
    data[tostring(target)]['settings']['public'] = 'yes'
    save_data(_config.moderation.data, data)
  end
  return 'حالت عمومی فعال شد'
end

local function unset_public_membermod(msg, data, target)
  if not is_momod(msg) then
    return
  end
  local group_public_lock = data[tostring(target)]['settings']['public']
  local long_id = data[tostring(target)]['long_id']
  if not long_id then
	data[tostring(target)]['long_id'] = msg.to.peer_id
	save_data(_config.moderation.data, data)
  end
  if group_public_lock == 'no' then
    return 'حالت عمومی غیرفعال بود'
  else
    data[tostring(target)]['settings']['public'] = 'no'
	data[tostring(target)]['long_id'] = msg.to.long_id
    save_data(_config.moderation.data, data)
    return 'حالت عمومی غیرفعال شد'
  end
end

--Show supergroup settings; function
function show_supergroup_settingsmod(msg, target)
 	if not is_momod(msg) then
    	return
  	end
	local data = load_data(_config.moderation.data)
    if data[tostring(target)] then
     	if data[tostring(target)]['settings']['flood_msg_max'] then
        	NUM_MSG_MAX = tonumber(data[tostring(target)]['settings']['flood_msg_max'])
        	print('custom'..NUM_MSG_MAX)
      	else
        	NUM_MSG_MAX = 6
      	end
    end
    local bots_protection = "Yes"
    if data[tostring(target)]['settings']['lock_bots'] then
    	bots_protection = data[tostring(target)]['settings']['lock_bots']
   	end
   if data[tostring(target)]['settings'] then
  if not data[tostring(target)]['settings']['inline'] then
   data[tostring(target)]['settings']['inline'] = 'no'
  end
 end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['public'] then
			data[tostring(target)]['settings']['public'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_rtl'] then
			data[tostring(target)]['settings']['lock_rtl'] = 'no'
		end
        end
      if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_tgservice'] then
			data[tostring(target)]['settings']['lock_tgservice'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['tag'] then
			data[tostring(target)]['settings']['tag'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['emoji'] then
			data[tostring(target)]['settings']['emoji'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['english'] then
			data[tostring(target)]['settings']['english'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_fwd'] then
			data[tostring(target)]['settings']['lock_fwd'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['reply'] then
			data[tostring(target)]['settings']['reply'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['join'] then
			data[tostring(target)]['settings']['join'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['fosh'] then
			data[tostring(target)]['settings']['fosh'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['username'] then
			data[tostring(target)]['settings']['username'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_photo'] then
			data[tostring(target)]['settings']['lock_photo'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
  if not data[tostring(target)]['settings']['lock_gif'] then
   data[tostring(target)]['settings']['lock_gif'] = 'no'
  end
 end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['media'] then
			data[tostring(target)]['settings']['media'] = 'no'
		end
	end
	  if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['leave'] then
			data[tostring(target)]['settings']['leave'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['lock_member'] then
			data[tostring(target)]['settings']['lock_member'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['all'] then
			data[tostring(target)]['settings']['all'] = 'no'
		end
	end
	if data[tostring(target)]['settings'] then
		if not data[tostring(target)]['settings']['operator'] then
			data[tostring(target)]['settings']['operator'] = 'no'
		end
	end
  local gp_type = data[tostring(msg.to.id)]['group_type']
 
  local settings = data[tostring(target)]['settings']
  local text = "<code>تنظیمات گروه</code>\n><code>قفل لینک  ~ </code><code>"..settings.lock_link.."</code>\n<code>>قفل مخاطب ~ </code><code>"..settings.lock_contacts.."</code>\n<code>>قفل فلود </code>~ <code>"..settings.flood.."</code>\n<code>>حساسیت اسپم </code>~ 200|<code>"..NUM_MSG_MAX.."</code>\n<code>>قفل اسپم ~</code> <code>"..settings.lock_spam.."</code>\n><code>قفل عربی/پارسی ~ </code><code>"..settings.lock_arabic.."</code>\n><code>قفل افزودن عضو ~ </code><code>"..settings.lock_member.."</code>\n<code>>قفل ار تی ال ~</code> <code>"..settings.lock_rtl.."</code>\n<code>>قفل پیام  ورود خروج ~ </code><code>"..settings.lock_tgservice.."</code>\n<code>>قفل ارسال استیکر ~ </code><code>"..settings.lock_sticker.."</code>\n><code>قفل ارسال پیام درون خطی ~ </code><code>"..settings.inline.."</code>\n><code>قفل تگ(#) ~</code> <code>"..settings.tag.."</code>\n><code>قفل شکلک ~ </code><code>"..settings.emoji.."</code>\n<code>>قفل انگلیسی ~ </code><code>"..settings.english.."</code>\n<code>>قفل فروارد ~ </code><code>"..settings.lock_fwd.."</code>\n<code>>قفل ریپلی ~</code> <code>"..settings.reply.."</code>\n<code>>قفل دعوت با لینک~ </code><code>"..settings.join.."</code>\n><code>قفل یوزرنیم(@) ~ </code><code>"..settings.username.."</code>\n<code>>قفل رسانه ~ </code><code>"..settings.media.."</code>\n<code>>قفل فحش ~ </code><code>"..settings.fosh.."</code>\n<code>>قفل بازگشت ~ </code><code>"..settings.leave.."</code>\n><code>قفل ورود ربات ~ </code><code>"..bots_protection.."</code>\n<code>>قفل اپراتور ~ </code><code>"..settings.operator.."</code>\n___________تیم کرنر___________\n><code>قفل همه ~ </code><code>"..settings.all.."</code>\n<code>>عمومی ~ </code><code>"..settings.public.."</code>\n><code>تنظیمات سخت گیرانه  ~</code> <code>"..settings.strict.."</code>\n<i>CerNerTeam</i>\n <code>channel Team</code>  @CerNerCH"
  return text
end
local function promote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' مجددا مدیر شد!')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
end

local function demote_admin(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' مدیر نیست.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
end

local function promote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  local member_tag_username = string.gsub(member_username, '@', '(at)')
  if not data[group] then
    return send_large_msg(receiver, '<code>سوپر گپ اضافه نشده !</code>')
  end
  if data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_username..' مجدا مدیر شد!')
  end
  data[group]['moderators'][tostring(user_id)] = member_tag_username
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' مدیر شد!')
end

local function demote2(receiver, member_username, user_id)
  local data = load_data(_config.moderation.data)
  local group = string.gsub(receiver, 'channel#id', '')
  if not data[group] then
    return send_large_msg(receiver, 'گروه اضافه نشده!')
  end
  if not data[group]['moderators'][tostring(user_id)] then
    return send_large_msg(receiver, member_tag_username..' مدیر نبوده.')
  end
  data[group]['moderators'][tostring(user_id)] = nil
  save_data(_config.moderation.data, data)
  send_large_msg(receiver, member_username..' عزل شد!.')
end

local function modlist(msg)
  local data = load_data(_config.moderation.data)
  local groups = "groups"
  if not data[tostring(groups)][tostring(msg.to.id)] then
    return '<‌code>سوپر گپ اضافه نشده</code>'
  end
  -- determine if table is empty
  if next(data[tostring(msg.to.id)]['moderators']) == nil then
    return '<code>هیچ کمک مدیری ثبت نشده</code>'
  end
  local i = 1
  local message = '\n<cide>لیست کمک مدیران</‌code> ' .. string.gsub(msg.to.print_name, '_', ' ') .. ':\n'
  for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
    message = message ..i..' - '..v..' [' ..k.. '] \n'
    i = i + 1
  end
  return message
end

-- Start by reply actions
function get_message_callback(extra, success, result)
	local get_cmd = extra.get_cmd
	local msg = extra.msg
	local data = load_data(_config.moderation.data)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
    if get_cmd == "ایدی" and not result.action then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for: ["..result.from.peer_id.."]")
		id1 = send_large_msg(channel, result.from.peer_id)
	elseif get_cmd == 'ایدی' and result.action then
		local action = result.action.type
		if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
			if result.action.user then
				user_id = result.action.user.peer_id
			else
				user_id = result.peer_id
			end
			local channel = 'channel#id'..result.to.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id by service msg for: ["..user_id.."]")
			id1 = send_large_msg(channel, user_id)
		end
    elseif get_cmd == "idfrom" then
		local channel = 'channel#id'..result.to.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] obtained id for msg fwd from: ["..result.fwd_from.peer_id.."]")
		id2 = send_large_msg(channel, result.fwd_from.peer_id)
    elseif get_cmd == 'channel_block' and not result.action then
		local member_id = result.from.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		--savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply")
		kick_user(member_id, channel_id)
	elseif get_cmd == 'channel_block' and result.action and result.action.type == 'chat_add_user' then
		local user_id = result.action.user.peer_id
		local channel_id = result.to.peer_id
    if member_id == msg.from.id then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
    if is_momod2(member_id, channel_id) and not is_admin2(msg.from.id) then
			   return send_large_msg("channel#id"..channel_id, "You can't kick mods/owner/admins")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "You can't kick other admins")
    end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..user_id.."] by reply to sev. msg.")
		kick_user(user_id, channel_id)
	elseif get_cmd == "پاک" then
		delete_msg(result.id, ok_cb, false)
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] deleted a message by reply")
	elseif get_cmd == "ادمین" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		channel_set_admin(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." <code>ادمین شد</code>"
		else
			text = "[ "..user_id.." ]ادمین شد"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..user_id.."] as admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "تنزل ادمین" then
		local user_id = result.from.peer_id
		local channel_id = "channel#id"..result.to.peer_id
		if is_admin2(result.from.peer_id) then
			return send_large_msg(channel_id, "شما توانایی انجام این کار را ندارید!")
		end
		channel_demote(channel_id, "user#id"..user_id, ok_cb, false)
		if result.from.username then
			text = "@"..result.from.username.." <code>تنزل یافت</code>"
		else
			text = "[ "..user_id.." ] <code>تنزل یافت</code>"
		end
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted: ["..user_id.."] from admin by reply")
		send_large_msg(channel_id, text)
	elseif get_cmd == "صاحب" then
		local group_owner = data[tostring(result.to.peer_id)]['set_owner']
		if group_owner then
		local channel_id = 'channel#id'..result.to.peer_id
			if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
				local user = "user#id"..group_owner
				channel_demote(channel_id, user, ok_cb, false)
			end
			local user_id = "user#id"..result.from.peer_id
			channel_set_admin(channel_id, user_id, ok_cb, false)
			data[tostring(result.to.peer_id)]['set_owner'] = tostring(result.from.peer_id)
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set: ["..result.from.peer_id.."] as owner by reply")
			if result.from.username then
				text = "@"..result.from.username.." <code>[ "..result.from.peer_id.." ] صاحب گروه شد</code>"
			else
				text = "<code>CerNer Team</code>[ "..result.from.peer_id.." ] <code>صاحب گروه شد</code>"
			end
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "مدیر" then
		local receiver = result.to.peer_id
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
		if result.from.username then
			member_username = '@'.. result.from.username
		end
		local member_id = result.from.peer_id
		if result.to.peer_type == 'channel' then
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted mod: @"..member_username.."["..result.from.peer_id.."] by reply")
		promote2("channel#id"..result.to.peer_id, member_username, member_id)
	    --channel_set_mod(channel_id, user, ok_cb, false)
		end
	elseif get_cmd == "تنزل مدیر" then
		local full_name = (result.from.first_name or '')..' '..(result.from.last_name or '')
		local member_name = full_name:gsub("‮", "")
		local member_username = member_name:gsub("_", " ")
    if result.from.username then
		member_username = '@'.. result.from.username
    end
		local member_id = result.from.peer_id
		--local user = "user#id"..result.peer_id
		savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted mod: @"..member_username.."["..user_id.."] by reply")
		demote2("channel#id"..result.to.peer_id, member_username, member_id)
		--channel_demote(channel_id, user, ok_cb, false)
	elseif get_cmd == 'mute_user' then
		if result.service then
			local action = result.action.type
			if action == 'chat_add_user' or action == 'chat_del_user' or action == 'chat_rename' or action == 'chat_change_photo' then
				if result.action.user then
					user_id = result.action.user.peer_id
				end
			end
			if action == 'chat_add_user_link' then
				if result.from then
					user_id = result.from.peer_id
				end
			end
		else
			user_id = result.from.peer_id
		end
		local receiver = extra.receiver
		local chat_id = msg.to.id
		print(user_id)
		print(chat_id)
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, "["..user_id.."] کاربر از لیست صامت شدگان حذف شد")
		elseif is_admin1(msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] کاربر به لیست صامت شدگان اضافه شد!")
		end
	end
end
-- End by reply actions

--By ID actions
local function cb_user_info(extra, success, result)
	local receiver = extra.receiver
	local user_id = result.peer_id
	local get_cmd = extra.get_cmd
	local data = load_data(_config.moderation.data)
      --[[if get_cmd == "ادمین" then
	 	local user_id = "user#id"..result.peer_id
		channel_set_admin(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." کاربر ادمین شد!"
		else
			text = "[ "..result.peer_id.." ] کاربر ادمین شد!"
		end
			send_large_msg(receiver, text)]]
	if get_cmd == "تنزل ادمین" then
		if is_admin2(result.peer_id) then
			return send_large_msg(receiver, "شما توانایی انجام این کار را ندارید")
		end
		local user_id = "user#id"..result.peer_id
		channel_demote(receiver, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." کاربر تنزل یافت"
			send_large_msg(receiver, text)
		else
			text = "[ "..result.peer_id.." ] کاربر تنزل مقام یافت"
			send_large_msg(receiver, text)
		end
	elseif get_cmd == "مدیر" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		promote2(receiver, member_username, user_id)
	elseif get_cmd == "تنزل مدیر" then
		if result.username then
			member_username = "@"..result.username
		else
			member_username = string.gsub(result.print_name, '_', ' ')
		end
		demote2(receiver, member_username, user_id)
	end
end

-- Begin resolve username actions
local function callbackres(extra, success, result)
  local member_id = result.peer_id
  local member_username = "@"..result.username
  local get_cmd = extra.get_cmd
	if get_cmd == "مشخصات" then
		local user = result.peer_id
		local name = string.gsub(result.print_name, "_", " ")
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user..'\n'..name)
		return user
	elseif get_cmd == "ایدی" then
		local user = result.peer_id
		local channel = 'channel#id'..extra.channelid
		send_large_msg(channel, user)
		return user
  elseif get_cmd == "دعوت" then
    local receiver = extra.channel
    local user_id = "user#id"..result.peer_id
    channel_invite(receiver, user_id, ok_cb, false)
  	--[[elseif get_cmd == "channel_block" then
		local user_id = result.peer_id
		local channel_id = extra.channelid
    local sender = extra.sender
    if member_id == sender then
      return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
    end
		if is_momod2(member_id, channel_id) and not is_admin2(sender) then
			   return send_large_msg("channel#id"..channel_id, "شما نمیتوانید ")
    end
    if is_admin2(member_id) then
         return send_large_msg("channel#id"..channel_id, "شما نمیتوانید")
    end
		kick_user(user_id, channel_id)
	elseif get_cmd == "ادمین" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		channel_set_admin(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." ادمین شد!"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." ادمین شد"
			send_large_msg(channel_id, text)
		end
	elseif get_cmd == "صاحب" then
		local receiver = extra.channel
		local channel = string.gsub(receiver, 'channel#id', '')
		local from_id = extra.from_id
		local group_owner = data[tostring(channel)]['set_owner']
		if group_owner then
			local user = "user#id"..group_owner
			if not is_admin2(group_owner) and not is_support(group_owner) then
				channel_demote(receiver, user, ok_cb, false)
			end
			local user_id = "user#id"..result.peer_id
			channel_set_admin(receiver, user_id, ok_cb, false)
			data[tostring(channel)]['set_owner'] = tostring(result.peer_id)
			save_data(_config.moderation.data, data)
			savelog(channel, name_log.." ["..from_id.."] set ["..result.peer_id.."] as owner by username")
		if result.username then
			text = member_username.." [ "..result.peer_id.." ] صاحب گروه شد"
		else
			text = "[ "..result.peer_id.." ] صاحب گروه شد"
		end
		send_large_msg(receiver, text)
  end]]
	elseif get_cmd == "مدیر" then
		local receiver = extra.channel
		local user_id = result.peer_id
		--local user = "user#id"..result.peer_id
		promote2(receiver, member_username, user_id)
		--channel_set_mod(receiver, user, ok_cb, false)
	elseif get_cmd == "تنزل مدیر" then
		local receiver = extra.channel
		local user_id = result.peer_id
		local user = "user#id"..result.peer_id
		demote2(receiver, member_username, user_id)
	elseif get_cmd == "تنزل ادمین" then
		local user_id = "user#id"..result.peer_id
		local channel_id = extra.channel
		if is_admin2(result.peer_id) then
			return send_large_msg(channel_id, "شما نمی توانید")
		end
		channel_demote(channel_id, user_id, ok_cb, false)
		if result.username then
			text = "@"..result.username.." کاربر تنزل یافت"
			send_large_msg(channel_id, text)
		else
			text = "@"..result.peer_id.." کاربر تنزل یافت"
			send_large_msg(channel_id, text)
		end
		local receiver = extra.channel
		local user_id = result.peer_id
		demote_admin(receiver, member_username, user_id)
	elseif get_cmd == 'mute_user' then
		local user_id = result.peer_id
		local receiver = extra.receiver
		local chat_id = string.gsub(receiver, 'channel#id', '')
		if is_muted_user(chat_id, user_id) then
			unmute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] کاربر از لیست صامت شدگان حذف شد")
		elseif is_owner(extra.msg) then
			mute_user(chat_id, user_id)
			send_large_msg(receiver, " ["..user_id.."] کاربر به لیست صامت شدگان اضافه شد")
		end
	end
end
--End resolve username actions

--Begin non-channel_invite username actions
local function in_channel_cb(cb_extra, success, result)
  local get_cmd = cb_extra.get_cmd
  local receiver = cb_extra.receiver
  local msg = cb_extra.msg
  local data = load_data(_config.moderation.data)
  local print_name = user_print_name(cb_extra.msg.from):gsub("‮", "")
  local name_log = print_name:gsub("_", " ")
  local member = cb_extra.username
  local memberid = cb_extra.user_id
  if member then
    text = 'کاربر @'..member..' در گروه نیست.'
  else
    text = 'کاربر['..memberid..'] در گروه نیست'
  end
if get_cmd == "channel_block" then
  for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
     local user_id = v.peer_id
     local channel_id = cb_extra.msg.to.id
     local sender = cb_extra.msg.from.id
      if user_id == sender then
        return send_large_msg("channel#id"..channel_id, "Leave using kickme command")
      end
      if is_momod2(user_id, channel_id) and not is_admin2(sender) then
        return send_large_msg("channel#id"..channel_id, "شما نمیتوانید ( سودو/ادمین/مدیر) اخراج کنید....❗️")
      end
      if is_admin2(user_id) then
        return send_large_msg("channel#id"..channel_id, "شما نمیتوانید ( سودو/مدیر) اخراج کنید....❗️")
      end
      if v.username then
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..v.username.." ["..v.peer_id.."]")
      else
        text = ""
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: ["..v.peer_id.."]")
      end
      kick_user(user_id, channel_id)
      return
    end
  end
elseif get_cmd == "ادمین" then
   for k,v in pairs(result) do
    vusername = v.username
    vpeer_id = tostring(v.peer_id)
    if vusername == member or vpeer_id == memberid then
      local user_id = "user#id"..v.peer_id
      local channel_id = "channel#id"..cb_extra.msg.to.id
      channel_set_admin(channel_id, user_id, ok_cb, false)
      if v.username then
        text = "@"..v.username.." ["..v.peer_id.."] کاربر ادمین شد"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..v.username.." ["..v.peer_id.."]")
      else
        text = "["..v.peer_id.."] کاربر ادمین شد"
        savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin "..v.peer_id)
      end
	  if v.username then
		member_username = "@"..v.username
	  else
		member_username = string.gsub(v.print_name, '_', ' ')
	  end
		local receiver = channel_id
		local user_id = v.peer_id
		promote_admin(receiver, member_username, user_id)

    end
    send_large_msg(channel_id, text)
    return
 end
 elseif get_cmd == 'صاحب' then
	for k,v in pairs(result) do
		vusername = v.username
		vpeer_id = tostring(v.peer_id)
		if vusername == member or vpeer_id == memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
					local user_id = "user#id"..v.peer_id
					channel_set_admin(receiver, user_id, ok_cb, false)
					data[tostring(channel)]['set_owner'] = tostring(v.peer_id)
					save_data(_config.moderation.data, data)
					savelog(channel, name_log.."["..from_id.."] set ["..v.peer_id.."] as owner by username")
				if result.username then
					text = member_username.." ["..v.peer_id.."] added as owner"
				else
					text = "["..v.peer_id.."] <code>added as owner</code>"
				end
			end
		elseif memberid and vusername ~= member and vpeer_id ~= memberid then
			local channel = string.gsub(receiver, 'channel#id', '')
			local from_id = cb_extra.msg.from.id
			local group_owner = data[tostring(channel)]['set_owner']
			if group_owner then
				if not is_admin2(tonumber(group_owner)) and not is_support(tonumber(group_owner)) then
					local user = "user#id"..group_owner
					channel_demote(receiver, user, ok_cb, false)
				end
				data[tostring(channel)]['set_owner'] = tostring(memberid)
				save_data(_config.moderation.data, data)
				savelog(channel, name_log.."["..from_id.."] set ["..memberid.."] as owner by username")
				text = "["..memberid.."] <code> added as owner</code>"
			end
		end
	end
 end
send_large_msg(receiver, text)
end
--End non-channel_invite username actions

--'Set supergroup photo' function
local function set_supergroup_photo(msg, success, result)
  local data = load_data(_config.moderation.data)
  if not data[tostring(msg.to.id)] then
      return
  end
  local receiver = get_receiver(msg)
  if success then
    local file = 'data/photos/channel_photo_'..msg.to.id..'.jpg'
    print('File downloaded to:', result)
    os.rename(result, file)
    print('File moved to:', file)
    channel_set_photo(receiver, file, ok_cb, false)
    data[tostring(msg.to.id)]['settings']['set_photo'] = file
    save_data(_config.moderation.data, data)
    send_large_msg(receiver, 'Photo saved!', ok_cb, false)
  else
    print('Error downloading: '..msg.id)
    send_large_msg(receiver, 'Failed, please try again!', ok_cb, false)
  end
end

--Run function
local function run(msg, matches)
	if msg.to.type == 'chat' then
		if matches[1] == 'ارتقا' then
			if not is_admin1(msg) then
				return
			end
			local receiver = get_receiver(msg)
			chat_upgrade(receiver, ok_cb, false)
		end
	elseif msg.to.type == 'channel'then
		if matches[1] == 'ارتقا' then
			if not is_admin1(msg) then
				return
			end
			return "Already a SuperGroup"
		end
	end
	if msg.to.type == 'channel' then
	local support_id = msg.from.id
	local receiver = get_receiver(msg)
	local print_name = user_print_name(msg.from):gsub("‮", "")
	local name_log = print_name:gsub("_", " ")
	local data = load_data(_config.moderation.data)
		if matches[1] == افزودن and not matches[2] then
			if not is_admin1(msg) and not is_support(support_id) then
				return
			end
			if is_super_group(msg) then
				return reply_msg(msg.id, 'SuperGroup is already added.', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") added")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] added SuperGroup")
			superadd(msg)
			set_mutes(msg.to.id)
			channel_set_admin(receiver, 'user#id'..msg.from.id, ok_cb, false)
		end

		if matches[1] == 'حذف شو' and is_admin1(msg) and not matches[2] then
			if not is_super_group(msg) then
				return reply_msg(msg.id, 'SuperGroup is not added.', ok_cb, false)
			end
			print("SuperGroup "..msg.to.print_name.."("..msg.to.id..") removed")
			superrem(msg)
			rem_mutes(msg.to.id)
		end

		if not data[tostring(msg.to.id)] then
			return
		end
		if matches[1] == "اطلاعات گروه" then
			if not is_owner(msg) then
				return
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup info")
			channel_info(receiver, callback_info, {receiver = receiver, msg = msg})
		end

		if matches[1] == "ادمین ها" then
			if not is_owner(msg) and not is_support(msg.from.id) then
				return
			end
			member_type = 'Admins'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup Admins list")
			admins = channel_get_admins(receiver,callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "صاحب گروه" then
			local group_owner = data[tostring(msg.to.id)]['set_owner']
			if not group_owner then
				return "no owner,ask admins in support groups to set owner for your SuperGroup"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] used /owner")
			return "<i>SuperGroup owner is</i><code>["..group_owner..']</code>'
		end

		if matches[1] == "مدیران" then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group modlist")
			return modlist(msg)
			-- channel_get_admins(receiver,callback, {receiver = receiver})
		end

		if matches[1] == "ربات ها" and is_momod(msg) then
			member_type = 'Bots'
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup bots list")
			channel_get_bots(receiver, callback, {receiver = receiver, msg = msg, member_type = member_type})
		end

		if matches[1] == "who" and not matches[2] and is_momod(msg) then
			local user_id = msg.from.peer_id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup users list")
			channel_get_users(receiver, callback_who, {receiver = receiver})
		end

		if matches[1] == "kicked" and is_momod(msg) then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested Kicked users list")
			channel_get_kicked(receiver, callback_kicked, {receiver = receiver})
		end

		if matches[1] == 'پاک' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'del',
					msg = msg
				}
				delete_msg(msg.id, ok_cb, false)
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			end
		end

		if matches[1] == 'بلوک or matches[1] == 'اخراج' and is_momod(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'channel_block',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'block' or matches[1] == 'kick' and string.match(matches[2], '^%d+$') then
		        --[[local user_id = matches[2]
				local channel_id = msg.to.id
				if is_momod2(user_id, channel_id) and not is_admin2(user_id) then
					return send_large_msg(receiver, "You can't kick mods/owner/admins")
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: [ user#id"..user_id.." ]")
				kick_user(user_id, channel_id)]]
				local	get_cmd = 'channel_block'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif msg.text:match("@[%a%d]") then
			--[[local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'channel_block',
					sender = msg.from.id
				}
			    local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] kicked: @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
			local get_cmd = 'channel_block'
			local msg = msg
			local username = matches[2]
			local username = string.gsub(matches[2], '@', '')
			channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'ایدی' then
			if type(msg.reply_id) ~= "nil" and is_momod(msg) and not matches[2] then
				local cbreply_extra = {
					get_cmd = 'ایدی',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif type(msg.reply_id) ~= "nil" and matches[2] == "from" and is_momod(msg) then
				local cbreply_extra = {
					get_cmd = 'idfrom',
					msg = msg
				}
				get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif msg.text:match("@[%a%d]") then
				local cbres_extra = {
					channelid = msg.to.id,
					get_cmd = 'ایدی'
				}
				local username = matches[2]
				local username = username:gsub("@","")
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested ID for: @"..username)
				resolve_username(username,  callbackres, cbres_extra)
			else
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup ID")
				return "<code>CerNer Team</code>\n<code>#ایدی شما: </code>"..msg.from.id.."<code>\n#نام گروه:</code>" ..string.gsub(msg.to.print_name, "_", " ").. "<code>\n#ایدی گروه: </code>"..msg.to.id
			end
		end

		if matches[1] == 'خروج' then
			if msg.to.type == 'channel' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] left via kickme")
				channel_kick("channel#id"..msg.to.id, "user#id"..msg.from.id, ok_cb, false)
			end
		end

		if matches[1] == 'ساخت لینک' and is_momod(msg)then
			local function callback_link (extra , success, result)
			local receiver = get_receiver(msg)
				if success == 0 then
					send_large_msg(receiver, 'ربات سازنده گروه نیست! لطفا از دستور تنظیم لینک استفاده کنید!')
					data[tostring(msg.to.id)]['settings']['set_link'] = nil
					save_data(_config.moderation.data, data)
				else
					send_large_msg(receiver, "<code>لینک جدید ساخته شد</code>")
					data[tostring(msg.to.id)]['settings']['set_link'] = result
					save_data(_config.moderation.data, data)
				end
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] attempted to create a new SuperGroup link")
			export_channel_link(receiver, callback_link, false)
		end

		if matches[1] == 'تنظیم لینک' and is_owner(msg) then
			data[tostring(msg.to.id)]['settings']['set_link'] = 'waiting'
			save_data(_config.moderation.data, data)
			return '<code>لطفا لینک جدید را ارسال کنید</code>'
		end

		if msg.text then
			if msg.text:match("^(https://t.me/joinchat/%S+)$") or if msg.text:match("^(https://telegram.me/joinchat/%S+)$")  and data[tostring(msg.to.id)]['settings']['set_link'] == 'waiting' and is_owner(msg) then
				data[tostring(msg.to.id)]['settings']['set_link'] = msg.text
				save_data(_config.moderation.data, data)
				return "<code>لینک ثبت شد!</code>"
			end
		end

		if matches[1] == 'لینک' then
			if not is_momod(msg) then
				return
			end
			local group_link = data[tostring(msg.to.id)]['settings']['set_link']
			if not group_link then
				return "<code>لینک وجود ندارد برای ساخت لینک از دستور #ایجاد لینک استفاده کنید و برای ثبت لینک از دستور #ثبت لینک استفاده کنید</code>"
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group link ["..group_link.."]")
			return "<code>Channel Team</code> @CerNerCH \n<code>لینک گروه</code>:\n"..group_link
		end

		if matches[1] == "دعوت" and is_sudo(msg) then
			local cbres_extra = {
				channel = get_receiver(msg),
				get_cmd = "دعوت"
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] invited @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		if matches[1] == 'مشخصات' and is_owner(msg) then
			local cbres_extra = {
				channelid = msg.to.id,
				get_cmd = 'مشخصات'
			}
			local username = matches[2]
			local username = username:gsub("@","")
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] resolved username: @"..username)
			resolve_username(username,  callbackres, cbres_extra)
		end

		--[[if matches[1] == 'اخراج' and is_momod(msg) then
			local receiver = channel..matches[3]
			local user = "user#id"..matches[2]
			chaannel_kick(receiver, user, ok_cb, false)
		end]]

			if matches[1] == 'ادمین' then
				if not is_support(msg.from.id) and not is_owner(msg) then
					return
				end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'ادمین',
					msg = msg
				}
				setadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'ادمین' and string.match(matches[2], '^%d+$') then
			--[[]	local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'ادمین'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})]]
				local	get_cmd = 'ادمین'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'ادمین' and not string.match(matches[2], '^%d+$') then
				--[[local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'ادمین'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set admin @"..username)
				resolve_username(username, callbackres, cbres_extra)]]
				local	get_cmd = 'ادمین'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'تنزل ادمین' then
			if not is_support(msg.from.id) and not is_owner(msg) then
				return
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'تنزل ادمین',
					msg = msg
				}
				demoteadmin = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'تنزل ادمین' and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'تنزل ادمین'
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'تنزل ادمین' and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'تنزل ادمین'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted admin @"..username)
				resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'صاحب' and is_owner(msg) then
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'صاحب',
					msg = msg
				}
				setowner = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'صاحب' and string.match(matches[2], '^%d+$') then
		--[[	local group_owner = data[tostring(msg.to.id)]['set_owner']
				if group_owner then
					local receiver = get_receiver(msg)
					local user_id = "user#id"..group_owner
					if not is_admin2(group_owner) and not is_support(group_owner) then
						channel_demote(receiver, user_id, ok_cb, false)
					end
					local user = "user#id"..matches[2]
					channel_set_admin(receiver, user, ok_cb, false)
					data[tostring(msg.to.id)]['set_owner'] = tostring(matches[2])
					save_data(_config.moderation.data, data)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set ["..matches[2].."] as owner")
					local text = "[ "..matches[2].." ] صاحب گروه شد"
					return text
				end]]
				local	get_cmd = 'صاحب'
				local	msg = msg
				local user_id = matches[2]
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, user_id=user_id})
			elseif matches[1] == 'صاحب' and not string.match(matches[2], '^%d+$') then
				local	get_cmd = 'صاحب'
				local	msg = msg
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				channel_get_users (receiver, in_channel_cb, {get_cmd=get_cmd, receiver=receiver, msg=msg, username=username})
			end
		end

		if matches[1] == 'مدیر' then
		  if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "<code>فقط صاحب گروه</code>"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'مدیر',
					msg = msg
				}
				promote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'مدیر' and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'مدیر'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif matches[1] == 'مدیر' and not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'مدیر',
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] promoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == 'mp' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_set_mod(channel, user_id, ok_cb, false)
			return "ok"
		end
		if matches[1] == 'md' and is_sudo(msg) then
			channel = get_receiver(msg)
			user_id = 'user#id'..matches[2]
			channel_demote(channel, user_id, ok_cb, false)
			return "ok"
		end

		if matches[1] == 'تنزل مدیر' then
			if not is_momod(msg) then
				return
			end
			if not is_owner(msg) then
				return "<code>فقط صاحب گروه</code>"
			end
			if type(msg.reply_id) ~= "nil" then
				local cbreply_extra = {
					get_cmd = 'تنزل مدیر',
					msg = msg
				}
				demote = get_message(msg.reply_id, get_message_callback, cbreply_extra)
			elseif matches[1] == 'تنزل مدیر' and string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local user_id = "user#id"..matches[2]
				local get_cmd = 'تنزل مدیر'
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted user#id"..matches[2])
				user_info(user_id, cb_user_info, {receiver = receiver, get_cmd = get_cmd})
			elseif not string.match(matches[2], '^%d+$') then
				local cbres_extra = {
					channel = get_receiver(msg),
					get_cmd = 'تنزل مدیر'
				}
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] demoted @"..username)
				return resolve_username(username, callbackres, cbres_extra)
			end
		end

		if matches[1] == "تنظیم نام" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local set_name = string.gsub(matches[2], '_', '')
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..matches[2])
			rename_channel(receiver, set_name, ok_cb, false)
		end

		if msg.service and msg.action.type == 'chat_rename' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] renamed SuperGroup to: "..msg.to.title)
			data[tostring(msg.to.id)]['settings']['set_name'] = msg.to.title
			save_data(_config.moderation.data, data)
		end

		if matches[1] == "تنظیم درباره" and is_momod(msg) then
			local receiver = get_receiver(msg)
			local about_text = matches[2]
			local data_cat = 'description'
			local target = msg.to.id
			data[tostring(target)][data_cat] = about_text
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup description to: "..about_text)
			channel_set_about(receiver, about_text, ok_cb, false)
			return "Description has been set.\n\nSelect the chat again to see the changes."
		end

		if matches[1] == "تنظیم یوزرنیم" and is_admin1(msg) then
			local function ok_username_cb (extra, success, result)
				local receiver = extra.receiver
				if success == 1 then
					send_large_msg(receiver, "یوزرنیم گروه ذخیره شد /لطفا پیامی ارسال کنید")
				elseif success == 0 then
					send_large_msg(receiver, "خطا یوزرنیم ثبت نشد .")
				end
			end
			local username = string.gsub(matches[2], '@', '')
			channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
		end

		if matches[1] == 'تنظیم قوانین' and is_momod(msg) then
			rules = matches[2]
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] has changed group rules to ["..matches[2].."]")
			return set_rulesmod(msg, data, target)
		end

		if msg.media then
			if msg.media.type == 'photo' and data[tostring(msg.to.id)]['settings']['set_photo'] == 'waiting' and is_momod(msg) then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set new SuperGroup photo")
				load_photo(msg.id, set_supergroup_photo, msg)
				return
			end
		end
		if matches[1] == 'تنظیم عکس' and is_momod(msg) then
			data[tostring(msg.to.id)]['settings']['set_photo'] = 'waiting'
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] started setting new SuperGroup photo")
			return 'لطفا عکس جدید گروه را ارسال کنید'
		end

		if matches[1] == 'پاک کردن' then
			if not is_momod(msg) then
				return
			end
			if not is_momod(msg) then
				return "Only owner can clean"
			end
			if matches[2] == 'مدیران' then
				if next(data[tostring(msg.to.id)]['moderators']) == nil then
					return 'هیچ مدیری موجود نیست.'
				end
				for k,v in pairs(data[tostring(msg.to.id)]['moderators']) do
					data[tostring(msg.to.id)]['moderators'][tostring(k)] = nil
					save_data(_config.moderation.data, data)
				end
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned modlist")
				return 'لیست مدیران پاک سازی شد'
			end
			if matches[2] == 'قوانین' then
				local data_cat = 'rules'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return "قوانین ثبت نشده"
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned rules")
				return 'قوانین پاک شد'
			end
			if matches[2] == 'درباره' then
				local receiver = get_receiver(msg)
				local about_text = ' '
				local data_cat = 'description'
				if data[tostring(msg.to.id)][data_cat] == nil then
					return 'درباره گروه ثبت نشده'
				end
				data[tostring(msg.to.id)][data_cat] = nil
				save_data(_config.moderation.data, data)
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] cleaned about")
				channel_set_about(receiver, about_text, ok_cb, false)
				return "درباره گروه پاک شد"
			end
			if matches[2] == 'صامت شدگان' then
				chat_id = msg.to.id
				local hash =  'mute_user:'..chat_id
					redis:del(hash)
				return "لیست صامت شدگان پاک سازی شد!"
			end
			if matches[2] == 'یوزرنیم' and is_admin1(msg) then
				local function ok_username_cb (extra, success, result)
					local receiver = extra.receiver
					if success == 1 then
						send_large_msg(receiver, "یوزرنیم سوپرگپ پاک شد.")
					elseif success == 0 then
						send_large_msg(receiver, "یوزرنیم موجود نیست")
					end
				end
				local username = ""
				channel_set_username(receiver, username, ok_username_cb, {receiver=receiver})
			end
		end

		if matches[1] == 'قفل' and is_momod(msg) then
			local target = msg.to.id
			     if matches[2] == 'همه' then
      	local safemode ={
        lock_group_links(msg, data, target),
		lock_group_tag(msg, data, target),
		lock_group_spam(msg, data, target),
		lock_group_flood(msg, data, target),
		lock_group_arabic(msg, data, target),
		lock_group_membermod(msg, data, target),
		lock_group_rtl(msg, data, target),
		lock_group_tgservice(msg, data, target),
		lock_group_sticker(msg, data, target),
		lock_group_contacts(msg, data, target),
		lock_group_english(msg, data, target),
		lock_group_fwd(msg, data, target),
		lock_group_reply(msg, data, target),
		lock_group_join(msg, data, target),
		lock_group_emoji(msg, data, target),
		lock_group_username(msg, data, target),
		lock_group_fosh(msg, data, target),
		lock_group_media(msg, data, target),
		lock_group_leave(msg, data, target),
		lock_group_bots(msg, data, target),
		lock_group_operator(msg, data, target),
      	}
      	return lock_group_all(msg, data, target), safemode
      end
			if matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked link posting ")
				return lock_group_links(msg, data, target)
			end
			if matches[2] == 'دعوت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked join ")
				return lock_group_join(msg, data, target)
			end
			if matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked tag ")
				return lock_group_tag(msg, data, target)
			end			
			if matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked spam ")
				return lock_group_spam(msg, data, target)
			end
			if matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked flood ")
				return lock_group_flood(msg, data, target)
			end
			if matches[2] == 'زبان عربی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked arabic ")
				return lock_group_arabic(msg, data, target)
			end
			if matches[2] == 'افزودن عضو' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked member ")
				return lock_group_membermod(msg, data, target)
			end		    
			if matches[2]:lower() == 'ار تی ال' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked rtl chars. in names")
				return lock_group_rtl(msg, data, target)
			end
			if matches[2] == 'ورود خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked Tgservice Actions")
				return lock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked sticker posting")
				return lock_group_sticker(msg, data, target)
			end
			if matches[2]:lower() == 'دکمه شیشه ای' then
    savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked inline chars. in names")
    return lock_group_inline(msg, data, target)
   end
			if matches[2] == 'مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked contact posting")
				return lock_group_contacts(msg, data, target)
			end
			if matches[2] == 'سخت گیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked enabled strict settings")
				return enable_strict_rules(msg, data, target)
			end
			if matches[2] == 'زبان انگلیسی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked english")
				return lock_group_english(msg, data, target)
			end
			if matches[2] == 'فروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fwd")
				return lock_group_fwd(msg, data, target)
			end
			if matches[2] == 'ریپلی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked reply")
				return lock_group_reply(msg, data, target)
			end
			if matches[2] == 'شکلک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked emoji")
				return lock_group_emoji(msg, data, target)
			end
			if matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked fosh")
				return lock_group_fosh(msg, data, target)
			end
			if matches[2] == 'رسانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked media")
				return lock_group_media(msg, data, target)
			end
			if matches[2] == 'یوزرنیم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked username")
				return lock_group_username(msg, data, target)
			end
			if matches[2] == 'بازگشت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked leave")
				return lock_group_leave(msg, data, target)
			end
			if matches[2] == 'ورود ربات then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked bots")
				return lock_group_bots(msg, data, target)
			end
			if matches[2] == 'اپراتور' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked operator")
				return lock_group_operator(msg, data, target)
			end
		end

		if matches[1] == 'باز کردن and is_momod(msg) then
			local target = msg.to.id
			     if matches[2] == 'همه' then
      	local dsafemode ={
        unlock_group_links(msg, data, target),
		unlock_group_tag(msg, data, target),
		unlock_group_spam(msg, data, target),
		unlock_group_flood(msg, data, target),
		unlock_group_arabic(msg, data, target),
		unlock_group_membermod(msg, data, target),
		unlock_group_rtl(msg, data, target),
		unlock_group_tgservice(msg, data, target),
		unlock_group_sticker(msg, data, target),
		unlock_group_contacts(msg, data, target),
		unlock_group_english(msg, data, target),
		unlock_group_fwd(msg, data, target),
		unlock_group_reply(msg, data, target),
		unlock_group_join(msg, data, target),
		unlock_group_emoji(msg, data, target),
		unlock_group_username(msg, data, target),
		unlock_group_fosh(msg, data, target),
		unlock_group_media(msg, data, target),
		unlock_group_leave(msg, data, target),
		unlock_group_bots(msg, data, target),
		unlock_group_operator(msg, data, target),
      	}
      	return unlock_group_all(msg, data, target), dsafemode
      end
	         if matches[2] == 'لینک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked link posting")
				return unlock_group_links(msg, data, target)
			end
			if matches[2] == 'دعوت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked join")
				return unlock_group_join(msg, data, target)
			end
			if matches[2] == 'تگ' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tag")
				return unlock_group_tag(msg, data, target)
			end			
			if matches[2] == 'اسپم' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked spam")
				return unlock_group_spam(msg, data, target)
			end
			if matches[2] == 'فلود' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked flood")
				return unlock_group_flood(msg, data, target)
			end
			if matches[2] == 'زبان عربی then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked Arabic")
				return unlock_group_arabic(msg, data, target)
			end
			if matches[2] == 'افزودن عضو' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked member ")
				return unlock_group_membermod(msg, data, target)
			end                   
			if matches[2]:lower() == 'ار تی ال' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked RTL chars. in names")
				return unlock_group_rtl(msg, data, target)
			end
				if matches[2] == 'ورود خروج' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked tgservice actions")
				return unlock_group_tgservice(msg, data, target)
			end
			if matches[2] == 'استیکر' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked sticker posting")
				return unlock_group_sticker(msg, data, target)
			end
			if matches[2] == 'مخاطب' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked contact posting")
				return unlock_group_contacts(msg, data, target)
			end
			if matches[2] == 'سخت گیرانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled strict settings")
				return disable_strict_rules(msg, data, target)
			end
			if matches[2] == 'انگلیسی then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked english")
				return unlock_group_english(msg, data, target)
			end
			if matches[2] == 'فروارد' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fwd")
				return unlock_group_fwd(msg, data, target)
			end
			if matches[2] == 'ریپلی' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked reply")
				return unlock_group_reply(msg, data, target)
			end
			if matches[2] == 'شکلک' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled emoji")
				return unlock_group_emoji(msg, data, target)
			end
			if matches[2] == 'فحش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked fosh")
				return unlock_group_fosh(msg, data, target)
			end
			if matches[2] == 'رسانه' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked media")
				return unlock_group_media(msg, data, target)
			end
			if matches[2] == 'یوزرنیم then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked disabled username")
				return unlock_group_username(msg, data, target)
			end
			if matches[2] == 'بازگشت' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked leave")
				return unlock_group_leave(msg, data, target)
			end
			if matches[2] == 'ورود ربات' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked bots")
				return unlock_group_bots(msg, data, target)
			end
			if matches[2]:lower() == 'دکمه شیشه ای' then
    savelog(msg.to.id, name_log.." ["..msg.from.id.."] unlocked inline chars. in names")
    return unlock_group_inline(msg, data, target)
   end
			if matches[2] == 'اپراتور' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] locked operator")
				return unlock_group_operator(msg, data, target)
			end
		end

		if matches[1] == 'تنظیم حساسیت then
			if not is_momod(msg) then
				return
			end
			if tonumber(matches[2]) < 1 or tonumber(matches[2]) > 200 then
				return " استفاده کنید خطا.فقط میتوانید از [1-200]"
			end
			local flood_max = matches[2]
			data[tostring(msg.to.id)]['settings']['flood_msg_max'] = flood_max
			save_data(_config.moderation.data, data)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] set flood to ["..matches[2].."]")
			return '<code>حساسیت اسپم تنظیم شد به :</code> '..matches[2]
		end
		if matches[1] == 'عمومی' and is_momod(msg) then
			local target = msg.to.id
			if matches[2] == 'روشن' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set group to: public")
				return set_public_membermod(msg, data, target)
			end
			if matches[2] == 'خاموش' then
				savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: not public")
				return unset_public_membermod(msg, data, target)
			end
		end

		if matches[1] == 'صامت کردن' and is_owner(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SupGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." صامت شد"
				else
					return msg_type.." مجددا صامت شد"
				end
			end
			if matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." صامت شد"
				else
					return msg_type.." مجددا صامت شد"
				end
			end
			if matches[2] == 'فیلم'‌ then
			local msg_type = 'Video'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." صامت شد"
				else
					return msg_type.." مجددا صامت شد"
				end
			end
			if matches[2] == 'گیف then
			local msg_type = 'Gifs'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." صامت شد"
				else
					return msg_type.." مجددا صامت شد"
				end
			end
			if matches[2] == 'سند' then
			local msg_type = 'Documents'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." صامت شد"
				else
					return msg_type.." مجددا صامت شد"
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'Text'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return msg_type.." صامت شد"
				else
					return msg_type.." مجددا صامت شد"
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'All'
				if not is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: mute "..msg_type)
					mute(chat_id, msg_type)
					return "Mute "..msg_type.."  موصوت شد"
				else
					return msg_type.." مجددا موصوت شد
				end
			end
		end
		if matches[1] == 'موصوت' and is_momod(msg) then
			local chat_id = msg.to.id
			if matches[2] == 'صدا' then
			local msg_type = 'Audio'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." صامت شد"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'عکس' then
			local msg_type = 'Photo'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'فیلم' then
			local msg_type = 'Video'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'گیف' then
			local msg_type = 'Gifs'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." have been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'سند' then
			local msg_type = 'Documents'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return msg_type.." have been unmuted"
				else
					return "Mute "..msg_type.." is already off"
				end
			end
			if matches[2] == 'متن' then
			local msg_type = 'Text'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute message")
					unmute(chat_id, msg_type)
					return msg_type.." has been unmuted"
				else
					return "Mute text is already off"
				end
			end
			if matches[2] == 'همه' then
			local msg_type = 'All'
				if is_muted(chat_id, msg_type..': yes') then
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] set SuperGroup to: unmute "..msg_type)
					unmute(chat_id, msg_type)
					return "Mute "..msg_type.." has been disabled"
				else
					return "Mute "..msg_type.." is already disabled"
				end
			end
		end


		if matches[1] == "سایلنت" or matches[1] == "موصوت" and is_momod(msg) then
			local chat_id = msg.to.id
			local hash = "mute_user"..chat_id
			local user_id = ""
			if type(msg.reply_id) ~= "nil" then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				muteuser = get_message(msg.reply_id, get_message_callback, {receiver = receiver, get_cmd = get_cmd, msg = msg})
			elseif matches[1] == "سایلنت" or matches[1] == "موصوت" and string.match(matches[2], '^%d+$') then
				local user_id = matches[2]
				if is_muted_user(chat_id, user_id) then
					unmute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] removed ["..user_id.."] from the muted users list")
					return "["..user_id.."]  از لیست صامت شدگان حذف شد"
				elseif is_momod(msg) then
					mute_user(chat_id, user_id)
					savelog(msg.to.id, name_log.." ["..msg.from.id.."] added ["..user_id.."] to the muted users list")
					return "["..user_id.."] کاربر صامت شد"
				end
			elseif matches[1] == "سایلنت" or matches[1] == "موصوت" and not string.match(matches[2], '^%d+$') then
				local receiver = get_receiver(msg)
				local get_cmd = "mute_user"
				local username = matches[2]
				local username = string.gsub(matches[2], '@', '')
				resolve_username(username, callbackres, {receiver = receiver, get_cmd = get_cmd, msg=msg})
			end
		end

		if matches[1] == "میوت لیست" and is_momod(msg) then
			local chat_id = msg.to.id
			if not has_mutes(chat_id) then
				set_mutes(chat_id)
				return mutes_list(chat_id)
			end
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup muteslist")
			return mutes_list(chat_id)
		end
		if matches[1] == "صامت شدگان"" and is_momod(msg) then
			local chat_id = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup mutelist")
		 return muted_user_list(chat_id)
		end

		if matches[1] == 'تنظیمات'' and is_momod(msg) then
			local target = msg.to.id
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested SuperGroup settings ")
			return show_supergroup_settingsmod(msg, target)
		end

		if matches[1] == 'قوانین' then
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] requested group rules")
			return get_rules(msg, data)
		end

		if matches[1] == 'راهنما' and not is_owner(msg) then
			text = "فقط مدیران"
			reply_msg(msg.id, text, ok_cb, false)
		elseif matches[1] == 'help' and is_owner(msg) then
			local name_log = user_print_name(msg.from)
			savelog(msg.to.id, name_log.." ["..msg.from.id.."] Used /superhelp")
			return super_help()
		end

		if matches[1] == 'peer_id' and is_admin1(msg)then
			text = msg.to.peer_id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		if matches[1] == 'msg.to.id' and is_admin1(msg) then
			text = msg.to.id
			reply_msg(msg.id, text, ok_cb, false)
			post_large_msg(receiver, text)
		end

		--Admin Join Service Message
		if msg.service then
		local action = msg.action.type
			if action == 'chat_add_user_link' then
				if is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Admin ["..msg.from.id.."] joined the SuperGroup via link")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.from.id) and not is_owner2(msg.from.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.from.id
					savelog(msg.to.id, name_log.." Support member ["..msg.from.id.."] joined the SuperGroup")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
			if action == 'chat_add_user' then
				if is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Admin ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_admin(receiver, user, ok_cb, false)
				end
				if is_support(msg.action.user.id) and not is_owner2(msg.action.user.id) then
					local receiver = get_receiver(msg)
					local user = "user#id"..msg.action.user.id
					savelog(msg.to.id, name_log.." Support member ["..msg.action.user.id.."] added to the SuperGroup by [ "..msg.from.id.." ]")
					channel_set_mod(receiver, user, ok_cb, false)
				end
			end
		end
		if matches[1] == '1110482248293884902848928829489391171888' then
			post_large_msg(receiver, msg.to.peer_id)
		end
	end
end

local function pre_process(msg)
  if not msg.text and msg.media then
    msg.text = '['..msg.media.type..']'
  end
  return msg
end

return {
  patterns = {
	"^(افزودن)$",
	"^(حذف شو)$",
	"^([Mm]ove) (.*)$",
	"^(اطلاعات گروه)$",
	"^(ادمین ها)$",
	"^(صاحب گروه)$",
	"^(مدیران)$",
	"^(ربات ها)$",
	"^([Ww]ho)$",
	"(اخراج شده ها)$",
        "(بلوک) (.*)",
	"^(بلوک)",
	    "^(اخراج) (.*)",
	"^(اخراج)",
	"^(ارتقا)$",
	"^(ایدی)$",
	"^(ایدی) (.*)$",
	"^(خروج)$",
	"^(ساخت لینک)$",
	"^(تتظیم لینک)$",
	"^(لینک)$",
	"^(مشخصات) (.*)$",
	"^(ادمین) (.*)$",
	"^(ادمین)",
	"(تنزل ادمین) (.*)$",
	"^(تنزل ادمین)",
	"^(صاحب) (.*)$",
	"^(صاحب)$",
	"^(مدیر) (.*)$",
	"^(مدیر)",
	"^(تنزل مدیر) (.*)$",
	"^(تنزل مدیر)",
	"^(تنظیم نام) (.*)$",
	"^(تنظیم درباره) (.*)$",
	"^(تنظیم قوانین) (.*)$",
	"^(تنظیم عکس)$",
	"^(تنظیم یوزرنیم) (.*)$",
	"^(پاک)$",
	"^(قفل ) (.*)$",
	"^(بازکردن) (.*)$",
	"^(صامت) ([^%s]+)$",
	"^(موصوت) ([^%s]+)$",
	"^(سایلنت)$",
	"^(سایلنت) (.*)$",
	"^(موصوت)$",
	"^(موصوت) (.*)$",
	"^(عمومی) (.*)$",
	"^(تنظیمات)$",
	"^(قوانین)$",
	"^(تنظیم حساسیت) (%d+)$",
	"^(پاک کردن) (.*)$",
	"^(راهنما)$",
	"^(میوت لیست)$",
	"^(صامت شدگان)$",
    "(mp) (.*)",
	"(md) (.*)",
    "^(https://telegram.me/joinchat/%S+)$",
    "^(https://t.me/joinchat/%S+)$",
	"1110482248293884902848928829489391171888",
	"%[(document)%]",
	"%[(photo)%]",
	"%[(video)%]",
	"%[(audio)%]",
	"%[(contact)%]",
	"^!!tgservice (.+)$",
  },
  run = run,
  pre_process = pre_process
}

