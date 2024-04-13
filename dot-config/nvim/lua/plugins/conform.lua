return {
  {
    "stevearc/conform.nvim",

    opts = function()
      local opts = {
        formatters_by_ft = {
          typescript = { "prettier" },
        },
      }
      return opts
    end,
  },
}
