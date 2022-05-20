/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of binding to command.
*/
/* Mwm's domain */
(
  /* Create ViewModel Command */
  local printCommand = ::mwm.CreateCommand #Print \
      executeFunction:(
        fn executePrint model params event = (
          format "hello, world!\n"
        )
      )

  /* Define View */
  rollout RltMain "BindingToCommand" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #BindingToCommandViewModel

    button BtnPrint "Print"

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
        local printBinding = ::mwm.CreateCommandBinding #Print BtnPrint #Pressed
        DataContext.SetBinding printBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on BtnPrint Pressed do EventNotify BtnPrint #Pressed #()
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #BindingToCommandViewModel
  viewModel.AddCommand printCommand

  /* Build Application */
  global bindingToCommandApplication = ::mwm.CreateApplication \
      #BindingToCommandApplication #RltMain
  ::bindingToCommandApplication.AddView view
  ::bindingToCommandApplication.AddViewModel viewModel

  /* Running Application */
  ::bindingToCommandApplication.Run()

  /* Direct operation */
  /*
  (::bindingToCommandApplication.GetViewModel #BindingToCommandViewModel).ExecuteCommand #Print
  */

  /* Shutdown Application */
  /*
  ::bindingToCommandApplication.Shutdown()
  */
  ok
)
