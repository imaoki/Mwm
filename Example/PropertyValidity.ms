/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of switching property validity.
*/
/* Mwm's domain */
(
  /* Create Condition */
  local enabledCondition = ::mwm.CreateCondition evaluator:(
    fn enabledEvaluator params = (
      params.Count == 1 and params[1].Name == #Enabled and params[1].Value
    )
  )

  /* Create ViewModel Property */
  local enabledProperty = ::mwm.CreateProperty #Enabled true
  enabledCondition.AddProperty enabledProperty
  local textProperty = ::mwm.CreateProperty #Text "hello, world!"

  /* Set Condition */
  textProperty.SetEnabledCondition enabledCondition

  /* Define View */
  rollout RltMain "PropertyValidity" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #PropertyValidityViewModel

    checkBox CkbxEnabled "Enabled"
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
        local enabledBinding = ::mwm.CreatePropertyBinding 1 #Enabled CkbxEnabled #Changed #Checked
        local textBinding = ::mwm.CreatePropertyBinding 1 #Text EdtText #Entered #Text
        DataContext.SetBinding enabledBinding
        DataContext.SetBinding textBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on CkbxEnabled Changed v do EventNotify CkbxEnabled #Changed #(v)
    on EdtText Entered v do EventNotify EdtText #Entered #(v)
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #PropertyValidityViewModel
  viewModel.AddProperty enabledProperty
  viewModel.AddProperty textProperty

  /* Build Application */
  global propertyValidityApplication = ::mwm.CreateApplication \
      #PropertyValidityApplication #RltMain
  ::propertyValidityApplication.AddView view
  ::propertyValidityApplication.AddViewModel viewModel

  /* Running Application */
  ::propertyValidityApplication.Run()

  /* Direct operation */
  /*
  (::propertyValidityApplication.GetViewModel #PropertyValidityViewModel).GetPropertyValue #Enabled
  (::propertyValidityApplication.GetViewModel #PropertyValidityViewModel).SetPropertyValue #Enabled false
  (::propertyValidityApplication.GetViewModel #PropertyValidityViewModel).GetPropertyValue #Text
  (::propertyValidityApplication.GetViewModel #PropertyValidityViewModel).SetPropertyValue #Text "source to target"
  */

  /* Shutdown Application */
  /*
  ::propertyValidityApplication.Shutdown()
  */
  ok
)
