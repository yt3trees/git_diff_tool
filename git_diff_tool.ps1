#region パラメータ
$json = Get-Content param.json | ConvertFrom-Json
$proj = $json.proj # プロジェクトフォルダ
#endregion

#region 関数定義
function Git-Diff {
$proj = $InputBoxProj.Text
Set-Location $proj # プロジェクトフォルダをカレントディレクトリに設定

$commit_from = $InputBox.Text # BeforeコミットID
$commit_to = $InputBox2.Text # AfterコミットID

# チェックボックスの内容を取得
if ($ChecktBoxA.Checked -eq $True){
    $filter += "A"
}
if ($ChecktBoxC.Checked -eq $True){
    $filter += "C"
}
if ($ChecktBoxM.Checked -eq $True){
    $filter += "M"
}
if ($ChecktBoxR.Checked -eq $True){
    $filter += "R"
}
if ($ChecktBoxD.Checked -eq $True){
    $filter += "D"
}

    $enc = [Console]::OutputEncoding
    try
    {
        [Console]::OutputEncoding = [Text.Encoding]::UTF8
        $outputBox.Text = git diff --stat --diff-filter=$($filter) $commit_from　$commit_to | Out-String
    }
    finally
    {
        [Console]::OutputEncoding = $enc
    }
}
function Git-Log {
    $proj = $InputBoxProj.Text

    Set-Location $proj

    $enc = [Console]::OutputEncoding
    try
    {
        [Console]::OutputEncoding = [Text.Encoding]::UTF8
        $result = git log -50 --graph --name-status | Out-String
    }
    finally
    {
        [Console]::OutputEncoding = $enc
    }

    $OutputBox2.Text = $result
}
function Save-Param {
    $json = @{
        "proj" = $InputBoxProj.Text
    }
    ConvertTo-Json $json | Out-File param.json -Encoding utf8
    [System.Windows.Forms.MessageBox]::Show('Saved to "param.json".') # メッセージボックスを表示
}
function Folder-Select() {
    # COMオブジェクトの読み込み
    $shell = New-Object -com Shell.Application

    # ダイアログを表示し、結果を変数folderPathに格納する
    $folderPath = $shell.BrowseForFolder(0,"対象フォルダーを選択してください",0,"C:\")

    # キャンセルを選択した場合は終了
    if ($folderPath -eq $Null){return}

    # $folderPath内の情報のうち、パス情報のみを格納する
    $InputBoxProj.text = $folderPath.Self.Path

    # 格納したパスをメッセージボックスで表示
    Add-Type -Assembly System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($folderPath.Self.Path,"処理完了")
}
#endregion

#region フォーム
# アセンブリの読み込み
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# フォント
$Font = New-Object System.Drawing.Font("ＭＳ ゴシック",11)       # ラベルのフォント
$FontTextbox = New-Object System.Drawing.Font("ＭＳ ゴシック",9) # テキストボックスのフォント

# フォーム
$Form = New-Object System.Windows.Forms.Form -Property @{
    Size = "1095,810"
    Text = "git_diff_tool"
    Add_Shown = {$InputBox.Select()} # FromコミットIDテキストボックスにフォーカス
    StartPosition = "CenterScreen"   # 中心に表示する
    #StartPosition = "Manual"        # 表示位置を指定する
    #Location = "0,200"              # 座標
    #Opacity = 0.9                   # 透明度
    #Topmost = $True                 # 最前面固定
}

# パラメータグループ
$MyGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location = "10,10"
    size = "700,50"
    text = "Parameter"
}

# プロジェクトフォルダラベル
$CommitLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = "10,20"
    Size = "120,20"
    Text = "Project Folder:"
    Forecolor = "black"
    Font = $Font
}
$Form.Controls.Add($CommitLabel)

# プロジェクトフォルダテキストボックス
$InputBoxProj = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "130,20"
    Size = "400,20"
    Text = $proj
}
$Form.Controls.Add($InputBoxProj)

# フォルダ選択ボタン
$Button_folder = New-Object System.Windows.Forms.Button -Property @{
    Location = "540,30"
    Size = "55,20"
    Text = "Browse"
    Add_Click = {Folder-Select} # 関数呼び出し
}
$Form.Controls.Add($Button_folder)

