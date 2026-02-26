/// <reference path="./deno-globals.d.ts" />

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

type TranslateRequest = {
  text?: string;
  source?: string;
  target?: string;
};

async function tryLibreTranslate(
  endpoint: string,
  text: string,
  source: string,
  target: string,
  apiKey?: string,
): Promise<string | null> {
  const payload: Record<string, string> = {
    q: text,
    source,
    target,
    format: "text",
  };

  if (apiKey != null && apiKey.length > 0) {
    payload.api_key = apiKey;
  }

  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    return null;
  }

  const result = (await response.json()) as { translatedText?: string };
  const translatedText = (result.translatedText ?? "").trim();
  return translatedText.length > 0 ? translatedText : null;
}

async function tryMyMemory(
  text: string,
  source: string,
  target: string,
): Promise<string | null> {
  const url = `https://api.mymemory.translated.net/get?q=${encodeURIComponent(text)}&langpair=${encodeURIComponent(source)}|${encodeURIComponent(target)}`;
  const response = await fetch(url, { method: "GET" });
  if (!response.ok) {
    return null;
  }

  const data = (await response.json()) as {
    responseData?: { translatedText?: string };
  };
  const translatedText = (data.responseData?.translatedText ?? "").trim();
  return translatedText.length > 0 ? translatedText : null;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const body = (await req.json()) as TranslateRequest;
    const text = (body.text ?? "").trim();
    const source = (body.source ?? "ar").trim();
    const target = (body.target ?? "en").trim();

    if (!text) {
      return new Response(
        JSON.stringify({ error: "text is required" }),
        {
          status: 400,
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        },
      );
    }

    if (source === target) {
      return new Response(
        JSON.stringify({ translatedText: text }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } },
      );
    }

    const endpoint = Deno.env.get("TRANSLATE_API_URL");
    const apiKey = Deno.env.get("TRANSLATE_API_KEY");

    const libreEndpoints = endpoint != null && endpoint.trim().length > 0
      ? [endpoint.trim()]
      : [
          "https://libretranslate.com/translate",
          "https://translate.astian.org/translate",
        ];

    let translatedText: string | null = null;

    for (const libreEndpoint of libreEndpoints) {
      try {
        translatedText = await tryLibreTranslate(
          libreEndpoint,
          text,
          source,
          target,
          apiKey ?? undefined,
        );
        if (translatedText != null && translatedText.length > 0) {
          break;
        }
      } catch (_) {
      }
    }

    if (translatedText == null || translatedText.length == 0) {
      try {
        translatedText = await tryMyMemory(text, source, target);
      } catch (_) {
      }
    }

    const finalText = (translatedText ?? "").trim();

    return new Response(
      JSON.stringify({ translatedText: finalText.length == 0 ? text : finalText }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" } },
    );
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return new Response(
      JSON.stringify({ error: message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }
});
