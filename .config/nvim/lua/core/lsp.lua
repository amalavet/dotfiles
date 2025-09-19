vim.lsp.enable({ "luals" })

vim.cmd[[set completeopt+=menuone,noselect,popup]]
    vim.lsp.start({
      name = 'luals',
      cmd = …,
      on_attach = function(client, bufnr)
        vim.lsp.completion.enable(true, client.id, bufnr, {
          autotrigger = true,
          convert = function(item)
            return { abbr = item.label:gsub('%b()', '') }
          end,
        })
      end,
    })

