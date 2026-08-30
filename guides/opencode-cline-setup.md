# 🚀 آموزش راه‌اندازی OpenCode با مدل‌های رایگان Cline

## 📋 خلاصه
اتصال OpenCode به مدل‌های رایگان Cline (مثل GLM-5.3-Flash) از طریق `useclaudeproxy`.

---

## ⚙️ پیش‌نیازها

1. **Node.js** نصب باشه (`node -v` برای تست)
2. **OpenCode** نصب باشه:
   ```powershell
   npm i -g opencode-ai@latest
   ```
3. **اکانت Cline** ساخته باشید:
   - ثبت‌نام: https://app.cline.bot

---

## 🛠️ مراحل راه‌اندازی (هر بار که می‌خوای استفاده کنی)

### گام ۱: اجرای پروکسی (پاورشل اول)
یک پاورشل باز کن و این دستور رو بزن و **بذار باز بمونه**:

```powershell
npx useclaudeproxy@3.5.0 --provider cline --model z-ai/glm-5.3-flash --port 2096
```

### گام ۲: کانفیگ OpenCode (فقط یک‌بار انجام بده)
فایل `C:\Users\Hossein\.config\opencode\opencode.jsonc` رو باز کن و این محتوا رو توش بذار:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "cline": {
      "npm": "@ai-sdk/openai",
      "name": "Cline (GLM-5.3-Flash)",
      "options": {
        "baseURL": "http://127.0.0.1:2096/v1",
        "apiKey": "456789"
      },
      "models": {
        "z-ai/glm-5.3-flash": {
          "name": "GLM 5.3 Flash",
          "limit": {
            "context": 128000,
            "output": 8192
          }
        },
        "claude-opus-5": {
          "name": "Claude Opus 5 (GLM-5.3)",
          "limit": {
            "context": 128000,
            "output": 8192
          }
        }
      }
    }
  }
}
```

### گام ۳: اجرای OpenCode (پاورشل دوم)
یک پاورشل جدید باز کن:

```powershell
opencode
```

با `Ctrl+P` یا `/model` مدل **GLM 5.3 Flash** رو انتخاب کن.

---

## ⚠️ نکات مهم

- **پنجره پاورشل اول رو نبند!** اگه پروکسی بسته بشه، OpenCode اتصالش قطع میشه.
- اگه ارور `Cannot connect to API` اومد، یعنی پروکسی خاموشه. پاورشل اول رو چک کن.
- اگه ارور `Invalid API Key` اومد، API Key پروکسی رو از خروجی پاورشل اول چک کن و توی فایل `opencode.jsonc` جایگزین کن.

---
