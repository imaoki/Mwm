/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of binding to model.
*/
/* Define Model */
struct FilteringInputValuesStruct (
  /*- @prop <Integer> */
  private count = 0,

  /*-
  @returns <Integer>
  */
  public fn GetCount = (
    this.count
  ),

  /*-
  @param input <Integer>
  @returns <Integer>
  */
  public fn SetCount input = (
    if classOf input == Integer and mod input 2 == 0 do (
      this.count = input
      this.StateChanged.Notify #Count this.count
    )
    this.GetCount()
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
            #FilteringInputValues \
            propertyName:#Count \
            getterName:#GetCount \
            setterName:#SetCount
      )

  /* Define View */
  rollout RltMain "FilteringInputValues" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #FilteringInputValuesViewModel

    editText EdtCount "Count"
    label Lbl "even-numbered only"

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
  global filteringInputValuesModel = ::FilteringInputValuesStruct()

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #FilteringInputValuesViewModel
  viewModel.AddModel #FilteringInputValues ::filteringInputValuesModel
  viewModel.AddProperty countProperty

  /* Build Application */
  global filteringInputValuesApplication = ::mwm.CreateApplication \
      #FilteringInputValuesApplication #RltMain
  ::filteringInputValuesApplication.AddModel #FilteringInputValues ::filteringInputValuesModel
  ::filteringInputValuesApplication.AddView view
  ::filteringInputValuesApplication.AddViewModel viewModel

  /* Running Application */
  ::filteringInputValuesApplication.Run()

  /* Direct operation */
  /*
  ::filteringInputValuesModel.GetCount()
  ::filteringInputValuesModel.SetCount 3
  ::filteringInputValuesModel.SetCount 4
  (::filteringInputValuesApplication.GetViewModel #FilteringInputValuesViewModel).GetPropertyValue #Count
  */

  /* Shutdown Application */
  /*
  ::filteringInputValuesApplication.Shutdown()
  */
  ok
)
