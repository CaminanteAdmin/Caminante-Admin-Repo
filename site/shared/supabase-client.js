// FYLL INN disse to verdiene fra Supabase-prosjektet (Project Settings → API).
// Anon-nøkkelen er trygg å ha i klientkoden – den er ment å være offentlig.
// All faktisk tilgangskontroll skjer via Row Level Security-reglene i sql/schema.sql,
// ikke ved å holde denne nøkkelen hemmelig.
window.SUPABASE_URL = "https://ihabhsqpzafusvxpikga.supabase.co";
window.SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImloYWJoc3FwemFmdXN2eHBpa2dhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQzMDM0NTAsImV4cCI6MjA5OTg3OTQ1MH0.bvNkA7t0hz0t7jTx8jHf4dEtrjFhGgkK9fcEqlo_L8s";

window.sb = supabase.createClient(window.SUPABASE_URL, window.SUPABASE_ANON_KEY);
