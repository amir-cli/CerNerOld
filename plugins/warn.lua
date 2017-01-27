--#############################
--#                  Warn Plugin                            #
--#                                                                   #
--#                  @Empix                                 #
--#                  @EdBaRoO                          #
--#                                                                #
--#                @shieldTM                           #
--###########################
local data = load_data(_config.moderation.data)
--------------------------------------------------
local function set_warn(msg, value)
    if tonumber(value) < 0 or tonumber(value) > 10 then
        return 'Error, range is [0-10].'
    end
    local warn_max = value
    data[tostring(msg.to.id)]['settings']['warn_max'] = warn_max
    save_data(_config.moderation.data, data)
    return 'Warn has been set to '..value
end
--------------------------------------------------------------
local function get_warn(msg)
    local warn_max = data[tostring(msg.to.id)]['settings']['warn_max']
    if not warn_max then
        return 'warn not set'
    end
    return 'Warn has been set to '..warn_max
end
---------------------------------------------------------
local function get_user_warns(user_id, chat_id)
    local channel = 'channel#id'..chat_id
    local chat = 'chat#id'..chat_id
    local hash = chat_id..':warn:'..user_id
    local hashonredis = redis:get(hash)
    local warn_msg = 'You\'re at X warns on P.'
    local warn_chat = string.match(get_warn( { from = { id = user_id }, to = { id = chat_id } }), "%d+")

    if hashonredis then
        warn_msg = string.gsub(string.gsub(warn_msg, 'P', warn_chat), 'X', tostring(hashonredis))
        send_large_msg(chat, warn_msg, ok_cb, false)
        send_large_msg(channel, warn_msg, ok_cb, false)
    else
        warn_msg = string.gsub(string.gsub(warn_msg, 'P', warn_chat), 'X', '0')
        send_large_msg(chat, warn_msg, ok_cb, false)
        send_large_msg(channel, warn_msg, ok_cb, false)
    end
end
-------------------------------------------------------------
local function warn_user(user_id, chat_id)
    local channel = 'channel#id'..chat_id
    local chat = 'chat#id'..chat_id
    local user = 'user#id'..user_id
    local warn_chat = string.match(get_warn( { from = { id = user_id }, to = { id = chat_id } }), "%d+")
    local hash = chat_id..':warn:'..user_id
    redis:incr(hash)
    local hashonredis = redis:get(hash)
    if hashonredis then
        if tonumber(warn_chat) ~= 0 then
            if tonumber(hashonredis) >= tonumber(warn_chat) then
                local function post_kick()
                    chat_del_user(chat, user, ok_cb, false)
                    channel_kick(channel, user, ok_cb, false)
                end
                postpone(post_kick, false, 3)
                redis:getset(hash, 0)
            end
            send_large_msg(chat, string.gsub('You\'ve been warned X times, calm down!', 'X', tostring(hashonredis)), ok_cb, false)
            send_large_msg(channel, string.gsub('You\'ve been warned X times, calm down!', 'X', tostring(hashonredis)), ok_cb, false)
        end
    else
        redis:set(hash, 1)
        send_large_msg(chat, string.gsub('You\'ve been warned X times, calm down!', 'X', '1'), ok_cb, false)
        send_large_msg(channel, string.gsub('You\'ve been warned X times, calm down!', 'X', '1'), ok_cb, false)
    end
end
-------------------------------------------------------------
local function unwarn_user(user_id, chat_id)
    local channel = 'channel#id'..chat_id
    local chat = 'chat#id'..chat_id
    local hash = chat_id..':warn:'..user_id
    local warns = redis:get(hash)
    if tonumber(warns) <= 0 then
        redis:set(hash, 0)
        send_large_msg(chat, 'You\'re already at zero warns.', ok_cb, false)
        send_large_msg(channel, 'You\'re already at zero warns.', ok_cb, false)
    else
        redis:set(hash, warns - 1)
        send_large_msg(chat, 'One warn has been deleted, keep it up!', ok_cb, false)
        send_large_msg(channel, 'One warn has been deleted, keep it up!', ok_cb, false)
    end
end
---------------------------------------------------------------
local function unwarnall_user(user_id, chat_id)
    local channel = 'channel#id'..chat_id
    local chat = 'chat#id'..chat_id
    local hash = chat_id..':warn:'..user_id
    redis:set(hash, 0)
    send_large_msg(chat, 'Your warns has been removed.', ok_cb, false)
    send_large_msg(channel, 'Your warns has been removed.', 'X', ok_cb, false)
end
-----------------------------------------------------------------
local function Warn_by_reply(extra, success, result)
    if result.to.peer_type == 'chat' or result.to.peer_type == 'channel' then
        if tonumber(result.from.peer_id) == tonumber(our_id) then
            return
        end
        if is_momod2(result.from.peer_id, result.to.peer_id) then
            return 'You can\'t warn mod/owner/admin/sudo!'
        end
        warn_user(result.from.peer_id, result.to.peer_id)
    else
        return 'Use it in your groups!'
    end
end
--------------------------------------------------------
local function Warn_by_username(extra, success, result)
    if success == 0 then
        return send_large_msg(receiver, 'Can\'t find a user with that username.')
    end
    local user_id = result.peer_id
    local chat_id = extra.msg.to.id
    warn_user(user_id, chat_id)
