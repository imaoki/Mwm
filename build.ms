/*! © 2022 imaoki | MIT License | https://github.com/imaoki */
(
  /* 初期化 */
  local mp = ::MxsPackStruct (getSourceFileName())
  /* 出力先ディレクトリ削除 */
  -- mp.DeleteDirectory @".\Distribution"

  /* コード切り出し */
  local definitionPoolCode = mp.ClipFile @".\definitionPool.ms" 1 905
  local generalConverterCode = mp.ClipFile @".\generalConverter.ms" 64 -1
  local MwmCode = mp.ClipFile @".\Mwm.ms" 1 -1

  local MwmApplicationCode = mp.ClipFile @".\Model\MwmApplication.ms" 1827 -1
  local MwmBindingCode = mp.ClipFile @".\Model\MwmBinding.ms" 2203 -1
  local MwmCommandCode = mp.ClipFile @".\Model\MwmCommand.ms" 1400 -1
  local MwmConditionCode = mp.ClipFile @".\Model\MwmCondition.ms" 849 -1
  local MwmConverterCode = mp.ClipFile @".\Model\MwmConverter.ms" 186 -1
  local MwmEventCode = mp.ClipFile @".\Model\MwmEvent.ms" 186 -1
  local MwmModelAttributeCode = mp.ClipFile @".\Model\MwmModelAttribute.ms" 739 -1
  local MwmPropertyCode = mp.ClipFile @".\Model\MwmProperty.ms" 1296 -1
  local MwmViewModelCode = mp.ClipFile @".\Model\MwmViewModel.ms" 908 -1

  /* コード置換 */
  local definitionPoolMergedCode = mp.ReplaceText definitionPoolCode 873 33 MwmApplicationCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 721 31 MwmViewModelCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 642 30 MwmPropertyCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 558 36 MwmModelAttributeCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 477 27 MwmEventCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 401 31 MwmConverterCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 321 31 MwmConditionCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 243 29 MwmCommandCode
  definitionPoolMergedCode = mp.ReplaceText definitionPoolMergedCode 167 29 MwmBindingCode
  definitionPoolMergedCode = mp.ClipText definitionPoolMergedCode 64 -1
  local code = mp.ReplaceText MwmCode 10747 29 generalConverterCode
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
