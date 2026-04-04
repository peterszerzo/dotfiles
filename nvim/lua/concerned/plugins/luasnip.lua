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

		vim.keymap.set({ "i" }, "<C-k>", function()
			ls.expand()
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-l>", function()
			ls.jump(1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-j>", function()
			ls.jump(-1)
		end, { silent = true })

		vim.keymap.set({ "i", "s" }, "<C-h>", function()
			if ls.choice_active() then
				ls.change_choice(1)
			end
		end, { silent = true })

		ls.add_snippets("elm", {
			s({ trig = "todo", name = "TODO comment" }, fmt("-- TODO: {}", { i(1) })),
			s(
				{ trig = "hn", name = "HTML node" },
				fmt('H.{} [ HA.class "{}" ] [ H.text "{}" ]', {
					i(1, "div"),
					i(2),
					i(3),
				})
			),
			s(
				{ trig = "nlxnode", name = "NLX node" },
				fmt(
					[[
module Flow.NodeType.{} exposing ({}Payload, emptyPayload, encode, decoder, view)

import Flow.SimpleContext exposing (SimpleContext)
import Domain.Placeholder as Placeholder
import Html as H
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Json.Encode as Encode
import Schema exposing (Schema)
import Ui.Inputs.Label as Label
import Ui.Inputs.Text as Text
import Ui.Sidebar.Block as SidebarBlock


type alias {}Payload =
    {{ {} : String }}


emptyPayload : {}Payload
emptyPayload =
    {{ {} = "" }}


encode : {}Payload -> Encode.Value
encode {{ {} }} =
    Encode.object [ ( "{}", Encode.string {} ) ]


decoder : Decode.Decoder {}Payload
decoder =
    Decode.succeed {}Payload
        |> Pipeline.required "{}" Decode.string


view :
    {{ context : SimpleContext a
    , payload : {}Payload
    , localVariables : List ( String, Schema )
    , onChange : {}Payload -> msg
    }}
    -> List (H.Html msg)
view {{ context, payload, localVariables, onChange }} =
    let
        placeholders =
            Placeholder.allFromContext context
                {{ localVariables = localVariables
                , fields = []
                , includeComplexDataTypes = False
                }}
    in
    [ SidebarBlock.view []
        [ Text.text 
            [ Text.placeholders placeholders
            , Text.placeholder "Enter value"
            , Text.onChange (\val -> onChange {{ payload | {} = val }})
            ] 
            payload.{}
            |> Label.top [ Label.tooltip "I am going to be very helpful" ] "Field label"
        ]
    ]
                                ]],
					{
						i(1),
						rep(1),
						rep(1),
						i(2),
						rep(1),
						rep(2),
						rep(1),
						rep(2),
						rep(2),
						rep(2),
						rep(1),
						rep(1),
						rep(2),
						rep(1),
						rep(1),
						rep(2),
						rep(2),
					}
				)
			),
			s(
				{ trig = "dbb", name = "Design System BasicButton" },
				fmt(
					[[
                                            BasicButton.{}
                                              [ BasicButton.{}
                                              , BasicButton.{} <| Debug.todo ""
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
						c(3, { t("onClick"), t("linkTo") }),
						i(4),
						i(5, "add"),
					}
				)
			),
			s(
				{ trig = "dmb", name = "Design System MainButton" },
				fmt(
					[[
                                            MainButton.{}
                                              [ MainButton.{} <| Debug.todo ""
                                              ]
                                              "{}"
                                        ]],
					{
						c(1, { t("regular"), t("danger") }),
						c(2, { t("onClick"), t("linkTo") }),
						i(3),
					}
				)
			),
		})

		ls.add_snippets("typescriptreact", {
			s({ trig = "todo", name = "TODO comment" }, fmt("// TODO: {}", { i(1) })),
			s(
				{ trig = "cattr", name = "Custom element attribute" },
				fmt(
					[[
    #{}!: {};

    get {}(): {} {{
      return this.#{};
    }}

    set {}(val: {}) {{
      if (!equals(this.#{}, val)) {{
        this.#{} = val;
        this.scheduleUpdate();
      }}
    }}
                        ]],
					{ i(1), i(2), rep(1), rep(2), rep(1), rep(1), rep(2), rep(1), rep(1) }
				)
			),
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
