/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of binding to model.
*/
/* Define Model */
struct BindingToModelStruct (
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
    if classOf input == Integer do (
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
            #BindingToModel \
            propertyName:#Count \
            getterName:#GetCount \
            setterName:#SetCount
      )

  /* Define View */
  rollout RltMain "BindingToModel" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #BindingToModelViewModel

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
  global bindingToModelModel = ::BindingToModelStruct()

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #BindingToModelViewModel
  viewModel.AddModel #BindingToModel ::bindingToModelModel
  viewModel.AddProperty countProperty

  /* Build Application */
  global bindingToModelApplication = ::mwm.CreateApplication \
      #BindingToModelApplication #RltMain
  ::bindingToModelApplication.AddModel #BindingToModel ::bindingToModelModel
  ::bindingToModelApplication.AddView view
  ::bindingToModelApplication.AddViewModel viewModel

  /* Running Application */
  ::bindingToModelApplication.Run()

  /* Direct operation */
  /*
  ::bindingToModelModel.GetCount()
  ::bindingToModelModel.SetCount 99
  (::bindingToModelApplication.GetViewModel #BindingToModelViewModel).GetPropertyValue #Count
  */

  /* Shutdown Application */
  /*
  ::bindingToModelApplication.Shutdown()
  */
  ok
)
