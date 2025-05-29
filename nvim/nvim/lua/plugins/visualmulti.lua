return {
  'mg979/vim-visual-multi',
  branch = 'master',
  init = function()
    vim.g.VM_leader = '<Space>'
    vim.g.VM_default_mappings = 0

    vim.g.VM_maps = {
      -- Rebind block/column mode (used to be <C-b>)
      ['Start Block'] = '<Space>m',

      -- Remove conflicting default mapping
      ['Start Regex Search'] = '',

      -- Custom bindings
      ['Find Under']         = '<C-d>',
      ['Find Subword Under'] = '<C-d>',
      ['Select All']         = '<Space>a',
      ['Visual Add']         = '<Space>v',
      ['Visual All']         = '<Space>A',
      ['Skip Region']        = '<Space>q',
      ['Remove Region']      = '<Space>Q',
    }
  end
}
