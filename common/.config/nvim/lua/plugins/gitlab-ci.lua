-- GitLab CI/CD Language Server
-- Provides completion, go-to-definition, hover, diagnostics for .gitlab-ci.yml
-- Works alongside yaml-language-server (YAML syntax) + gitlab-ci-ls (GitLab CI semantics)

-- Filetype detection: mark GitLab CI files as yaml.gitlab
vim.filetype.add({
  filename = {
    [".gitlab-ci.yml"] = "yaml.gitlab",
    [".gitlab-ci.yaml"] = "yaml.gitlab",
  },
  pattern = {
    [".*%.gitlab%-ci%.ya?ml"] = "yaml.gitlab",
    [".*%.gitlab/ci/.*%.ya?ml"] = "yaml.gitlab",
  },
})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gitlab_ci_ls = {
          filetypes = { "yaml.gitlab" },
          init_options = {
            cache_path = vim.fn.stdpath("cache") .. "/gitlab-ci-ls/",
            log_path = vim.fn.stdpath("cache") .. "/gitlab-ci-ls/gitlab-ci-ls.log",
          },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gitlab-ci-ls" })
    end,
  },
}
