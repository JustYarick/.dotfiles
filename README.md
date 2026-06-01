# .dotfiles

Мои конфигурационные файлы для системы на базе **Arch Linux** с тайлинговым оконным менеджером **Hyprland**.

## Установка

Для управления конфигурациями используется [GNU Stow](https://www.gnu.org/software/stow/).

```bash
git clone https://github.com/JustYarick/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow .
```

> Многие пакеты устанавливаются из **AUR** — рекомендуется использовать `yay`.

---

## Системные компоненты

### Видеодрайверы (NVIDIA)

| Пакет | Описание | Источник |
|---|---|---|
| `nvidia-open` | Открытые модули ядра NVIDIA | official |
| `nvidia-settings` | Панель управления настройками GPU | official |
| `libva-nvidia-driver` | Аппаратное ускорение видео (VA-API) | AUR |

---

### Оболочка и оконный менеджер

| Пакет | Описание | Источник |
|---|---|---|
| `hyprland` | Основной тайлинговый WM (Wayland) | official |
| `ly` | TUI Display Manager — экран входа в систему | AUR |
| `uwsm` | Universal Wayland Session Manager | AUR |
| `xdg-desktop-portal-hyprland` | Системные порталы: скриншоты, шаринг экрана | official |
| `polkit-kde-agent` | Агент аутентификации Polkit | official |
| `waybar` | Статусная панель (скрипты в `.config/waybar/custom_modules/`) | official |
| `swaync` | Центр уведомлений (SwayNC) | AUR |
| `wofi` | Меню запуска приложений (Wayland-native) | official |
| `rofi` | Альтернативный launcher и window switcher | official |
| `hyprlock` | Блокировщик экрана для Hyprland | AUR |
| `wlogout` | Меню выхода из сессии | AUR |

---

### Терминал и окружение

| Пакет | Описание | Источник |
|---|---|---|
| `ghostty` | Основной эмулятор терминала | AUR |
| `kitty` | Альтернативный эмулятор терминала | official |
| `zsh` | Основная оболочка | official |
| `oh-my-zsh` | Фреймворк конфигурации zsh | external |
| `powerlevel10k` | Тема для zsh (устанавливается как плагин OMZ) | external |
| `tmux` | Мультиплексор терминала | official |
| `fastfetch` | Информация о системе (alias: `ff`) | official |

---

### Звук и мультимедиа

| Пакет | Описание | Источник |
|---|---|---|
| `pipewire` | Основной звуковой сервер | official |
| `pipewire-pulse` | PulseAudio-совместимый слой поверх PipeWire | official |
| `pipewire-alsa` | ALSA-совместимый слой поверх PipeWire | official |
| `wireplumber` | Session manager для PipeWire | official |
| `easyeffects` | Настройка и обработка звука | official |
| `lsp-plugins` | Аудио-фильтры для EasyEffects | official |
| `rnnoise` | Нейросетевое шумоподавление для EasyEffects | official |
| `playerctl` | Управление медиаплеерами из статусбара | official |
| `helvum` | Граф аудиопотоков PipeWire | official |

---

### Работа с файлами и обои

| Пакет | Описание | Источник |
|---|---|---|
| `yazi` | Терминальный файловый менеджер | official |
| `nautilus` | Графический файловый менеджер | official |
| `waypaper` | GUI-менеджер обоев | AUR |
| `awww` | Бэкенд обоев: GIF-анимация | AUR |
| `mpvpaper` | Бэкенд обоев: видео | AUR |
| `hyprshot` | Скриншоты (обёртка над grim + slurp) | AUR |
| `grim` | Захват экрана на Wayland | official |
| `slurp` | Интерактивный выбор области экрана | official |

---

## Разработка и инструменты

### Редакторы

| Пакет | Описание | Источник |
|---|---|---|
| `neovim` | Основной редактор (дистрибутив LazyVim) | official |
| `visual-studio-code-bin` | Альтернативный редактор / IDE | AUR |

---

### Контейнеризация

| Пакет | Описание | Источник |
|---|---|---|
| `docker` | Контейнеризация приложений | official |
| `docker-compose` | Оркестрация многоконтейнерных приложений | official |

---

### Языки и среды разработки

| Пакет | Описание | Источник |
|---|---|---|
| `nodejs` | JavaScript runtime (Node.js) | official |
| `npm` | Менеджер пакетов Node | official |
| `angular-cli` | CLI для Angular-проектов | npm |
| `pyenv` | Менеджер версий Python | AUR |
| `python-pip` | Менеджер пакетов Python | official |
| `mongodb-bin` | СУБД MongoDB | AUR |
| `mongodb-tools-bin` | Утилиты MongoDB (mongodump, mongorestore и др.) | AUR |

---

### Git

| Пакет | Описание | Источник |
|---|---|---|
| `git` | Система контроля версий | official |
| `lazygit` | TUI-клиент для удобной работы с Git | official |

---

### Сеть и безопасность

| Пакет | Описание | Источник |
|---|---|---|
| `networkmanager` | Управление сетевыми подключениями | official |
| `network-manager-applet` | Трей-апплет NetworkManager | official |
| `ufw` | Uncomplicated Firewall | official |
| `v2ray-bin` | Прокси-ядро V2Ray | AUR |
| `throne-bin` | Proxy / VCS-инструмент | AUR |

---

## Приложения

### Браузеры

| Пакет | Описание | Источник |
|---|---|---|
| `google-chrome` | Основной браузер | AUR |
| `firefox` | Резервный браузер | official |

---

### Мессенджеры и связь

| Пакет | Описание | Источник |
|---|---|---|
| `telegram-desktop` | Мессенджер Telegram | official |
| `com.discordapp.Discord` | Discord с автообновлениями | Flatpak |
| `teamspeak3` | Голосовой чат TeamSpeak 3 | AUR |
| `teamspeak` | Бета-версия TeamSpeak 6 | AUR |

---

### Игры

| Пакет | Описание | Источник |
|---|---|---|
| `steam` | Игровая платформа Valve | official |
| `gamescope` | Микрокомпозитор для игр (HDR, upscaling) | official |

---

### Утилиты

| Пакет | Описание | Источник |
|---|---|---|
| `spotify` | Стриминг музыки | AUR |
| `localsend-bin` | Передача файлов в локальной сети (AirDrop-альтернатива) | AUR |
| `onlyoffice-bin` | Офисный пакет (совместимость с .docx/.xlsx) | AUR |
| `timeshift` | Снимки системы и бэкапы | AUR |
| `cups` | Система печати | official |

---

## Шрифты и оформление

| Пакет | Описание | Источник |
|---|---|---|
| `ttf-jetbrains-mono-nerd` | Основной моноширинный шрифт с Nerd Icons | official |
| `noto-fonts` | Универсальный набор шрифтов | official |
| `noto-fonts-cjk` | Поддержка CJK: китайский, японский, корейский | official |
| `noto-fonts-emoji` | Поддержка emoji | official |
| `woff2-font-awesome` | Font Awesome в формате WOFF2 (для Waybar) | AUR |
| `adwaita-icon-theme` | Иконки и курсоры Adwaita | official |

---