/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
/*
Example of menu bar.
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

  /* Create ViewModel Command */
  local printCommand = ::mwm.CreateCommand #Print \
      executeFunction:(
        fn executePrint model params event = (
          format "hello, world!\n"
        )
      ) \
      canExecuteCondition:enabledCondition

  /* Define Menu */
  rcMenu MnuMain (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #MenuBarViewModel

    subMenu "Command" (
      menuItem MiPrint "Print"
    )

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
        local printBinding = ::mwm.CreateCommandBinding #Print MiPrint #Picked
        DataContext.SetBinding printBinding
      )
      EventNotify MnuMain #Open #()
      ok
    )

    on MiPrint Picked do EventNotify MiPrint #Picked #()
  )

  /* Define View */
  rollout RltMain "MenuBar" (
    /* Specify the name of the corresponding ViewModel */
    local DataContext = #MenuBarViewModel

    checkBox CkbxEnabled "Enabled"
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
        local enabledBinding = ::mwm.CreatePropertyBinding 1 #Enabled CkbxEnabled #Checked #Changed
        local printBinding = ::mwm.CreateCommandBinding #Print BtnPrint #Pressed
        DataContext.SetBinding enabledBinding
        DataContext.SetBinding printBinding
      )
      EventNotify RltMain #Open #()
      ok
    )

    on RltMain Close do EventNotify RltMain #Close #()
    on RltMain Moved v do EventNotify RltMain #Moved #(v)
    on RltMain Resized v do EventNotify RltMain #Resized #(v)

    on CkbxEnabled Changed v do EventNotify CkbxEnabled #Changed #(v)
    on BtnPrint Pressed do EventNotify BtnPrint #Pressed #()
  )

  /* Create View Instance */
  local view = ::std.DialogStruct RltMain [160, 160]

  /* SetMenu */
  view.SetMenuDef MnuMain

  /* Build ViewModel */
  local viewModel = ::mwm.CreateViewModel #MenuBarViewModel
  viewModel.AddProperty enabledProperty
  viewModel.AddCommand printCommand

  /* Build Application */
  global menuBarApplication = ::mwm.CreateApplication \
      #MenuBarApplication #RltMain
  ::menuBarApplication.AddView view
  ::menuBarApplication.AddViewModel viewModel

  /* Running Application */
  ::menuBarApplication.Run()

  /* Direct operation */
  /*
  (::menuBarApplication.GetViewModel #MenuBarViewModel).GetPropertyValue #Enabled
  (::menuBarApplication.GetViewModel #MenuBarViewModel).SetPropertyValue #Enabled false
  (::menuBarApplication.GetViewModel #MenuBarViewModel).ExecuteCommand #Print
  */

  /* Shutdown Application */
  /*
  ::menuBarApplication.Shutdown()
  */
  ok
)
