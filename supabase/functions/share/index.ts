declare const Deno: {
  serve: (handler: (req: Request) => Response | Promise<Response>) => void;
};

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  const id = url.searchParams.get('id');

  if (!id) {
    return new Response('Missing news ID', { status: 400 });
  }

  // The custom URI scheme to launch our app.
  // It matches what we defined in AndroidManifest.xml and Info.plist
  const appSchemeUrl = `alikhbariah://news/${id}`;
  const androidIntentUrl = `intent://news/${id}#Intent;scheme=alikhbariah;package=com.alikhbariah.newsapp;end`;

  // We return a simple HTML page that automatically redirects the browser 
  // to the app's custom scheme when opened. This ensures the link is 
  // clickable in social media apps like WhatsApp, Telegram, Facebook, etc.
  const html = `
    <!DOCTYPE html>
    <html lang="ar" dir="rtl">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>جاري فتح الخبر...</title>
      <style>
        body {
          font-family: system-ui, -apple-system, sans-serif;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 100vh;
          margin: 0;
          background-color: #f8f9fa;
          color: #333;
          text-align: center;
          padding: 20px;
        }
        .container {
          max-width: 400px;
          padding: 30px;
          background: white;
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        }
        h1 { font-size: 20px; color: #1a1a1a; margin-bottom: 10px; }
        p { font-size: 16px; color: #666; margin-bottom: 25px; }
        .btn {
          display: inline-block;
          padding: 12px 24px;
          background-color: #0066cc;
          color: white;
          text-decoration: none;
          border-radius: 8px;
          font-weight: bold;
          font-size: 16px;
        }
        .btn.secondary {
          background-color: #0f766e;
          margin-top: 10px;
        }
      </style>
      <script>
        const appSchemeUrl = "${appSchemeUrl}";
        const androidIntentUrl = "${androidIntentUrl}";

        function isAndroid() {
          return /Android/i.test(navigator.userAgent || '');
        }

        function tryOpenApp() {
          // Android browsers are usually more reliable with intent://
          if (isAndroid()) {
            window.location.href = androidIntentUrl;
            setTimeout(() => {
              window.location.href = appSchemeUrl;
            }, 700);
            return;
          }

          // iOS and other platforms
          window.location.href = appSchemeUrl;
        }

        window.addEventListener('load', () => {
          setTimeout(tryOpenApp, 250);
        });
      </script>
    </head>
    <body>
      <div class="container">
        <h1>جاري تحويلك إلى التطبيق...</h1>
        <p>إذا لم يفتح التطبيق تلقائياً، يرجى الضغط على الزر أدناه</p>
        <a href="${appSchemeUrl}" class="btn">فتح في التطبيق</a>
        <a href="${androidIntentUrl}" class="btn secondary">فتح مباشر لأندرويد</a>
      </div>
    </body>
    </html>
  `;

  return new Response(html, {
    status: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
      'Cache-Control': 'no-store, no-cache, must-revalidate',
    },
  });
});
