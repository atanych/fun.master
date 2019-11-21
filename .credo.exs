%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "test/"],
        excluded: [~r"/_build/", ~r"/deps/", ~r"/node_modules/"]
      },
      strict: false,
      color: true,
      checks: [
        {Credo.Check.Design.AliasUsage, false},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Readability.LargeNumbers, [only_greater_than: 999]},
        {Credo.Check.Readability.MaxLineLength, [priority: :low, max_length: 120]},
        {Credo.Check.Readability.UnnecessaryAliasExpansion, false},
        {Credo.Check.Refactor.MapInto, false},
        {Credo.Check.Warning.IoInspect, false},
        {Credo.Check.Warning.LazyLogging, false},
        {Credo.Check.Readability.SinglePipe, []},
        {Credo.Check.Refactor.AppendSingleItem, []},
        {Credo.Check.Refactor.PipeChainStart, []},
        {Credo.Check.Warning.MapGetUnsafePass, []}
      ]
    }
  ]
}
