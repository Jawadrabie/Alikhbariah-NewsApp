// @ts-nocheck
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import admin from "npm:firebase-admin@12.7.0";

console.log("Hello from send-fcm Function!");

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(payload: Record<string, unknown>, status = 200) {
  return new Response(JSON.stringify(payload), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function parseServiceAccount(rawValue: string) {
  const raw = rawValue.trim();

  try {
    return JSON.parse(raw);
  } catch (_) {
  }

  let normalized = raw;
  if (
    (normalized.startsWith("\"") && normalized.endsWith("\"")) ||
    (normalized.startsWith("'") && normalized.endsWith("'"))
  ) {
    normalized = normalized.slice(1, -1);
  }

  normalized = normalized
    .replace(/\\n/g, "\n")
    .replace(/\\"/g, "\"");

  return JSON.parse(normalized);
}

function decodeBase64Utf8(value: string) {
  const bytes = Uint8Array.from(atob(value), (char) => char.charCodeAt(0));
  return new TextDecoder().decode(bytes);
}

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const payload = await req.json();
    const record = payload?.record ?? payload;
    
    // Check if triggered by Database Webhook (INSERT into manual_notifications_log)
    // Or direct execution via HTTP
    let title = "";
    let body = "";
    
    if (record && record.title && record.body) {
      // Triggered by DB Insert
      title = record.title;
      body = record.body;
    } else {
      return jsonResponse({ error: "No valid title/body found in payload" }, 400);
    }

    // Initialize Firebase Admin if not already
    if (admin.apps.length === 0) {
      const serviceAccountBase64 = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_BASE64");
      const serviceAccountStr = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");

      let serviceAccount;
      if (serviceAccountBase64 && serviceAccountBase64.trim().length > 0) {
        serviceAccount = JSON.parse(decodeBase64Utf8(serviceAccountBase64.trim()));
      } else if (serviceAccountStr && serviceAccountStr.trim().length > 0) {
        serviceAccount = parseServiceAccount(serviceAccountStr);
      } else {
        throw new Error("Missing FIREBASE_SERVICE_ACCOUNT_BASE64 or FIREBASE_SERVICE_ACCOUNT environment variable");
      }
      
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      topic: "all", // Send to 'all' topic by default
    };

    const response = await admin.messaging().send(message);

    return jsonResponse({ success: true, messageId: response });

  } catch (error: unknown) {
    console.error(error);
    const message = error instanceof Error ? error.message : "Unknown error";
    return jsonResponse({ error: message }, 500);
  }
});
