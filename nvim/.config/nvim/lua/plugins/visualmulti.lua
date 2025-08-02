return {
  'mg979/vim-visual-multi',
  branch = 'master',
  -- lazy = false,
  init = function()
    vim.g.VM_leader = '<Space>'
    vim.g.VM_default_mappings = 0

    vim.g.VM_maps = {
      ['Start Regex Search'] = '',
      ['Find Under']         = '<C-d>',
      ['Add Cursor Up']      = '<M-k>',
      ['Add Cursor Down']    = '<M-j>',
      ['Find Subword Under'] = '<C-d>',
      ['Select All']         = '<Space>a',
      ['Visual Add']         = '<Space>v',
      ['Visual All']         = '<Space>A',
      ['Skip Region']        = '<Space>q',
      ['Remove Region']      = '<Space>Q',
      ['Merge Region']      = '',
    }
  end
}
