# blink-cmp-supermaven

Blink Cmp Supermaven is a compatibility plugin to make Supermaven compatible with Blink.

Personally I have issues with blink.compat and Supermaven, so I made this plugin based on the internal implementation that Supermaven has of cmp.

## Installation

Add the plugin to your package manager, with [supermaven-nvim](https://github.com/supermaven-inc/supermaven-nvim), and enable it in the plugins in blink.

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
  'saghen/blink.cmp',
  dependencies = {
    {
      "supermaven-inc/supermaven-nvim",
      opts = {
        disable_inline_completion = true, -- disables inline completion for use with cmp
        disable_keymaps = true            -- disables built in keymaps for more manual control
      }
    },
    {
      "huijiro/blink-cmp-supermaven"
    },
  },
  opts = {
    sources = {
      default = { "lsp", 'path', "supermaven", "snippets", 'buffer' },
      providers = {
        supermaven = {
          name = 'supermaven',
          module = "blink-cmp-supermaven",
          async = true
        }
      }
    },
  }
}
```
