/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/* Define Model */
struct SimpleCounterStruct (
  /*- @prop <Integer> */
  private count = 0,

  /*-
  @returns <Integer>
  */
  public fn GetCount = (
    this.count
  ),

  /*-
  @param config <Struct:ConfigStruct>
  @returns <BooleanClass>
  */
  public fn Load config = (
    local isSuccessful = false
    if this.isValidConfig config do (
      local table = config.GetValue #SimpleCounter
      if classOf table == Dictionary do (
        if hasDictValue table #Count do this.SetCount table[#Count]
        isSuccessful = true
      )
    )
    isSuccessful
  ),

  /*-
  @param config <Struct:ConfigStruct>
  @returns <BooleanClass>
  */
  public fn Save config = (
    local isSuccessful = false
    if this.isValidConfig config do (
      local table = Dictionary #Name
      table[#Count] = this.GetCount()
      config.AddValue #SimpleCounter table
      isSuccessful = true
    )
    isSuccessful
  ),

  /*-
  @param input <Integer>
  @returns <Integer>
  */
  public fn SetCount input = (
    if classOf input == Integer do (
      this.count = input
      this.StateChanged.Notify #Count this.count
    )
    this.GetCount()
  ),

  /*-
  @param obj <Any>
  @returns <BooleanClass>
  */
  private fn isValidConfig obj = (
    isStruct obj \
        and isProperty obj #StructName \
        and classOf obj.StructName == MAXScriptFunction \
        and obj.StructName() == #ConfigStruct
  ),

  /*- @prop <Struct:ObservableStruct> */
  public StateChanged,

  on Create do (
    this.StateChanged = ::std.ObservableStruct()
  )
)

/* Mwm's domain */
(
  /* Create ViewModel Property */
  local countProperty = ::mwm.CreateProperty #Count 0 \
      modelAttribute:(
        ::mwm.CreateModelAttribute \
            #SimpleCounter \
            propertyName:#Count \
            getterName:#GetCount \
            setterName:#SetCount
      )

  /* Create ViewModel Command */
  local commandAttribute = ::mwm.CreateModelAttribute #SimpleCounter
  local incrementCommand = ::mwm.CreateCommand #Increment \
      executeFunction:(
        fn executeIncrement model params event = (
          model.SetCount (params[1].Value + 1)
        )
      ) \
      modelAttribute:commandAttribute
  incrementCommand.AddExecuteProperty countProperty

  local decrementCommand = ::mwm.CreateCommand #Decrement \
      executeFunction:(
        fn executeDecrement model params event = (
          model.SetCount (params[1].Value - 1)
        )
      ) \
      modelAttribute:commandAttribute
  decrementCommand.AddExecuteProperty countProperty

  /* Define View */
  rollout RltMain "Counter" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #SimpleCounterViewModel

    editText EdtCounter "Counter"
    button BtnIncrement "+"
    button BtnDecrement "-"

    /*-
    @param control <RolloutClass|RolloutControl>
    @param eventName <Name>
    @param params <Array[<Any>]|Any>
    @returns <OkClass>
    */
    fn EventNotify control eventName params = (
      if ::mwm.IsValidViewModel DataContext do (
        DataContext.RaiseTargetChanged (
          ::mwm.CreateEvent control eventName params
        )
      )
      ok
    )

    /*-
    @param obj <Struct:MwmViewModelStruct>
    @returns <OkClass>
    */
    fn Initialize obj = (
      if ::mwm.IsValidViewModel obj do (
        DataContext = obj

        /* Data Binding */
        local countBinding = ::mwm.CreatePropertyBinding #Count EdtCounter #Entered #Text
        countBinding.SetConverter (
          ::mwm.CreateConverter \
              (fn integerAsString input = input as String) \
              (fn stringToInteger input = input as Integer)
        )
        local incrementBinding = ::mwm.CreateCommandBinding #Increment BtnIncrement #Pressed
        local decrementBinding = ::mwm.CreateCommandBinding #Decrement BtnDecrement #Pressed
        DataContext.SetBinding countBinding
        DataContext.SetBinding incrementBinding
        DataContext.SetBinding decrementBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on EdtCounter Entered v do EventNotify EdtCounter #Entered #(v)
    on BtnIncrement Pressed do EventNotify BtnIncrement #Pressed #()
    on BtnDecrement Pressed do EventNotify BtnDecrement #Pressed #()
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]

  /* Create Model Instance */
  global simpleCounterModel = ::SimpleCounterStruct()

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #SimpleCounterViewModel
  viewModel.AddModel #SimpleCounter ::simpleCounterModel
  viewModel.AddProperty countProperty
  viewModel.AddCommand incrementCommand
  viewModel.AddCommand decrementCommand

  /* Build Application */
  global simpleCounterApplication = ::mwm.CreateApplication \
      #CounterApplication #RltMain applicationFile:(getSourceFileName())
  ::simpleCounterApplication.AddModel #SimpleCounter ::simpleCounterModel
  ::simpleCounterApplication.AddView view
  ::simpleCounterApplication.AddViewModel viewModel

  /* Running Application */
  ::simpleCounterApplication.Run()

  /* Manipulate model values directly */
  /*
  ::simpleCounterModel.SetCount 99
  */

  /* Shutdown Application */
  /*
  ::simpleCounterApplication.Shutdown()
  */
  ok
)