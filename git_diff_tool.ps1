#region �p�����[�^
$json = Get-Content param.json | ConvertFrom-Json
$proj = $json.proj # �v���W�F�N�g�t�H���_
#endregion

#region �֐���`
function Git-Diff {
$proj = $InputBoxProj.Text
Set-Location $proj # �v���W�F�N�g�t�H���_���J�����g�f�B���N�g���ɐݒ�

$commit_from = $InputBox.Text # Before�R�~�b�gID
$commit_to = $InputBox2.Text # After�R�~�b�gID

# �`�F�b�N�{�b�N�X�̓��e���擾
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
        $outputBox.Text = git diff --stat --diff-filter=$($filter) $commit_from�@$commit_to | Out-String
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
    [System.Windows.Forms.MessageBox]::Show('Saved to "param.json".') # ���b�Z�[�W�{�b�N�X��\��
}
function Folder-Select() {
    # COM�I�u�W�F�N�g�̓ǂݍ���
    $shell = New-Object -com Shell.Application

    # �_�C�A���O��\�����A���ʂ�ϐ�folderPath�Ɋi�[����
    $folderPath = $shell.BrowseForFolder(0,"�Ώۃt�H���_�[��I�����Ă�������",0,"C:\")

    # �L�����Z����I�������ꍇ�͏I��
    if ($folderPath -eq $Null){return}

    # $folderPath���̏��̂����A�p�X���݂̂��i�[����
    $InputBoxProj.text = $folderPath.Self.Path

    # �i�[�����p�X�����b�Z�[�W�{�b�N�X�ŕ\��
    Add-Type -Assembly System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show($folderPath.Self.Path,"��������")
}
#endregion

#region �t�H�[��
# �A�Z���u���̓ǂݍ���
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

# �t�H���g
$Font = New-Object System.Drawing.Font("�l�r �S�V�b�N",11)       # ���x���̃t�H���g
$FontTextbox = New-Object System.Drawing.Font("�l�r �S�V�b�N",9) # �e�L�X�g�{�b�N�X�̃t�H���g

# �t�H�[��
$Form = New-Object System.Windows.Forms.Form -Property @{
    Size = "1095,810"
    Text = "git_diff_tool"
    Add_Shown = {$InputBox.Select()} # From�R�~�b�gID�e�L�X�g�{�b�N�X�Ƀt�H�[�J�X
    StartPosition = "CenterScreen"   # ���S�ɕ\������
    #StartPosition = "Manual"        # �\���ʒu���w�肷��
    #Location = "0,200"              # ���W
    #Opacity = 0.9                   # �����x
    #Topmost = $True                 # �őO�ʌŒ�
}

# �p�����[�^�O���[�v
$MyGroupBox = New-Object System.Windows.Forms.GroupBox -Property @{
    Location = "10,10"
    size = "700,50"
    text = "Parameter"
}

# �v���W�F�N�g�t�H���_���x��
$CommitLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = "10,20"
    Size = "120,20"
    Text = "Project Folder:"
    Forecolor = "black"
    Font = $Font
}
$Form.Controls.Add($CommitLabel)

# �v���W�F�N�g�t�H���_�e�L�X�g�{�b�N�X
$InputBoxProj = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "130,20"
    Size = "400,20"
    Text = $proj
}
$Form.Controls.Add($InputBoxProj)

# �t�H���_�I���{�^��
$Button_folder = New-Object System.Windows.Forms.Button -Property @{
    Location = "540,30"
    Size = "55,20"
    Text = "Browse"
    Add_Click = {Folder-Select} # �֐��Ăяo��
}
$Form.Controls.Add($Button_folder)

# �t�H���_���J���{�^��
$Button_open = New-Object System.Windows.Forms.Button -Property @{
    Location = "590,30"
    Size = "55,20"
    Text = "Open"
    Add_Click = {Invoke-item $InputBoxProj.Text}
}
$Form.Controls.Add($Button_open)

# �p�����[�^�ۑ��{�^��
$Button_parm = New-Object System.Windows.Forms.Button -Property @{
    Location = "645,30"
    Size = "55,20"
    Text = "Save"
    Add_Click = {Save-Param}
}
$Form.Controls.Add($Button_parm)

# �O���[�v�ɓ����
$MyGroupBox.Controls.AddRange(@($CommitLabel,$InputBoxProj,$InputBoxCpfolder))
$Form.Controls.AddRange(@($MyGroupBox))

# Before�R�~�b�gID���͗�
$InputBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "60,80"
    Size = "380,20"
}
$Form.Controls.Add($InputBox)

# After�R�~�b�gID���͗�
$InputBox2 = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "60,100"
    Size = "380,20"
    Text = "master"
}
$Form.Controls.Add($InputBox2)

# ���s�{�^��
$Button = New-Object System.Windows.Forms.Button -Property @{
    Location = "540,80"
    Size = "100,40"
    Text = "git diff"
    Font = $font
    BackColor = "#add8e6"
    Add_Click = {Git-Diff} # �֐��Ăяo��
}
$Form.Controls.Add($Button)
$Form.AcceptButton = $Button # Enter�L�[��git diff�����s

# ���s�{�^��2
$Button2 = New-Object System.Windows.Forms.Button -Property @{
    Location = "640,80"
    Size = "100,40"
    Text = "git log"
    Font = $font
    BackColor = "#add8e6"
    Add_Click = {Git-Log} # �֐��Ăяo��
}
$Form.Controls.Add($Button2)

# �`�F�b�N�{�b�N�X
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

# �e�L�X�g���x��(from)
$CommitLabel = New-Object System.Windows.Forms.Label -Property @{
    Location = "10,80"
    Size     = "60,20"
    Text     = "From"
    Forecolor = "black"
    Font      = $Font
}
$Form.Controls.Add($CommitLabel)

# �e�L�X�g���x��(to)
$CommitLabel2 = New-Object System.Windows.Forms.Label -Property @{
    Location = "10,100"
    Size     = "60,20"
    Text     = "To"
    Forecolor = "black"
    Font      = $Font
}
$Form.Controls.Add($CommitLabel2)

# �o�͌���
$OutputBox = New-Object System.Windows.Forms.TextBox -Property @{
    Location = "10,140"
    Size = "530,600"
    MultiLine = $True
    ScrollBars = "Vertical"
    Font = $FontTextbox
    text = "<git diff>"
    ReadOnly = $True # �ǂݎ���p
}
$Form.Controls.Add($outputBox)

# �o�͌���2
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

# �L�����Z���{�^��(�t�H�[���ɂ͔z�u���Ȃ�)
$CancelButton = New-Object System.Windows.Forms.Button -Property @{
    Size = "0,0"
    Text = "Cancel"
    DialogResult = "Cancel"
}
$form.Controls.Add($CancelButton)

# ESC�L�[�����ŕ���
$Form.CancelButton = $CancelButton

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()
#endregion