# フォルダを開くボタン
$Button_open = New-Object System.Windows.Forms.Button -Property @{
    Location = "590,30"
    Size = "55,20"
    Text = "Open"
    Add_Click = {Invoke-item $InputBoxProj.Text}
}
$Form.Controls.Add($Button_open)

# パラメータ保存ボタン
$Button_parm = New-Object System.Windows.Forms.Button -Property @{
    Location = "645,30"
    Size = "55,20"
    Text = "Save"
    Add_Click = {Save-Param}
}
$Form.Controls.Add($Button_parm)

# グループに入れる
$MyGroupBox.Controls.AddRange(@($CommitLabel,$InputBoxProj,$InputBoxCpfolder))
$Form.Controls.AddRange(@($MyGroupBox))

# BeforeコミットID入力欄
$InputBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "60,80"
    Size = "380,20"
}
$Form.Controls.Add($InputBox)

# AfterコミットID入力欄
$InputBox2 = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "60,100"
    Size = "380,20"
    Text = "master"
}
$Form.Controls.Add($InputBox2)

# 実行ボタン
$Button = New-Object System.Windows.Forms.Button -Property @{
    Location = "540,80"
    Size = "100,40"
    Text = "git diff"
    Font = $font
    BackColor = "#add8e6"
    Add_Click = {Git-Diff} # 関数呼び出し
}
$Form.Controls.Add($Button)
$Form.AcceptButton = $Button # Enterキーでgit diffを実行

# 実行ボタン2
$Button2 = New-Object System.Windows.Forms.Button -Property @{
    Location = "640,80"
    Size = "100,40"
    Text = "git log"
    Font = $font
    BackColor = "#add8e6"
    Add_Click = {Git-Log} # 関数呼び出し
}
$Form.Controls.Add($Button2)

# チェックボックス
$ChecktBoxA = New-Object System.Windows.Forms.CheckBox -Property @{
    Location = "445,80"
    Size     = "30,20"
    Text     = "A"
    Checked  = $True
}
$Form.Controls.Add($ChecktBoxA)

$ChecktBoxC = New-Object System.Windows.Forms.CheckBox -Property @{
    Location = "445,100"
    Size     = "30,20"
    Text     = "C"
    Checked  = $True
}
$Form.Controls.Add($ChecktBoxC)

$ChecktBoxM = New-Object System.Windows.Forms.CheckBox -Property @{
    Location = "480,80"
    Size     = "30,20"
    Text     = "M"
    Checked  = $True
}
$Form.Controls.Add($ChecktBoxM)

$ChecktBoxR = New-Object System.Windows.Forms.CheckBox -Property @{
    Location = "480,100"
    Size     = "30,20"
    Text     = "R"
    Checked  = $True
}
$Form.Controls.Add($ChecktBoxR)

$ChecktBoxD = New-Object System.Windows.Forms.CheckBox -Property @{
    Location = "510,80"
    Size     = "30,20"
    Text     = "D"
    Checked  = $True
}
$Form.Controls.Add($ChecktBoxD)

# テキストラベル(from)
$CommitLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = "10,80"
    Size     = "60,20"
    Text     = "From"
    Forecolor = "black"
    Font      = $Font
}
$Form.Controls.Add($CommitLabel)

# テキストラベル(to)
$CommitLabel2 = New-Object System.Windows.Forms.Label -Property @{
    Location = "10,100"
    Size     = "60,20"
    Text     = "To"
    Forecolor = "black"
    Font      = $Font
}
$Form.Controls.Add($CommitLabel2)

# 出力結果
$OutputBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "10,140"
    Size = "530,600"
    MultiLine = $True
    ScrollBars = "Vertical"
    Font = $FontTextbox
    text = "<git diff>"
    ReadOnly = $True # 読み取り専用
}
$Form.Controls.Add($outputBox)

# 出力結果2
$OutputBox2 = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "540,140"
    Size = "530,600"
    MultiLine = $True
    ScrollBars = "Vertical"
    Font = $FontTextbox
    ReadOnly = $True
    text = "<git log>"
}
$Form.Controls.Add($OutputBox2)

# キャンセルボタン(フォームには配置しない)
$CancelButton = New-Object System.Windows.Forms.Button -Property @{
    Size = "0,0"
    Text = "Cancel"
    DialogResult = "Cancel"
}
$form.Controls.Add($CancelButton)

# ESCキー押下で閉じる
$Form.CancelButton = $CancelButton

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()
#endregion