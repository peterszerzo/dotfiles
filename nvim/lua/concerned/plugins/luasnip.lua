return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	config = function()
		local ls = require("luasnip")

		local fmt = require("luasnip.extras.fmt").fmt
		local s = ls.s
		local t = ls.text_node
		local i = ls.insert_node
		local c = ls.choice_node
		local rep = require("luasnip.extras").rep

		ls.config.set_config({
			history = true,
			updateevents = "TextChanged,TextChangedI",
		})

		ls.setup()

		vim.keymap.set({ "i" }, "<C-K>", function()
			ls.expand()
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-L>", function()
			ls.jump(1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-J>", function()
			ls.jump(-1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-E>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true })

		ls.add_snippets("elm", {
			s({ trig = "todo", name = "TODO comment" }, fmt("-- TODO: {}", { i(1) })),
			s(
				{ trig = "hn", name = "HTML node" },
				fmt('H.{} [ HA.className "{}" ] [ H.text "{}" ]', {
					i(1, "div"),
					i(2),
					i(3),
				})
			),
			s(
				{ trig = "dbb", name = "Design System BasicButton" },
				fmt(
					[[
                                            BasicButton.{}
                                              [ BasicButton.{}
                                              , BasicButton.onClick <| Debug.todo ""
                                              , BasicButton.linkTo "https://"
                                              , Attr.if_ False BasicButton.padded
                                              , Attr.if_ False BasicButton.activated
                                              ]
                                              {{ label = "{}"
                                              , icon = Ui.Icons.{}
                                              }}
                                        ]],
					{
						c(1, { t("accent"), t("primary80"), t("primary60"), t("error") }),
						c(2, { t("small"), t("medium"), t("large") }),
						i(3),
						i(4),
					}
				)
			),
		})

		ls.add_snippets("typescriptreact", {
			s({ trig = "todo", name = "TODO comment" }, fmt("// TODO: {}", { i(1) })),
			s(
				{ trig = "rc", name = "React component" },
				fmt(
					[[
                                          interface {}Props {{
                                          }}

                                          const {}: FC<{}Props> = (props) => {{
                                            return (
                                              <div className="{}">
                                              </div>
                                            );
                                          }};
                                        ]],
					{
						i(1, "MyComponent"),
						rep(1),
						rep(1),
						i(2),
					}
				)
			),
		})
	end,
}
