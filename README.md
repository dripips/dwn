# DWN

**EN** | [RU](#ru) | [DE](#de)

Lightweight Rails API that extracts direct CDN download links from social media URLs via [yt-dlp](https://github.com/yt-dlp/yt-dlp). The server never downloads the media itself — it only resolves the direct URL so your client (phone, browser, shortcut) can download straight from the CDN.

### Supported platforms

YouTube, YouTube Shorts, Instagram Reels, VK Video, TikTok, Twitter/X, and [1000+ others](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) supported by yt-dlp.

### How it works

```
Client                    DWN Server                CDN
  |                          |                       |
  |-- GET /api/get?url= ---->|                       |
  |                          |-- yt-dlp --json ----->|
  |                          |<-- metadata+url ------|
  |<-- { url, title, ... } --|                       |
  |                                                  |
  |------------- download file directly ------------>|
```

### API

```
GET /api/get?url=<encoded_url>
Header: X-Api-Key: <your_token>
```

**200 OK**
```json
{
  "title": "Rick Astley - Never Gonna Give You Up",
  "ext": "mp4",
  "thumbnail": "https://i.ytimg.com/vi/.../maxresdefault.jpg",
  "duration": 213,
  "url": "https://rr3---sn-xxx.googlevideo.com/videoplayback?...",
  "audio_url": "https://..."
}
```

- `url` — direct CDN link to the best available video (combined video+audio when possible)
- `audio_url` — separate audio track (YouTube DASH only, `null` for Instagram/VK/TikTok)
- `4xx` / `5xx` — `{ "error": "..." }`

### Setup

**Requirements:** Ruby >= 3.2, yt-dlp, ffmpeg (optional)

```bash
git clone https://github.com/dripips/dwn.git
cd dwn
bundle install

# generate your API key
echo "DOWNLOADER_API_KEY=$(openssl rand -hex 32)" > .env

# run
bin/rails server
```

**Install yt-dlp:**
```bash
pip install -U yt-dlp

# auto-update cron (yt-dlp breaks weekly due to site changes)
echo "0 5 * * * pip install --break-system-packages -U yt-dlp >/dev/null 2>&1" | crontab -
```

**Instagram cookies** (required for private reels, optional for public):
```bash
# export cookies.txt from browser (e.g. "Get cookies.txt" extension)
mkdir -p /etc/yt-dlp
cp cookies.txt /etc/yt-dlp/cookies.txt
```

### iOS Shortcut

1. Accept URL from Share Sheet
2. `GET https://your-server.com/api/get?url=` + percent-encoded URL, header `X-Api-Key`
3. Get Dictionary from response
4. Get Value for key `url`
5. Get Contents of URL (this downloads the actual file from CDN)
6. Save to Photo Library

### Rate limiting

60 requests/minute per IP via Rack::Attack. CDN URLs are cached for 30 minutes.

### Notes

- CDN URLs have TTL: Instagram ~6h, YouTube ~6h, VK ~24h
- YouTube 1080p+ splits video and audio (DASH) — use `audio_url` + ffmpeg to merge
- No database required — everything runs in-memory

---

<a name="ru"></a>
## RU

Легковесный Rails API, который извлекает прямые CDN-ссылки из URL соцсетей через [yt-dlp](https://github.com/yt-dlp/yt-dlp). Сервер не скачивает медиа сам — только отдает прямую ссылку, чтобы клиент скачал напрямую с CDN.

### Поддерживаемые платформы

YouTube, YouTube Shorts, Instagram Reels, VK Video, TikTok, Twitter/X и [1000+ других](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).

### API

```
GET /api/get?url=<encoded_url>
Header: X-Api-Key: <ваш_токен>
```

**Ответ 200:**
```json
{
  "title": "...",
  "ext": "mp4",
  "thumbnail": "https://...",
  "duration": 213,
  "url": "https://cdn-direct-link...",
  "audio_url": null
}
```

- `url` — прямая ссылка на видео с CDN (combined video+audio когда возможно)
- `audio_url` — отдельная аудиодорожка (только YouTube DASH, для Instagram/VK/TikTok = `null`)

### Установка

```bash
git clone https://github.com/dripips/dwn.git
cd dwn
bundle install
echo "DOWNLOADER_API_KEY=$(openssl rand -hex 32)" > .env
bin/rails server
```

**yt-dlp:**
```bash
pip install -U yt-dlp
```

**Cookies для Instagram** (обязательно для приватных reels):
```bash
mkdir -p /etc/yt-dlp
cp cookies.txt /etc/yt-dlp/cookies.txt
```

### iOS Shortcut

1. Принять URL из Share Sheet
2. `GET https://ваш-сервер/api/get?url=` + percent-encoded URL, заголовок `X-Api-Key`
3. Получить словарь из ответа
4. Получить значение по ключу `url`
5. Загрузить содержимое URL (это уже сам файл с CDN)
6. Сохранить в Фотопленку

### Заметки

- CDN-ссылки временные: Instagram ~6ч, YouTube ~6ч, VK ~сутки
- Кеш 30 минут, rate limit 60 req/мин на IP
- БД не нужна — все в памяти

---

<a name="de"></a>
## DE

Leichtgewichtige Rails-API, die direkte CDN-Download-Links aus Social-Media-URLs via [yt-dlp](https://github.com/yt-dlp/yt-dlp) extrahiert. Der Server ladt keine Medien selbst herunter — er liefert nur die direkte URL, damit der Client direkt vom CDN herunterladen kann.

### Unterstuetzte Plattformen

YouTube, YouTube Shorts, Instagram Reels, VK Video, TikTok, Twitter/X und [1000+ weitere](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).

### API

```
GET /api/get?url=<encoded_url>
Header: X-Api-Key: <ihr_token>
```

**Antwort 200:**
```json
{
  "title": "...",
  "ext": "mp4",
  "thumbnail": "https://...",
  "duration": 213,
  "url": "https://cdn-direct-link...",
  "audio_url": null
}
```

### Installation

```bash
git clone https://github.com/dripips/dwn.git
cd dwn
bundle install
echo "DOWNLOADER_API_KEY=$(openssl rand -hex 32)" > .env
bin/rails server
```

### Hinweise

- CDN-URLs sind zeitlich begrenzt: Instagram ~6h, YouTube ~6h, VK ~24h
- Cache 30 Minuten, Rate-Limit 60 Anfragen/Min pro IP
- Keine Datenbank erforderlich — alles im Arbeitsspeicher

---

## License / Лицензия / Lizenz

[MIT](LICENSE)