end
-----------------------------------------------------------
local function Unwarn_by_reply(extra, success, result)
    if result.to.peer_type == 'chat' or result.to.peer_type == 'channel' then
        unwarn_user(result.from.peer_id, result.to.peer_id)
    else
        return 'Use it in your groups!'
    end
end
------------------------------------------------------------------
local function Unwarn_by_username(extra, success, result)
    if success == 0 then
        return send_large_msg(receiver, 'Can\'t find a user with that username.')
    end
    local user_id = result.peer_id
    local chat_id = extra.msg.to.id
    unwarn_user(user_id, chat_id)
end
--------------------------------------------------------------
local function Unwarnall_by_reply(extra, success, result)
    if result.to.peer_type == 'chat' or result.to.peer_type == 'channel' then
        unwarnall_user(result.from.peer_id, result.to.peer_id)
    else
        return 'Use it in your groups!'
    end
end
-----------------------------------------------------
local function Unwarnall_by_username(extra, success, result)
    if success == 0 then
        return send_large_msg(receiver, 'Can\'t find a user with that username.')
    end
    local user_id = result.peer_id
    local chat_id = extra.msg.to.id
    unwarnall_user(user_id, chat_id)
end
---------------------------------------------------------------
local function getWarn_by_reply(extra, success, result)
    if result.to.peer_type == 'chat' or result.to.peer_type == 'channel' then
        get_user_warns(result.from.peer_id, result.to.peer_id)
    else
        return 'Use it in your groups!'
    end
end
---------------------------------------------------------------
local function getWarn_by_username(extra, success, result)
    if success == 0 then
        return send_large_msg(receiver, 'Can\'t find a user with that username.')
    end
    local user_id = result.peer_id
    local chat_id = extra.msg.to.id
    get_user_warns(user_id, chat_id)
end
-------------------------------------------------------------
local function run(msg, matches)
    if is_momod(msg) then
        if matches[1]:lower() == 'warnmax' and matches[2] then
            local msg = set_warn(msg, matches[2])
            if matches[2] == '0' then
                return 'Warn will not work anymore.'
            else
                return msg
            end
        end
        if get_warn(msg) == 'Warn hasn\t been set yet.' then
            return 'Warn hasn\t been set yet.'
        else
            if matches[1]:lower() == 'getwarn' then
                if type(msg.reply_id) ~= "nil" then
                    msgr = get_message(msg.reply_id, getWarn_by_reply, false)
                elseif string.match(matches[2], '^%d+$') then
                    return get_user_warns(msg.from.id, msg.to.id)
                else
                    resolve_username(string.gsub(matches[2], '@', ''), getWarn_by_username, { msg = msg })
                end
            end
            if matches[1]:lower() == 'warn' then
                if type(msg.reply_id) ~= "nil" then
                    msgr = get_message(msg.reply_id, Warn_by_reply, false)
                elseif string.match(matches[2], '^%d+$') then
                    if tonumber(matches[2]) == tonumber(our_id) then
                        return
                    end
                    if is_momod2(matches[2], msg.to.id) then
                        return 'You can\'t warn mod/owner/admin/sudo!'
                    end
                    local user_id = matches[2]
                    local chat_id = msg.to.id
                    local print_name = user_print_name(msg.from):gsub("‮", "")
                    local name = print_name:gsub("_", "")
                    warn_user(user_id, chat_id)
                else
                    resolve_username(string.gsub(matches[2], '@', ''), Warn_by_username, { msg = msg })
                end
            end
            if matches[1]:lower() == 'unwarn' then
                if type(msg.reply_id) ~= "nil" then
                    msgr = get_message(msg.reply_id, Unwarn_by_reply, false)
                elseif string.match(matches[2], '^%d+$') then
                    local user_id = matches[2]
                    local chat_id = msg.to.id
                    local print_name = user_print_name(msg.from):gsub("‮", "")
                    local name = print_name:gsub("_", "")
                    unwarn_user(user_id, chat_id)
                else
                    resolve_username(string.gsub(matches[2], '@', ''), Unwarn_by_username, { msg = msg })
                end
            end
            if matches[1]:lower() == 'unwarnall' then
                if type(msg.reply_id) ~= "nil" then
                    msgr = get_message(msg.reply_id, Unwarnall_by_reply, false)
                elseif string.match(matches[2], '^%d+$') then
                    local user_id = matches[2]
                    local chat_id = msg.to.id
                    local print_name = user_print_name(msg.from):gsub("‮", "")
                    local name = print_name:gsub("_", "")
                    unwarnall_user(user_id, chat_id)
                else
                    resolve_username(string.gsub(matches[2], '@', ''), Unwarnall_by_username, { msg = msg })
                end
            end
        end
    else
        return 'This plugin requires mod privileges or higher.'
    end
end

return {
    description = "WARN",
    patterns =
    {
        "^[#!/]([Ww][Aa][Rr][Nn][Mm][Aa][Xx]) (%d+)$",
        "^[#!/]([Gg][Ee][Tt][Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Gg][Ee][Tt][Ww][Aa][Rr][Nn])$",
        "^[#!/]([Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Ww][Aa][Rr][Nn])$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn]) (.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn])$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll]) (.*)$",
        "^[#!/]([Uu][Nn][Ww][Aa][Rr][Nn][Aa][Ll][Ll])$",
    },
    run = run,
}
--#############################
--#                  Warn Plugin                            #
--#                                                                   #
--#                  @Empix                                 #
--#                  @EdBaRoO                          #
--#                                                                #
--#                @shieldTM                           #
--###########################