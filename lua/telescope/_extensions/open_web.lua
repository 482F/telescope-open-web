return require('telescope').register_extension({
  setup = function(ext_config, config)
    require('open-web').setup({ ext_config = ext_config, config = config })
  end,
  exports = require('open-web'),
})
