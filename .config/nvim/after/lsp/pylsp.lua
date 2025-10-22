return {
	settings = {
		pylsp = {
			plugins = {
				pycodestyle = {
					ignore = { "W391", "W503", "E501" },
					maxLineLength = 100,
				},
			},
		},
	},
}
