/* ====================================================================
   Delt venstremeny for Caminante Admin.

   Bruk: legg til denne linjen på hver innlogget side, rett etter de
   andre delte script-taggene (supabase-client.js / auth.js):

     <script src="shared/nav.js"></script>

   Filen injiserer selv all HTML/CSS/JS den trenger (meny, hamburger-
   knapp på mobil, overlay) - ingen andre endringer kreves på siden.
   Skal IKKE inkluderes på login.html.

   Nytt menypunkt = én ny linje i CAM_NAV_ITEMS under. Sett `href` for
   et fungerende punkt, eller `disabled:true` for et kommende punkt
   (vises gråtonet med en "Snart"-merking, uten lenke).
   ==================================================================== */
(function(){

  const CAM_NAV_ITEMS = [
    { label: "Oversikt",       href: "index.html" },
    { label: "Priskalkulator", href: "priskalkulator.html" },
    { label: "Forslag & Tilbud", href: "forslag.html" },
    { label: "Reiser",         disabled: true },
    { label: "Påmeldinger",    disabled: true },
    { label: "Reisemål",       href: "reisemaal.html" },
    { label: "Hoteller",       href: "hoteller.html" },
    { label: "Scandic-poeng",  href: "scandic-poeng.html" },
    { label: "Skoleoversikt",  href: "skoler.html" },
    { label: "Kunder",         disabled: true },
    { label: "EuroBonus",      disabled: true },
    { label: "Dokumenter",     disabled: true },
  ];

  const CAM_SIDEBAR_WIDTH = 208; // px

  function currentFile(){
    const path = window.location.pathname.split("/").pop();
    return path === "" ? "index.html" : path;
  }

  function injectStyle(){
    const style = document.createElement("style");
    style.textContent = `
      @media (min-width:901px){
        body.cam-has-sidebar{ margin-left:${CAM_SIDEBAR_WIDTH}px; }
      }
      .cam-sidebar{
        position:fixed; top:0; left:0; bottom:0;
        width:${CAM_SIDEBAR_WIDTH}px;
        background:#fcfcfb;
        border-right:1px solid #e1e0d9;
        display:flex; flex-direction:column;
        z-index:15;
        transform:translateX(-100%);
        transition:transform .18s ease;
      }
      @media (min-width:901px){
        .cam-sidebar{ transform:translateX(0); }
      }
      .cam-sidebar.cam-open{ transform:translateX(0); }
      .cam-sidebar-brand{
        padding:16px 18px 14px;
        border-bottom:1px solid #e1e0d9;
      }
      .cam-sidebar-brand .cam-company{
        font-weight:650; font-size:14.5px; color:#0b0b0b; display:block;
      }
      .cam-sidebar-brand .cam-tagline{
        font-size:11px; color:#898781; margin-top:2px; display:block;
      }
      .cam-sidebar-nav{
        list-style:none; margin:0; padding:10px 0 16px;
        overflow-y:auto; flex:1 1 auto;
      }
      .cam-sidebar-nav li{ margin:0; }
      .cam-nav-item{
        display:flex; align-items:center; justify-content:space-between;
        gap:8px;
        padding:9px 18px;
        font-size:13.5px;
        color:#3d3c39;
        text-decoration:none;
        border-left:2.5px solid transparent;
        cursor:pointer;
      }
      a.cam-nav-item:hover{ background:#f4f3ef; }
      .cam-nav-item.cam-active{
        border-left-color:#184f95;
        background:#eef3f9;
        color:#0b0b0b;
        font-weight:650;
      }
      .cam-nav-item.cam-disabled{
        color:#b3b1a9;
        cursor:default;
      }
      .cam-soon-tag{
        font-size:9.5px;
        text-transform:uppercase;
        letter-spacing:0.03em;
        color:#b3b1a9;
        border:1px solid #e1e0d9;
        border-radius:20px;
        padding:1.5px 6px;
        white-space:nowrap;
      }
      .cam-hamburger{
        display:none;
        position:fixed; top:7px; left:12px;
        width:34px; height:34px;
        border:1px solid #e1e0d9; border-radius:8px;
        background:#fcfcfb;
        font-size:16px; line-height:1;
        align-items:center; justify-content:center;
        cursor:pointer;
        z-index:16;
      }
      .cam-overlay{
        display:none;
        position:fixed; inset:0;
        background:rgba(11,11,11,0.30);
        z-index:14;
      }
      .cam-overlay.cam-open{ display:block; }
      @media (max-width:900px){
        .cam-hamburger{ display:flex; }
        body.cam-has-sidebar{ padding-top:48px; }
      }
    `;
    document.head.appendChild(style);
  }

  function buildSidebar(){
    const file = currentFile();

    const aside = document.createElement("aside");
    aside.className = "cam-sidebar";
    aside.id = "camSidebar";

    const brand = document.createElement("div");
    brand.className = "cam-sidebar-brand";
    brand.innerHTML = `<span class="cam-company">Caminante</span><span class="cam-tagline">Admin</span>`;
    aside.appendChild(brand);

    const nav = document.createElement("nav");
    const ul = document.createElement("ul");
    ul.className = "cam-sidebar-nav";

    CAM_NAV_ITEMS.forEach(item=>{
      const li = document.createElement("li");
      const isActive = !item.disabled && item.href === file;
      const el = document.createElement(item.disabled ? "span" : "a");
      el.className = "cam-nav-item" + (isActive ? " cam-active" : "") + (item.disabled ? " cam-disabled" : "");
      if(!item.disabled) el.href = item.href;

      const labelSpan = document.createElement("span");
      labelSpan.textContent = item.label;
      el.appendChild(labelSpan);

      if(item.disabled){
        const tag = document.createElement("span");
        tag.className = "cam-soon-tag";
        tag.textContent = "Snart";
        el.appendChild(tag);
      }

      li.appendChild(el);
      ul.appendChild(li);
    });

    nav.appendChild(ul);
    aside.appendChild(nav);
    return aside;
  }

  function init(){
    injectStyle();
    document.body.classList.add("cam-has-sidebar");

    const overlay = document.createElement("div");
    overlay.className = "cam-overlay";
    overlay.id = "camOverlay";

    const hamburger = document.createElement("button");
    hamburger.type = "button";
    hamburger.className = "cam-hamburger";
    hamburger.id = "camHamburger";
    hamburger.setAttribute("aria-label", "Åpne meny");
    hamburger.textContent = "☰";

    const sidebar = buildSidebar();

    document.body.appendChild(overlay);
    document.body.appendChild(hamburger);
    document.body.appendChild(sidebar);

    function openMenu(){ sidebar.classList.add("cam-open"); overlay.classList.add("cam-open"); }
    function closeMenu(){ sidebar.classList.remove("cam-open"); overlay.classList.remove("cam-open"); }

    hamburger.addEventListener("click", ()=>{
      sidebar.classList.contains("cam-open") ? closeMenu() : openMenu();
    });
    overlay.addEventListener("click", closeMenu);
    sidebar.querySelectorAll("a.cam-nav-item").forEach(a=> a.addEventListener("click", closeMenu));
  }

  if(document.readyState === "loading"){
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
