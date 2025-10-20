# git diffを用いてWindowsでdiffを行う
# 高機能化
# ・gitでついてくる余計なindexを削除
# ・-oオプションで一発でファイル出力
# 　・-NoClobberオプションで出力の上書きを阻止
# ・-vオプションでメモ帳で確認
# ・-cオプションでコマンドラインに出力


# コマンドライン引数は$Args[]
# ループでオプションを処理
$Comp_File =@()
$Opt_o = $null
$Opt_v = $false
$Opt_c = $false
$Opt_NoC = $false
$i = 0
foreach ($x in $Args) {
    switch ($x) {
        "-o" {
            if ($null -ne $Args[$i+1]) {
                $Opt_o = $Args[$i+1]
            } else {
                Write-Host "【エラー】オプションoの値がありません"
                exit 1
            }
        }
        "-v" {
            $Opt_v = $true
        }
        "-c" {
            $Opt_c = $true
        }
        "-NoClobber" {
            $Opt_NoC = $true
        }
        Default {
            if ($x -ne $Opt_o) {
                $Comp_File += $x
            }
        }
    }
    $i++
}



# 比較ファイルが足りない場合エラー
# 多すぎる場合は特に対策しない
if ($Comp_File.Length -lt 2) {
    Write-Host "【エラー】比較するファイルが足りません"
    exit 1
}

# git diffで比較
$diff = git diff --no-index $Comp_File[0] $Comp_File[1]
# 最初の二行を落とす
# cf. https://step-learn.com/article/powershell/043-array-pop.html
$diff = $diff[2..($diff.Length-1)]
# 配列で返ってくるので結合
$diff = $diff -join "`n"

# -vオプションでメモ帳で確認
# ドキュメント直下に仮ファイルを出力しオープン、終了したら削除
if ($Opt_v -eq $true) {
    $View_Path = [System.Environment]::GetFolderPath("MyDocuments") + "\" + "diffview" + $(get-date -Format "yyyyMMddHHmmssffff") + ".txt"
    $diff | Out-File -FilePath ($View_Path) -Encoding utf8 -NoNewline
    Start-Process $View_Path -Wait
    Remove-Item $View_Path
}

# -oオプションで一発でファイル出力
if ($null -ne $Opt_o) {
    if ($Opt_NoC) {
        $diff | Out-File -FilePath $Opt_o -Encoding utf8 -NoNewline -NoClobber
    } else {
        $diff | Out-File -FilePath $Opt_o -Encoding utf8 -NoNewline
    }
}

# -cオプション、またはオプションなしの場合コンソールに表示
if ((!$Opt_v -and $null -eq $Opt_o) -or $Opt_c) {
    Write-Host $diff
}