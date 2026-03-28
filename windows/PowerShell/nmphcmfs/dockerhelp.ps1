function Get-DockerEntries {
    $e = [System.Collections.Generic.List[object]]::new()

    # ── Konteyner ─────────────────────────────────────────────────────────────
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker ps';           Desc='Calisan konteynerleri listele.';                         Ex='docker ps -a';                                              Note='-a: durmus olanlar dahil  |  -q: sadece ID' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker run';          Desc='Imajdan yeni konteyner baslat.';                        Ex='docker run -d -p 8080:80 --name web nginx';                 Note='-d: arka plan  |  -it: interaktif  |  --rm: bitince sil  |  -e: env var' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker exec';         Desc='Calisan konteyner icinde komut calistir.';              Ex='docker exec -it <id> bash';                                Note='-it olmadan tek seferlik komut  |  bash yoksa sh' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker stop / kill';  Desc='Konteyneri durdur (graceful veya aninda).';            Ex='docker stop <id>  |  docker kill <id>';                    Note='stop: SIGTERM + 10s bekle  |  kill: aninda SIGKILL' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker rm';           Desc='Durdurulmus konteyneri sil.';                          Ex='docker rm $(docker ps -aq)';                               Note='-f: calisan konteyneri de zorla sil' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker logs';         Desc='Konteyner cikti loglarini goster.';                    Ex='docker logs -f --tail 100 <id>';                           Note='-f: canli akis  |  --since 1h: son 1 saat' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker stats';        Desc='CPU, RAM, ag ve disk kullanimi canli izle.';            Ex='docker stats --no-stream';                                 Note='--no-stream: tek snapshot  |  --format ile JSON' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker inspect';      Desc='Konteyner veya imaj hakkinda JSON detay.';             Ex='docker inspect <id>';                                      Note='jq ile filtrelenebilir  |  -f go-template ile ozel cikti' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker cp';           Desc='Host ile konteyner arasinda dosya kopyala.';           Ex='docker cp app.conf <id>:/etc/app/';                        Note='Calisan veya durdurulmus konteynerde calisir' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker rename';       Desc='Konteyner adini degistir.';                            Ex='docker rename eski yeni';                                  Note='' })
    $e.Add([PSCustomObject]@{ Cat='KONTEYNER'; Cmd='docker restart';      Desc='Konteyneri yeniden baslat.';                           Ex='docker restart <id>';                                      Note='--time 5: 5s bekleyip yeniden baslatir' })

    # ── İmaj ──────────────────────────────────────────────────────────────────
    $e.Add([PSCustomObject]@{ Cat='IMAJ'; Cmd='docker images';    Desc='Yerel imajlari listele.';                    Ex='docker images --format "table {{.Repository}}\t{{.Size}}"'; Note='-a: ara katmanlar dahil  |  --filter dangling=true' })
    $e.Add([PSCustomObject]@{ Cat='IMAJ'; Cmd='docker pull';      Desc='Registry den imaj indir.';                  Ex='docker pull nginx:1.25-alpine';                              Note='Etiket belirtilmezse :latest indirilir' })
    $e.Add([PSCustomObject]@{ Cat='IMAJ'; Cmd='docker build';     Desc='Dockerfile dan imaj olustur.';              Ex='docker build -t myapp:1.0 --build-arg ENV=prod .';           Note='--no-cache: katman onbellegini atla  |  --target: stage sec' })
    $e.Add([PSCustomObject]@{ Cat='IMAJ'; Cmd='docker tag / push'; Desc='Imaji etiketle ve registry ye gonder.';   Ex='docker tag myapp:1.0 myrepo/myapp:1.0';                      Note='push oncesi docker login gerekir' })
    $e.Add([PSCustomObject]@{ Cat='IMAJ'; Cmd='docker rmi';       Desc='Yerel imaji sil.';                          Ex='docker rmi myapp:1.0  |  docker image prune -a';             Note='Kullanimdaki imaj silinemez' })
    $e.Add([PSCustomObject]@{ Cat='IMAJ'; Cmd='docker save / load'; Desc='Imaji tar arsivine aktar veya yukle.';   Ex='docker save -o myapp.tar myapp:1.0';                         Note='Internetsiz ortam aktarimi icin kullanilir' })
    $e.Add([PSCustomObject]@{ Cat='IMAJ'; Cmd='docker history';   Desc='Imaj katmanlarini ve boyutlarini goster.';  Ex='docker history --no-trunc myapp:1.0';                        Note='Imaj boyutunu analiz etmeyi saglar' })

    # ── Ağ ────────────────────────────────────────────────────────────────────
    $e.Add([PSCustomObject]@{ Cat='AG'; Cmd='docker network ls';      Desc='Tum Docker aglarini listele.';   Ex='docker network ls --filter driver=bridge'; Note='Varsayilan aglar: bridge, host, none' })
    $e.Add([PSCustomObject]@{ Cat='AG'; Cmd='docker network create';  Desc='Ozel ag olustur.';              Ex='docker network create --driver bridge mynet'; Note='Konteynerler ayni agda birbirini isimle bulabilir' })
    $e.Add([PSCustomObject]@{ Cat='AG'; Cmd='docker network connect'; Desc='Konteyneri mevcut bir aga bagla.'; Ex='docker network connect mynet <id>';       Note='Calisan konteynere canli ag eklenebilir' })

    # ── Volume ────────────────────────────────────────────────────────────────
    $e.Add([PSCustomObject]@{ Cat='VOLUME'; Cmd='docker volume create'; Desc='Volume olustur.';             Ex='docker volume create pgdata';                Note='docker run -v pgdata:/var/lib/postgresql ...' })
    $e.Add([PSCustomObject]@{ Cat='VOLUME'; Cmd='docker volume prune';  Desc='Kullanilmayan volumeleri sil.'; Ex='docker volume prune';                     Note='Hicbir konteynere bagli olmayanlari siler' })

    # ── Compose ───────────────────────────────────────────────────────────────
    $e.Add([PSCustomObject]@{ Cat='COMPOSE'; Cmd='docker compose up';       Desc='Servisleri baslat.';                 Ex='docker compose up -d --build';                              Note='-d: arka plan  |  --build: imaj yenile  |  --scale web=3' })
    $e.Add([PSCustomObject]@{ Cat='COMPOSE'; Cmd='docker compose down';     Desc='Servisleri durdur ve temizle.';      Ex='docker compose down -v --remove-orphans';                   Note='-v: volume lari da sil' })
    $e.Add([PSCustomObject]@{ Cat='COMPOSE'; Cmd='docker compose logs';     Desc='Servis loglarini goster.';           Ex='docker compose logs -f web';                                Note='Belirli servisi izlemek icin servis adini ekle' })
    $e.Add([PSCustomObject]@{ Cat='COMPOSE'; Cmd='docker compose exec';     Desc='Calisan serviste komut calistir.';   Ex='docker compose exec web bash';                              Note='exec: mevcut konteyner  |  run: yeni konteyner olusturur' })

    # ── Temizlik ──────────────────────────────────────────────────────────────
    $e.Add([PSCustomObject]@{ Cat='TEMIZLIK'; Cmd='docker system prune'; Desc='Kullanilmayan tum kaynaklari temizle.'; Ex='docker system prune -af --volumes'; Note='-a: imajlari da dahil et  |  DIKKAT: geri alinamaz' })
    $e.Add([PSCustomObject]@{ Cat='TEMIZLIK'; Cmd='docker system df';    Desc='Docker disk kullanim ozeti.';           Ex='docker system df -v';               Note='-v: her imaj ve konteyner icin detayli boyut' })

    return $e.ToArray()
}

