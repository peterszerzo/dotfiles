return {
	"L3MON4D3/LuaSnip",
	version = "v2.*",
	build = "make install_jsregexp",
	event = "InsertEnter",
	config = function()
		local ls = require("luasnip")

		local fmt = require("luasnip.extras.fmt").fmt
		local s = ls.s
		local t = ls.text_node
		local i = ls.insert_node
		local c = ls.choice_node
		local rep = require("luasnip.extras").rep

		-- One call only: `set_config` rebuilds from the defaults every time, so a
		-- bare `ls.setup()` after this would throw all of it away again.
		ls.setup({
			history = true,
			update_events = "TextChanged,TextChangedI",
		})

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
			s(
				{ trig = "page", name = "elm-spa page skeleton" },
				fmt(
					[[
module Pages.{} exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html as H
import Shared
import Spa.Page
import Translations
import User exposing (UserContext)
import View exposing (View)


page : Shared.Model -> UserContext -> Spa.Page.Page () Shared.Msg (View Msg) Model Msg
page shared userContext =
    Spa.Page.element
        {{ init = init userContext shared
        , update = update userContext shared
        , view = view shared
        , subscriptions = subscriptions
        }}


type alias Model =
    {{ {} }}


type Msg
    = {}


init : UserContext -> Shared.Model -> () -> ( Model, Effect Msg )
init userContext shared () =
    ( {{ {} }}, Effect.none )


update : UserContext -> Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update userContext shared msg model =
    case msg of
        {} ->
            ( model, Effect.none )


view : Shared.Model -> Model -> View Msg
view shared model =
    View.page
        {{ title = Translations.{} shared.i18n
        , body = [ {} ]
        }}


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
                    ]],
					{
						i(1, "MyPage"),
						i(2, "placeholder : ()"),
						i(3, "NoOp"),
						i(4, "placeholder = ()"),
						rep(3),
						i(5, "myPage"),
						i(6),
					}
				)
			),
			s(
				{ trig = "hget", name = "Api GET request" },
				fmt(
					[[
{} :
    Shared.Context a b
    -> (Shared.Response {} -> msg)
    -> Cmd msg
{} =
    Http.Request.get
        {{ path = [ "{}" ]
        , query = []
        , decoder = {}
        }}
                    ]],
					{ i(1, "all"), i(2), rep(1), i(3), i(4, "decoder") }
				)
			),
			s(
				{ trig = "hput", name = "Api PUT/POST request" },
				fmt(
					[[
{} :
    Shared.Context a b
    -> {}
    -> (Shared.Response {} -> msg)
    -> Cmd msg
{} =
    Http.Request.{}
        {{ path = [ "{}" ]
        , query = []
        , encode = {}
        , decoder = {}
        }}
                    ]],
					{
						i(1, "create"),
						i(2),
						rep(2),
						rep(1),
						c(3, { t("put"), t("post") }),
						i(4),
						i(5, "encode"),
						i(6, "decoder"),
					}
				)
			),
			s(
				{ trig = "dec", name = "Record decoder (pipeline)" },
				fmt(
					[[
decoder : Decode.Decoder {}
decoder =
    Decode.succeed {}
        |> Pipeline.required "{}" Decode.{}
                    ]],
					{ i(1), rep(1), i(2), c(3, { t("string"), t("bool"), t("int"), t("float") }) }
				)
			),
			s(
				{ trig = "pr", name = "Pipeline.required" },
				fmt('|> Pipeline.required "{}" {}', { i(1), i(2, "Decode.string") })
			),
			s(
				{ trig = "po", name = "Pipeline.optional" },
				fmt('|> Pipeline.optional "{}" {} {}', { i(1), i(2, "Decode.string"), i(3, '""') })
			),
			s(
				{ trig = "enc", name = "Record encoder" },
				fmt(
					[[
encode : {} -> Encode.Value
encode {} =
    Encode.object
        [ ( "{}", Encode.string {}.{} )
        ]
                    ]],
					{ i(1), i(2), i(3), rep(2), rep(3) }
				)
			),
			s(
				{ trig = "decvar", name = "Custom type decoder" },
				fmt(
					[[
{}Decoder : Decode.Decoder {}
{}Decoder =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "{}" ->
                        Decode.succeed {}

                    _ ->
                        Decode.fail ("Unknown {}: " ++ str)
            )
                    ]],
					{ i(1), i(2), rep(1), i(3), i(4), rep(2) }
				)
			),
			s(
				{ trig = "apiview", name = "Api.Data.view" },
				fmt(
					[[
Api.Data.view []
    {{ i18n = i18n, singular = Translations.{} i18n, plural = Translations.{} i18n }}
    model.{}
    (\{} ->
        {}
    )
                    ]],
					{ i(1), i(2), i(3), i(4, "data"), i(5) }
				)
			),
			s(
				{ trig = "tbl", name = "Ui.Table.view" },
				fmt(
					[[
Ui.Table.view []
    {{ i18n = i18n
    , data = {}
    , cells =
        [ {{ label = Translations.{} i18n
          , view = \{} -> H.text {}.{}
          , sortConfig = Nothing
          }}
        ]
    , cellClickHandler = \_ -> Ui.Table.NoHandler
    , select = Nothing
    , sort = Nothing
    }}
                    ]],
					{ i(1), i(2), i(3, "row"), rep(3), i(4) }
				)
			),
			s(
				{ trig = "tcol", name = "Ui.Table column" },
				fmt(
					[[
{{ label = Translations.{} i18n
, view = \{} -> H.text {}.{}
, sortConfig = Nothing
}}
                    ]],
					{ i(1), i(2, "row"), rep(2), i(3) }
				)
			),
			s(
				{ trig = "desc", name = "Test suite" },
				fmt(
					[[
{} : Test
{} =
    describe "{}"
        [ {}
        ]
                    ]],
					{ i(1, "suite"), rep(1), i(2), i(3) }
				)
			),
			s(
				{ trig = "tst", name = "Test case" },
				fmt(
					[[
test "{}" <|
    \_ ->
        {}
                    ]],
					{ i(1), i(2) }
				)
			),
			s(
				{ trig = "fz", name = "Fuzz test" },
				fmt(
					[[
fuzz {} "{}" <|
    \{} ->
        {}
                    ]],
					{ i(1, "fuzzer"), i(2), i(3, "value"), i(4) }
				)
			),
			s(
				{ trig = "qh", name = "Test.Html query" },
				fmt(
					[[
{}
    |> Query.fromHtml
    |> Query.find [ Selector.{} ]
    |> Query.has [ Selector.{} ]
                    ]],
					{ i(1), i(2, 'tag "button"'), i(3) }
				)
			),
			s(
				{ trig = "track", name = "Ports.track event" },
				fmt(
					[[
Ports.track
    [ Tracking.property "{}" {} ]
    "{}"
    |> Effect.fromCmd
                    ]],
					{ i(1), i(2), i(3) }
				)
			),
			s(
				{ trig = "notify", name = "Notify.success" },
				fmt("Notify.success [] (Ui.Copy.{} (Translations.{} i18n))", {
					c(1, { t("createSuccess"), t("updateSuccess"), t("deleteSuccess") }),
					i(2),
				})
			),
			s(
				{ trig = "apierr", name = "Notify.apiError" },
				fmt("Notify.apiError i18n (Ui.Copy.{} (Translations.{} i18n)) {}", {
					c(1, { t("createError"), t("updateError"), t("deleteError") }),
					i(2),
					i(3, "err"),
				})
			),
			s(
				{ trig = "can", name = "Permission check" },
				fmt("Api.Role.can Permission.{} {}", { i(1), i(2, "shared.role") })
			),
			s({ trig = "tr", name = "Translation lookup" }, fmt("Translations.{} i18n", { i(1) })),
		})

		ls.filetype_extend("typescriptreact", { "typescript" })

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
				{ trig = "ce", name = "Custom element (fill props with cattr)" },
				fmt(
					[[
customElements.define(
  "{}",
  class extends ReactCustomElement {{
    {}

    render(): ReactNode {{
      return <div />;
    }}
  }},
);
                    ]],
					{ i(1), i(2) }
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
