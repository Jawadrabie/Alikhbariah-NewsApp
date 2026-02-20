// @ts-nocheck
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
// Import from esm.sh which bundles for Deno
import admin from "https://esm.sh/firebase-admin@11.11.0";

console.log("Hello from send-fcm Function!");

serve(async (req: Request) => {
  // Handle CORS
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
    } })
  }

  try {
    const { record } = await req.json();
    
    // Check if triggered by Database Webhook (INSERT into manual_notifications_log)
    // Or direct execution via HTTP
    let title = "";
    let body = "";
    
    if (record && record.title && record.body) {
      // Triggered by DB Insert
      title = record.title;
      body = record.body;
    } else {
      // Maybe direct HTTP call logic if needed
      // const { title: t, body: b } = await req.json(); // Already parsed above
      // But let's assume DB Trigger is the main use case
      return new Response(JSON.stringify({ error: "No record found in payload" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Initialize Firebase Admin if not already
    if (admin.apps.length === 0) {
      const serviceAccountStr = Deno.env.get("FIREBASE_SERVICE_ACCOUNT");
      if (!serviceAccountStr) {
        throw new Error("Missing FIREBASE_SERVICE_ACCOUNT environment variable");
      }
      const serviceAccount = JSON.parse(serviceAccountStr);
      
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
    
    return new Response(JSON.stringify({ success: true, messageId: response }), {
      headers: { "Content-Type": "application/json" },
    });

  } catch (error: unknown) {
    console.error(error);
    const message = error instanceof Error ? error.message : "Unknown error";
    return new Response(JSON.stringify({ error: message }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
