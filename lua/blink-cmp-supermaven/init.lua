--- @module 'blink-cmp'

local CompletionPreview = require('supermaven-nvim.completion_preview')
local u = require('supermaven-nvim.util')

local loop = u.uv


--- @class blink-supermaven : blink.cmp.Source
--- @field client vim.lsp.Client | nil
local source = {
  executions = {}
}



local function set_client()
  require('supermaven-nvim')


  local clients = vim.lsp.get_clients({
    name = 'supermaven'
  })

  source.client = clients[1]
end


--- Create a new instance of the completion provider
function source:new()
  set_client()
  return setmetatable({
    timer = loop.new_timer()
  }, {
    __index = source
  })
end

function source:enabled()
  return true
end

function source:get_trigger_characters()
  return { "*" }
end

function source:resolve(item, callback)
  for _, fn in ipairs(self.executions) do
    item = fn(item)
  end

  callback(item)
end

local label_text = function(text)
  local shorten = function(str)
    local short_prefix = string.sub(str, 0, 20)
    local short_suffix = string.sub(str, string.len(str) - 15, string.len(str))
    local delimiter = " ... "
    return short_prefix .. delimiter .. short_suffix
  end

  text = text:gsub("^%s*", "")
  return string.len(text) > 40 and shorten(text) or text
end


---@param context blink.cmp.Context
function source:get_completions(context, callback)
  local inlay_instance = CompletionPreview:get_inlay_instance()

  if inlay_instance == nil or inlay_instance.is_active == false then
    callback({
      items = {},
      is_incomplete_backward = true,
      is_incomplete_forward = true,
    })
    return
  end


  local completion_text = inlay_instance.line_before_cursor .. inlay_instance.completion_text
  local preview_text = completion_text
  local split = vim.split(completion_text, "\n", { plain = true })
  local label = label_text(split[1])

  local instertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText
  local kind = require('blink.cmp.types').CompletionItemKind.Text

  if #split > 1 then
    instertTextFormat = vim.lsp.protocol.InsertTextFormat.Snippet
    kind = require('blink.cmp.types').CompletionItemKind.Snippet
  end

  local cursor = context.get_cursor()

  -- I don't get why, but line needs a - 1
  local range = {
    start = {
      line = cursor[1] - 1,
      character = math.max(cursor[2] - inlay_instance.prior_delete - #inlay_instance.line_before_cursor - 1, 0),
    },
    ["end"] = {
      line = cursor[1] - 1,
      character = vim.fn.col("$"),
    },
  }

  ---@type blink.cmp.CompletionItem[]
  local items = {
    {
      label = label,
      kind = kind,
      score_offset = 100,
      insertTextFormat = instertTextFormat,
      kind_icon = "󰧑",
      textEdit = {
        newText = completion_text,
        insert = range,
        replace = range,
      },
      documentation = {
        kind = "markdown",
        value = "```" .. vim.bo.filetype .. "\n" .. preview_text .. "\n```",
      }
    }
  }

  return callback({
    items = items,
    is_incomplete_backward = false,
    is_incomplete_forward = false,
  })
end

function source:execute(ctx, item, callback, default_implementatio)
  default_implementatio()
  CompletionPreview:dispose_inlay()

  callback(item)
end

return source
