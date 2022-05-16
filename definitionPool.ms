/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
global mwmDefinitionPool = Dictionary #String
/* 依存無し */
::mwmDefinitionPool[@"Model\MwmBinding.ms"] = fileIn @"Model\MwmBinding.ms"
::mwmDefinitionPool[@"Model\MwmCommand.ms"] = fileIn @"Model\MwmCommand.ms"
::mwmDefinitionPool[@"Model\MwmCondition.ms"] = fileIn @"Model\MwmCondition.ms"
::mwmDefinitionPool[@"Model\MwmConverter.ms"] = fileIn @"Model\MwmConverter.ms"
::mwmDefinitionPool[@"Model\MwmEvent.ms"] = fileIn @"Model\MwmEvent.ms"
::mwmDefinitionPool[@"Model\MwmModelAttribute.ms"] = fileIn @"Model\MwmModelAttribute.ms"
::mwmDefinitionPool[@"Model\MwmProperty.ms"] = fileIn @"Model\MwmProperty.ms"
::mwmDefinitionPool[@"Model\MwmViewModel.ms"] = fileIn @"Model\MwmViewModel.ms"
/*
MwmBinding.ms
MwmCommand.ms
MwmModelAttribute.ms
MwmProperty.ms
*/
::mwmDefinitionPool[@"Model\MwmApplication.ms"] = fileIn @"Model\MwmApplication.ms"

::mwmDefinitionPool
