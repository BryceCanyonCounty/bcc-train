-- Small shared helpers to resolve item information (labels and full item data)
-- This module prefers the server inventory export when available and falls back to
-- the `items` DB table via oxmysql/MySQL when needed.
local Core = exports.vorp_core:GetCore()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

-- Shared helper: fetch item info from inventory export or DB fallback.
-- Returns a table with fields (id,label,name,desc,weight,limit, etc.) or minimal fallback.
-- Fetch detailed item info for an item id or a table of ids.
-- Returns a table (or map of tables) with fields similar to vorp_inventory's item object.
local function fetchItemInfo(itemId)
    if not itemId then return nil end

    -- Batch resolution: accept a table of ids and return a map
    if type(itemId) == 'table' then
        DBG.Info('fetchItemInfo: resolving batch of ' .. tostring(#itemId) .. ' ids')
        local out = {}
        for _, id in ipairs(itemId) do
            out[id] = fetchItemInfo(id)
        end
        return out
    end

    -- Try server-side inventory export first (preferred)
    if exports.vorp_inventory and exports.vorp_inventory.getItem then
        local ok, info = pcall(function() return exports.vorp_inventory:getItem(itemId) end)
        if ok and info then
            info.id = info.id or itemId
            DBG.Info('fetchItemInfo: used vorp_inventory export for item ' .. tostring(itemId))
            return info
        else
            DBG.Info('fetchItemInfo: vorp_inventory.getItem returned nil or errored for ' .. tostring(itemId))
        end
    end

    -- DB fallback: query the `items` table if oxmysql/MySQL is available
    local ok, rows = pcall(function()
        if MySQL and MySQL.query and MySQL.query.await then
            return MySQL.query.await('SELECT item AS id, label, description AS desc, weight, `limit` FROM items WHERE item = ?', { itemId })
        elseif exports.oxmysql and exports.oxmysql.query_async then
            return exports.oxmysql.query_async('SELECT item AS id, label, description AS desc, weight, `limit` FROM items WHERE item = ?', { itemId })
        end
        return nil
    end)

    if ok and rows and rows[1] then
        local r = rows[1]
        DBG.Info('fetchItemInfo: DB fallback found metadata for item ' .. tostring(itemId))
        local out = {
            id = r.id or itemId,
            label = r.label or tostring(itemId),
            name = r.label or tostring(itemId),
            metadata = {},
            group = 0,
            type = 'item',
            count = 0,
            limit = r['limit'] or 0,
            canUse = false,
            weight = r.weight or 0,
            desc = r.desc or '',
            percentage = 0
        }
        return out
    end

    DBG.Warning('fetchItemInfo: no data found for item ' .. tostring(itemId) .. ' — returning minimal fallback')
    -- Minimal fallback object
    return { id = itemId, label = tostring(itemId), name = tostring(itemId), metadata = {}, group = 0, type = 'item', count = 0, limit = 0, canUse = false, weight = 0, desc = '', percentage = 0 }
end

-- Return the human-friendly label for an item id (or a map for multiple ids)
local function getItemLabel(itemId)
    if not itemId then return tostring(itemId) end
    if type(itemId) == 'table' then
        DBG.Info('getItemLabel: resolving labels for ' .. tostring(#itemId) .. ' ids')
        local out = {}
        for _, id in ipairs(itemId) do
            local info = fetchItemInfo(id)
            out[id] = (info and info.label) or tostring(id)
        end
        return out
    end

    local info = fetchItemInfo(itemId)
    if info and type(info) == 'table' and info.label then
        DBG.Info('getItemLabel: resolved label for ' .. tostring(itemId) .. ' -> ' .. tostring(info.label))
        return info.label
    end
    if type(info) == 'string' then
        DBG.Info('getItemLabel: resolved label via string response for ' .. tostring(itemId))
        return info
    end

    DBG.Warning('getItemLabel: falling back to raw id for ' .. tostring(itemId))
    return tostring(itemId)
end

-- Return full item data shape for a single id or a table of ids
local function getItemData(itemId)
    if not itemId then return nil end
    if type(itemId) == 'table' then
        DBG.Info('getItemData: batch request for ' .. tostring(#itemId) .. ' ids')
        local out = {}
        for _, id in ipairs(itemId) do
            out[id] = getItemData(id)
        end
        return out
    end
    local info = fetchItemInfo(itemId)
    if info and type(info) == 'table' then
        DBG.Info('getItemData: returning detailed data for ' .. tostring(itemId))
        return info
    end

    DBG.Warning('getItemData: no data found for ' .. tostring(itemId) .. ' — returning minimal fallback')
    return { id = itemId, label = tostring(itemId), name = tostring(itemId), metadata = {}, group = 0, type = 'item', count = 0, limit = 0, canUse = false, weight = 0, desc = '', percentage = 0 }
end

-- Expose globally for other server files loaded after this file
BccTrainItemUtils = {
    fetchItemInfo = fetchItemInfo,
    getItemLabel = getItemLabel,
    getItemData = getItemData
}
