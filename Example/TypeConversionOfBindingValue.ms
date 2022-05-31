/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of type conversion of binding values.
*/
/* Mwm's domain */
(
  /* Create ViewModel Property */
  local countProperty = ::mwm.CreateProperty #Count 0

  /* Define View */
  rollout RltMain "TypeConversionOfBindingValue" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #TypeConversionOfBindingValueViewModel

    editText EdtCounter "Counter"

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

        /* Define converter */
        local countConverter = ::mwm.CreateConverter \
            (fn integerAsString input = input as String) \
            (fn stringToInteger input = input as Integer)

        /* or use preset converter */
        -- local countConverter = ::mwm.GetConverter #IntegerToString

        /* Data Binding */
        local countBinding = ::mwm.CreatePropertyBinding 1 #Count EdtCounter #Text #Entered
        countBinding.SetConverter countConverter
        DataContext.SetBinding countBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on EdtCounter Entered v do EventNotify EdtCounter #Entered #(v)
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #TypeConversionOfBindingValueViewModel
  viewModel.AddProperty countProperty
  viewModel.AddProperty lockProperty
  viewModel.AddCommand incrementCommand
  viewModel.AddCommand decrementCommand

  /* Build Application */
  global typeConversionOfBindingValueApplication = ::mwm.CreateApplication \
      #TypeConversionOfBindingValueApplication #RltMain
  ::typeConversionOfBindingValueApplication.AddView view
  ::typeConversionOfBindingValueApplication.AddViewModel viewModel

  /* Running Application */
  ::typeConversionOfBindingValueApplication.Run()

  /* Direct operation */
  /*
  (::typeConversionOfBindingValueApplication.GetViewModel #TypeConversionOfBindingValueViewModel).GetPropertyValue #Count
  (::typeConversionOfBindingValueApplication.GetViewModel #TypeConversionOfBindingValueViewModel).SetPropertyValue #Count 99
  */

  /* Shutdown Application */
  /*
  ::typeConversionOfBindingValueApplication.Shutdown()
  */
  ok
)
