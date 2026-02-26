# Deploy Instructions for FCM Function

This folder contains a Supabase Edge Function (`send-fcm`) to send Firebase Cloud Messaging (FCM) notifications.

The app can call this function directly from dashboard services when creating `news` and `breaking_news`, and it can also be triggered from `manual_notifications_log` via webhook.

## Prerequisites

1.  **Supabase CLI**: Make sure you have the Supabase CLI installed and logged in.
2.  **Firebase Project**: You need a Firebase project with Cloud Messaging enabled.
3.  **Service Account Key**: Go to Firebase Console -> Project Settings -> Service Accounts -> Generate New Private Key. Download the JSON file.

## Setup Steps

1.  **Set Environment Variable**:
    Run the following command to store your service account JSON as a secret in Supabase.
    Replace `path/to/service-account.json` with the path to your downloaded file.

    ```bash
    supabase secrets set --env-file .env
    # OR manually:
    supabase secrets set FIREBASE_SERVICE_ACCOUNT='{"type": "service_account", ... content of json ...}'
    ```

    *Tip: Minify the JSON first to avoid improved line break issues.*

2.  **Deploy the Function**:
    Run this command from the root of your project:

    ```bash
    supabase functions deploy send-fcm
    ```

3.  **(Optional) Set up Database Trigger for manual notifications**:
    Go to your Supabase Dashboard -> Database -> Webhooks (or Triggers).
    Create a new webhook:
    -   **Name**: `send-fcm-trigger`
    -   **Variable**: `INSERT` on table `public.manual_notifications_log`
    -   **Function**: Select the `send-fcm` function you just deployed.

    Alternatively, run this SQL in SQL Editor:

    ```sql
    create extension if not exists wrappers; -- Ensure http extension or similar if needed for calling edge functions directly via pg_net which is better
    
    -- Actually, Supabase uses Webhooks UI for this easily. 
    -- Or use the following Trigger if you prefer doing it in SQL (requires pg_net):
    
    -- (Recommended) Use the Dashboard Webhooks section to bind the INSERT event to the Edge Function.
    ```

## Testing

1.  In the dashboard, create a new **Main News** item or **Breaking News** item with notification enabled.
2.  Open Supabase **Edge Functions logs** and verify `send-fcm` invocation succeeded.
3.  If webhook is configured, also test from **Manual Notifications**.
