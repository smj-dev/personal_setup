return {
  "kylechui/nvim-surround",
  version = "*",
  event = "InsertEndter",
  config = function()
    require("nvim-surround").setup()
  end
}

