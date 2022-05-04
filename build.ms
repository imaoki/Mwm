/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  /* 初期化 */
  local mp = ::MxsPackStruct (getSourceFileName())
  /* 出力先ディレクトリ削除 */
  -- mp.DeleteDirectory @".\Distribution"

  /* コード切り出し */
  local definitionPoolCode = mp.ClipFile @".\definitionPool.ms" 1 825
  local generalConverterCode = mp.ClipFile @".\generalConverter.ms" 64 -1
  local MwmCode = mp.ClipFile @".\Mwm.ms" 1 -1

  local MwmApplicationCode = mp.ClipFile @".\Model\MwmApplication.ms" 1775 -1
  local MwmBindingCode = mp.ClipFile @".\Model\MwmBinding.ms" 2011 -1
  local MwmCommandCode = mp.ClipFile @".\Model\MwmCommand.ms" 1629 -1
  local MwmConverterCode = mp.ClipFile @".\Model\MwmConverter.ms" 195 -1
  local MwmEventCode = mp.ClipFile @".\Model\MwmEvent.ms" 195 -1
  local MwmModelAttributeCode = mp.ClipFile @".\Model\MwmModelAttribute.ms" 754 -1
  local MwmPropertyCode = mp.ClipFile @".\Model\MwmProperty.ms" 894 -1
  local MwmViewModelCode = mp.ClipFile @".\Model\MwmViewModel.ms" 917 -1

  /* コード置換 */
  local definitionPoolMergedCode = mp.ReplaceText definitionPoolCode 793 33 MwmApplicationCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 641 31 MwmViewModelCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 562 30 MwmPropertyCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 478 36 MwmModelAttributeCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 397 27 MwmEventCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 321 31 MwmConverterCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 243 29 MwmCommandCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 167 29 MwmBindingCode
  definitionPoolMergedCode = mp.ClipText definitionPoolMergedCode 64 -1
  local code = mp.ReplaceText MwmCode 9310 29 generalConverterCode
  code = mp.ReplaceText code 714 27 definitionPoolMergedCode

  /* インストールコード追加 */
  code = mp.AppendText code "::MwmStruct.Install()\n::MwmStruct\n"
  /* インストーラーオプション削除 */
  code = mp.RemoveInstallerOption code
  /* バンドルファイルを保存 */
  -- mp.WriteAllText @".\Distribution\Mwm.bundle.ms" code
  /* 最小化ファイルを保存 */
  code = mp.Minify code
  mp.WriteAllText @".\Distribution\Mwm.min.ms" code
  /* ファイルコピー */
  -- mp.CopyDirectory @".\Mwm.SubDir" @".\Distribution\Mwm.SubDir"
  ok
)