function Show-DockerEntryCard {
    param([PSCustomObject]$Entry)

    $catColors = @{ KONTEYNER=39; IMAJ=117; AG=82; VOLUME=214; COMPOSE=141; TEMIZLIK=196 }
    $col  = if ($catColors[$Entry.Cat]) { $catColors[$Entry.Cat] } else { 245 }
    $line = '-' * 70

    Write-Host ''
    Write-Host "`e[38;5;244m$line`e[0m"
    Write-Host "`e[38;5;${col}m◆ $($Entry.Cat)`e[0m  `e[97m$($Entry.Cmd)`e[0m"
    Write-Host ''
    Write-Host "  `e[38;5;245m$($Entry.Desc)`e[0m"
    Write-Host ''
    Write-Host "  `e[38;5;244mOrnek`e[0m  `e[38;5;${col}m$($Entry.Ex)`e[0m"
    if ($Entry.Note) {
        Write-Host "  `e[38;5;244mNot  `e[0m  `e[38;5;244m$($Entry.Note)`e[0m"
    }
    Write-Host "`e[38;5;244m$line`e[0m"
    Write-Host ''
}

function dockerhelp {
    $entries = Get-DockerEntries

    if (-not (Get-Command fzf -ErrorAction SilentlyContinue)) {
        foreach ($e in $entries) { Show-DockerEntryCard -Entry $e }
        return
    }

    $catColors = @{ KONTEYNER=39; IMAJ=117; AG=82; VOLUME=214; COMPOSE=141; TEMIZLIK=196 }

    $items = for ($i = 0; $i -lt $entries.Count; $i++) {
        $e   = $entries[$i]
        $col = if ($catColors[$e.Cat]) { $catColors[$e.Cat] } else { 245 }
        $display = ("`e[38;5;${col}m◆ {0,-10}`e[0m  `e[97m{1,-26}`e[0m `e[38;5;245m{2}`e[0m" -f $e.Cat, $e.Cmd, $e.Desc)
        # alan1=index  alan2=Cat  alan3=Cmd  alan4=Desc  alan5=display(ANSI)
        [string]::Join([char]9, @([string]$i, [string]$e.Cat, [string]$e.Cmd, [string]$e.Desc, $display))
    }

    $fzfColor = if (Get-Command Get-SystemCmdFzfColorOption -ErrorAction SilentlyContinue) {
        Get-SystemCmdFzfColorOption
    } else { 'dark' }

    $selection = $items | & fzf `
        --delimiter "`t" `
        --with-nth 5 `
        --prompt 'docker > ' `
        --header 'Docker Referans  |  Enter: detay  |  Esc: cik' `
        --layout reverse `
        --border `
        --ansi `
        --color $fzfColor

    if ([string]::IsNullOrWhiteSpace($selection)) { return }

    $idx = [int]($selection -split "`t", 2)[0].Trim()
    Show-DockerEntryCard -Entry $entries[$idx]
}
