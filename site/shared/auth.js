// Delt innloggingssjekk. Kalles øverst på alle sider unntatt login.html.
// Sender til login.html hvis ingen aktiv sesjon. Fyller ut #userName med
// brukerens visningsnavn (fra profiles-tabellen) hvis elementet finnes,
// og kobler en eventuell #logoutBtn til utlogging.
async function requireLogin(){
  const { data: { session } } = await window.sb.auth.getSession();
  if(!session){
    window.location.href = "login.html";
    return null;
  }
  const { data: profile } = await window.sb
    .from("profiles")
    .select("navn")
    .eq("id", session.user.id)
    .single();
  const nameEl = document.getElementById("userName");
  if(nameEl) nameEl.textContent = (profile && profile.navn) || session.user.email;
  return session;
}

async function doLogout(){
  await window.sb.auth.signOut();
  window.location.href = "login.html";
}

document.addEventListener("DOMContentLoaded", ()=>{
  const btn = document.getElementById("logoutBtn");
  if(btn) btn.addEventListener("click", doLogout);
});
