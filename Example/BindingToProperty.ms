/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of binding to property.
*/
/* Mwm's domain */
(
  /* Create ViewModel Property */
  local textProperty = ::mwm.CreateProperty #Text "hello, world!"

  /* Define View */
  rollout RltMain "BindingToProperty" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #BindingToPropertyViewModel

    editText EdtText "Text"

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
        local textBinding = ::mwm.CreatePropertyBinding 1 #Text EdtText #Text #Entered
        DataContext.SetBinding textBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on EdtText Entered v do EventNotify EdtText #Entered #(v)
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #BindingToPropertyViewModel
  viewModel.AddProperty textProperty

  /* Build Application */
  global bindingToPropertyApplication = ::mwm.CreateApplication \
      #BindingToPropertyApplication #RltMain
  ::bindingToPropertyApplication.AddView view
  ::bindingToPropertyApplication.AddViewModel viewModel

  /* Running Application */
  ::bindingToPropertyApplication.Run()

  /* Direct operation */
  /*
  (::bindingToPropertyApplication.GetViewModel #BindingToPropertyViewModel).GetPropertyValue #Text
  (::bindingToPropertyApplication.GetViewModel #BindingToPropertyViewModel).SetPropertyValue #Text "source to target"
  */

  /* Shutdown Application */
  /*
  ::bindingToPropertyApplication.Shutdown()
  */
  ok
)
