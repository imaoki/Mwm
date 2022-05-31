/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of saving settings to a file.
*/
/* Define Model */
struct SaveSettingsToFileStruct (
  /*- @prop <Integer> */
  private count = 0,

  /*
  public fn GetCount = (),
  public fn Load config = (),
  public fn Save config = (),
  public fn SetCount input = (),

  private fn isValidConfig obj = (),
  */

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
      local table = config.GetValue #SaveSettingsToFile
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
      config.AddValue #SaveSettingsToFile table
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
            #SaveSettingsToFile \
            propertyName:#Count \
            getterName:#GetCount \
            setterName:#SetCount
      )

  /* Define View */
  rollout RltMain "SaveSettingsToFile" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #SaveSettingsToFileViewModel

    editText EdtCount "Count"

    /*-
    @param control <RolloutClass|RolloutControl|RCMenu|MenuItem>
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
        local countBinding = ::mwm.CreatePropertyBinding 1 #Count EdtCount #Text #Entered
        countBinding.SetConverter (::mwm.GetConverter #IntegerToString)
        DataContext.SetBinding countBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on EdtCount Entered v do EventNotify EdtCount #Entered #(v)
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]

  /* Create Model Instance */
  global saveSettingsToFileModel = ::SaveSettingsToFileStruct()

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #SaveSettingsToFileViewModel
  viewModel.AddModel #SaveSettingsToFile ::saveSettingsToFileModel
  viewModel.AddProperty countProperty

  /* Build Application */
  /*
  Specifying applicationFile will save to the configuration file.
  */
  global saveSettingsToFileApplication = ::mwm.CreateApplication \
      #SaveSettingsToFileApplication #RltMain applicationFile:(getSourceFileName())
  ::saveSettingsToFileApplication.AddModel #SaveSettingsToFile ::saveSettingsToFileModel
  ::saveSettingsToFileApplication.AddView view
  ::saveSettingsToFileApplication.AddViewModel viewModel

  /* Running Application */
  ::saveSettingsToFileApplication.Run()

  /* Direct operation */
  /*
  ::saveSettingsToFileModel.GetCount()
  ::saveSettingsToFileModel.SetCount 99
  (::saveSettingsToFileApplication.GetViewModel #SaveSettingsToFileViewModel).GetPropertyValue #Count
  */

  /* Shutdown Application */
  /*
  ::saveSettingsToFileApplication.Shutdown()
  */
  ok
)
