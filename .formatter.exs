[
  import_deps: [:ecto, :phoenix],
  line_length: 120,
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"],
  locals_without_parens: [
    import_fields: :*,
    import_types: :*,
    field: :*,
    resolve: :*,
    arg: :*,
    puts: :*,
    defenum: :*,
    attributes: :*,
    meta: :*,
    assert_raise: :*
  ]
]
