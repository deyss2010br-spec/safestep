@@ -0,0 +1,565 @@
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1"/>
  <title>Safe Step VES — Todo integrado</title>

  <!-- Leaflet -->
  <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css"/>
  <style>
    :root{
      --primary:#3b2df0;
      --accent:#7b5bff;
      --danger:#ff3b5c;
      --safe:#28a745;
      --muted:#666;
      --card:#ffffff;
    }
    *{box-sizing:border-box}
    body{margin:0;font-family:Inter,Arial,Helvetica,sans-serif;background:linear-gradient(135deg,#fff8f9 0%,#eaf9ff 60%);color:#111}
    /* LOGIN */
    #loginScreen{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100vh;background:linear-gradient(180deg,var(--primary),var(--accent));color:white;padding:20px}
    #loginScreen input{padding:10px;border-radius:8px;border:none;width:240px;margin:6px}
    #loginScreen button{padding:10px 16px;border-radius:8px;border:none;background:#fff;color:var(--primary);font-weight:700;cursor:pointer}
    #app{display:none}
    header{background:linear-gradient(90deg,var(--primary),var(--accent));color:white;padding:14px;text-align:center;font-size:1.05rem;font-weight:700;box-shadow:0 8px 20px rgba(0,0,0,0.12)}
    .topbar{display:flex;justify-content:space-between;align-items:center;padding:10px;background:#fff;box-shadow:0 4px 18px rgba(0,0,0,0.04)}
    .userInfo{color:var(--primary);font-weight:700}
    .container{width:95%;max-width:1200px;margin:14px auto;display:grid;grid-template-columns:1fr 360px;gap:16px}
    @media(max-width:980px){.container{grid-template-columns:1fr}}
    .left,.right{display:flex;flex-direction:column;gap:12px}
    .card{background:var(--card);padding:14px;border-radius:12px;box-shadow:0 10px 30px rgba(0,0,0,0.06)}
    .card h3{margin:0 0 8px 0;color:var(--primary)}
    .muted{color:var(--muted);font-size:.95rem}
    button,.btn{padding:10px 12px;border-radius:10px;border:none;background:var(--primary);color:white;cursor:pointer;font-weight:700}
    .btn.ghost{background:transparent;color:var(--primary);border:2px solid rgba(59,45,240,0.08)}
    .small{padding:8px 10px;font-size:.95rem}
    input,select,textarea{width:100%;padding:8px;border-radius:8px;border:1px solid rgba(0,0,0,0.08)}
    #map{height:360px;border-radius:10px}
    #miniMap{height:140px;border-radius:8px}
    .floatingSOS{position:fixed;right:18px;bottom:18px;background:var(--danger);width:76px;height:76px;border-radius:50%;display:flex;align-items:center;justify-content:center;color:white;font-size:28px;cursor:pointer;z-index:999}
    .floatingCall{position:fixed;right:18px;bottom:110px;background:#1a9dff;width:56px;height:56px;border-radius:12px;display:flex;align-items:center;justify-content:center;color:white;font-size:20px;cursor:pointer;z-index:999}
    .listScroll{max-height:200px;overflow:auto;padding:6px;background:#fff;border-radius:8px;border:1px solid rgba(0,0,0,0.03)}
    footer{text-align:center;padding:10px;color:#666;margin-top:12px}
    .tiny{font-size:.85rem;color:var(--muted)}
    .btn-inline{display:inline-block;margin-left:6px}
  </style>
</head>
<body>

  <!-- LOGIN -->
  <div id="loginScreen">
    <h1>Safe Step — Villa El Salvador</h1>
    <p>Inicia sesión para usar la app (datos guardados localmente en tu navegador).</p>

    <div style="display:flex;gap:8px;margin-top:12px">
      <input id="regUser" placeholder="Nuevo usuario"/>
      <input id="regPass" placeholder="Contraseña (opcional)" type="password"/>
      <button onclick="register()">Registrar</button>
    </div>

    <div style="display:flex;gap:8px;margin-top:10px">
      <input id="username" placeholder="Usuario"/>
      <input id="password" placeholder="Contraseña" type="password"/>
      <button onclick="login()">Ingresar</button>
    </div>

    <div style="margin-top:10px"><small>Si no quieres contraseña, déjala vacía. También puedes usar "demo" como usuario.</small></div>
    <div style="margin-top:12px"><button onclick="useDemo()" style="background:#fff;color:var(--primary);padding:8px 12px;border-radius:8px;border:none">Usar demo</button></div>
  </div>

  <!-- APP -->
  <div id="app" aria-live="polite">
    <header>Safe Step VES — Villa El Salvador</header>

    <div class="topbar">
      <div><span class="userInfo">Usuario: <span id="userLabel"></span></span> <span class="tiny" id="userNote" style="margin-left:8px"></span></div>
      <div style="display:flex;gap:8px">
        <button class="btn small" onclick="logout()">Cerrar sesión</button>
        <button class="btn ghost small" onclick="exportAll()">Exportar datos</button>
      </div>
    </div>

    <div class="container">
      <div class="left">

        <!-- MAP + SOS -->
        <div class="card">
          <h3>🗺️ Mapa (Villa El Salvador) + SOS</h3>
          <div id="map"></div>
          <div style="display:flex;gap:8px;margin-top:10px;flex-wrap:wrap">
            <button class="btn" onclick="locateMe()">📍 Mostrar mi ubicación</button>
            <button class="btn ghost" onclick="centerVES()">Centrar VES</button>
            <button class="btn small ghost" onclick="copyLocationLink()">📋 Copiar enlace</button>
            <button class="btn small" onclick="sendSOS()">🚨 Activar SOS</button>
          </div>
          <p id="ubicacion" class="muted" style="margin-top:8px"></p>
        </div>

        <!-- SOS history -->
        <div class="card">
          <h3>📜 Historial SOS</h3>
          <div class="muted">Se guarda cada SOS con coordenadas y hora.</div>
          <div id="sosHistory" class="listScroll" style="margin-top:8px"></div>
          <div style="display:flex;gap:8px;margin-top:8px">
            <button class="btn" onclick="exportSosCSV()">Exportar CSV</button>
            <button class="btn ghost" onclick="clearSosHistory()">Limpiar historial</button>
          </div>
        </div>

        <!-- Survey -->
        <div class="card">
          <h3>📝 Cuestionario / Evaluación</h3>
          <div class="muted">Responde para evaluar tu nivel de riesgo en VES.</div>
          <form id="surveyForm" onsubmit="return false;" style="margin-top:8px">
            <label>1) ¿Te sientes seguro/a donde estás?</label>
            <select name="q1"><option value="">Selecciona</option><option value="0">Sí</option><option value="2">No</option></select>

            <label>2) ¿Sueles movilizarte en VES de noche?</label>
            <select name="q2"><option value="">Selecciona</option><option value="0">No</option><option value="1">Sí</option></select>

            <label>3) ¿Has visto o sufrido robos recientemente?</label>
            <select name="q3"><option value="">Selecciona</option><option value="0">No</option><option value="2">Sí</option></select>

            <label>4) ¿Tomas precauciones (compartir ubicación, evitar calles solas)?</label>
            <select name="q4"><option value="">Selecciona</option><option value="0">Sí</option><option value="1">No</option></select>

            <label>5) ¿Tienes a alguien que reciba tu check-in?</label>
            <select name="q5"><option value="">Selecciona</option><option value="0">Sí</option><option value="1">No</option></select>

            <div style="display:flex;gap:8px;margin-top:10px">
              <button class="btn" onclick="evaluateSurvey()">Evaluar</button>
              <button class="btn ghost" onclick="saveSurvey()">Guardar</button>
            </div>
            <p id="surveyResult" class="muted" style="margin-top:8px"></p>
          </form>
        </div>

        <!-- Reports -->
        <div class="card">
          <h3>📨 Reporte anónimo</h3>
          <form id="reportForm" onsubmit="return false;">
            <input id="repTitle" placeholder="Asunto (ej: Robo, Acoso)"/>
            <textarea id="repText" rows="3" placeholder="Descripción..."></textarea>
            <div style="display:flex;gap:8px;margin-top:8px">
              <button class="btn" onclick="saveReport()">Enviar y guardar</button>
              <button class="btn ghost" onclick="showReports()">Ver reportes</button>
            </div>
          </form>
          <div id="reportsList" class="listScroll" style="margin-top:8px"></div>
        </div>

      </div>

      <aside class="right">
        <div class="card">
          <h3>☎️ Contactos oficiales (Perú)</h3>
          <div style="display:flex;flex-direction:column;gap:8px">
            <a class="btn" href="tel:105">Policía Nacional (105)</a>
            <a class="btn" href="tel:116">Bomberos (116)</a>
            <a class="btn" href="tel:100">Línea 100 (Violencia)</a>
            <a class="btn ghost" href="tel:106">SAMU (106)</a>
          </div>
        </div>

        <div class="card">
          <h3>👥 Contactos personales</h3>
          <div class="muted">Guardar contactos que puedas llamar rápido.</div>
          <input id="pName" placeholder="Nombre" style="margin-top:8px"/>
          <input id="pPhone" placeholder="Teléfono (ej: +519...)" style="margin-top:6px"/>
          <div style="display:flex;gap:8px;margin-top:8px">
            <button class="btn small" onclick="addPersonalContact()">Agregar</button>
            <button class="btn ghost small" onclick="clearPersonalContacts()">Eliminar todos</button>
          </div>
          <div id="personalList" class="listScroll" style="margin-top:8px"></div>
        </div>

        <div class="card">
          <h3>📌 Zonas de riesgo / seguras (VES)</h3>
          <div id="miniMap"></div>
          <div style="margin-top:8px" class="muted">
            <div><b style="color:var(--danger)">●</b> Zonas de riesgo (estimadas)</div>
            <div><b style="color:var(--safe)">●</b> Zonas seguras (comisarías, centros de salud)</div>
          </div>
        </div>

        <div class="card">
          <h3>💡 Consejos dinámicos (VES)</h3>
          <div class="muted">Se adaptan según la hora del día (mañana/tarde/noche).</div>
          <ul id="tipsList" style="text-align:left;margin-top:8px"></ul>
          <div style="margin-top:8px" class="tiny">Consejos actualizados según hora local del dispositivo.</div>
        </div>
      </aside>
    </div>

    <footer>Safe Step VES — prototipo · datos guardados en tu navegador</footer>
  </div>

  <!-- Floating -->
  <div class="floatingSOS" title="SOS rápido" onclick="quickSOS()">🔴</div>
  <div class="floatingCall" title="Llamar 105" onclick="location.href='tel:105'">📞</div>

  <audio id="siren" src="https://actions.google.com/sounds/v1/emergency_siren/air_raid_siren.ogg" preload="auto"></audio>

  <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
  <script>
    /* ================== Variables globales ================== */
    let currentUser = null;
    let map=null, miniMap=null, lastMarker=null;

    /* ---------------- Session (simple) ---------------- */
    function register(){
      const user = document.getElementById('regUser').value.trim();
      const pass = document.getElementById('regPass').value || '';
      if(!user){ alert('Ingresa usuario para registrar'); return; }
      const users = JSON.parse(localStorage.getItem('ss_users')||'{}');
      users[user] = { pass: btoa(pass) };
      localStorage.setItem('ss_users', JSON.stringify(users));
      alert('Usuario registrado. Ahora inicia sesión.');
      document.getElementById('regUser').value=''; document.getElementById('regPass').value='';
    }

    function login(){
      const user = document.getElementById('username').value.trim();
      const pass = document.getElementById('password').value || '';
      if(!user){ alert('Ingresa usuario'); return; }
      const users = JSON.parse(localStorage.getItem('ss_users')||'{}');
      if(users[user]){
        if(users[user].pass !== btoa(pass) && pass !== ''){ alert('Contraseña incorrecta'); return; }
      }
      currentUser = user;
      localStorage.setItem('ves_active', currentUser);
      showApp();
    }

    function useDemo(){
      document.getElementById('username').value='demo';
      login();
    }

    function logout(){
      if(!confirm('Cerrar sesión?')) return;
      localStorage.removeItem('ves_active');
      location.reload();
    }

    window.addEventListener('load', ()=>{
      const u = localStorage.getItem('ves_active');
      if(u){ currentUser = u; showApp(); }
    });

    function userKey(k){ return `${currentUser}::${k}`; }

    function showApp(){
      document.getElementById('loginScreen').style.display='none';
      document.getElementById('app').style.display='block';
      document.getElementById('userLabel').textContent = currentUser;
      document.getElementById('userNote').textContent = '(sesión local)';
      loadUserData();
      initMap();
      initMiniMap();
      showTips();
      renderSosHistory();
      renderPersonalContacts();
      renderReports();
    }

    /* ---------------- Map y marcadores VES ---------------- */
    function initMap(){
      if(map) return;
      // Centrar en Villa El Salvador (coordenadas aproximadas)
      map = L.map('map').setView([-12.1608, -76.9757], 13);

      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',{ attribution: '&copy; OpenStreetMap' }).addTo(map);

      // Zonas de riesgo estimadas en VES (puedes ajustar con coordenadas más precisas)
      const risks = [
        {name:'Av. Pachacútec - tramo norte', lat:-12.1505, lon:-76.9792, info:'Sector con reportes de robos y poca iluminación por la noche.'},
        {name:'Zona industrial (cercanías Panamericana Sur)', lat:-12.1750, lon:-76.9800, info:'Tramos con baja actividad nocturna.'},
        {name:'AA.HH. densos (sectores periféricos)', lat:-12.1850, lon:-76.9725, info:'Barrios densos con movimientos nocturnos irregulares.'},
        {name:'Intersecciones oscuras y pasos laterales', lat:-12.1650, lon:-76.9900, info:'Cruces con menor visibilidad y mayor riesgo.'}
      ];
      risks.forEach(z=>{
        const color = '#ff3b5c';
        L.circle([z.lat, z.lon], {color, radius:250, fillOpacity:0.08}).addTo(map).bindPopup(`<b>${z.name}</b><br>${z.info}`);
        L.marker([z.lat, z.lon], {icon: L.divIcon({html:`<span style="color:${color}">●</span>`, className:''})}).addTo(map);
      });

      // Zonas seguras (comisaría, posta, bomberos, puesto de serenazgo)
      const safe = [
        {name:'Comisaría VES', lat:-12.1762, lon:-76.9709, info:'Comisaría local - atención policial'},
        {name:'Posta de Salud VES', lat:-12.1750, lon:-76.9690, info:'Centro de salud local'},
        {name:'Bomberos VES', lat:-12.1770, lon:-76.9675, info:'Cuerpo de bomberos'}
      ];
      safe.forEach(z=>{
        const color = '#28a745';
        L.circle([z.lat, z.lon], {color, radius:160, fillOpacity:0.06}).addTo(map).bindPopup(`<b>${z.name}</b><br>${z.info}`);
        L.marker([z.lat, z.lon], {icon: L.divIcon({html:`<span style="color:${color}">●</span>`, className:''})}).addTo(map);
      });

      // Guardar referencia mínima si se requiere
    }

    function initMiniMap(){
      if(miniMap) return;
      miniMap = L.map('miniMap', {zoomControl:false, attributionControl:false}).setView([-12.1608, -76.9757], 13);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(miniMap);
      // Repetir algunos marcadores pequeños
      [[-12.1505, -76.9792,'R1'],[-12.1750,-76.9800,'R2'],[-12.1762,-76.9709,'Comisaría']].forEach(p=>{
        L.marker([p[0],p[1]]).addTo(miniMap).bindPopup(p[2]);
      });
    }

    function centerVES(){ if(map) map.setView([-12.1608, -76.9757], 13); }

    /* ---------------- Geolocalización y SOS ---------------- */
    function locateMe(){
      if(!navigator.geolocation){ alert('Geolocalización no disponible'); return; }
      navigator.geolocation.getCurrentPosition(pos=>{
        const lat = pos.coords.latitude, lon = pos.coords.longitude;
        placeUserMarker(lat,lon);
        showLocationText(lat,lon);
      }, err => alert('Permiso denegado o error al obtener ubicación'));
    }

    function placeUserMarker(lat,lon){
      if(lastMarker) map.removeLayer(lastMarker);
      lastMarker = L.marker([lat,lon]).addTo(map).bindPopup('Tú estás aquí').openPopup();
      map.setView([lat,lon],15);
    }

    function showLocationText(lat,lon){
      const url = `https://www.google.com/maps?q=${lat},${lon}`;
      document.getElementById('ubicacion').innerHTML = `Lat: ${lat.toFixed(5)}, Lon: ${lon.toFixed(5)} — <a href="${url}" target="_blank">Abrir en Maps</a>`;
    }

    function copyLocationLink(){
      if(!navigator.geolocation){ alert('Geolocalización no disponible'); return; }
      navigator.geolocation.getCurrentPosition(pos=>{
        const url = `https://www.google.com/maps?q=${pos.coords.latitude},${pos.coords.longitude}`;
        navigator.clipboard.writeText(url).then(()=> alert('Enlace copiado al portapapeles'), ()=> alert('No se pudo copiar'));
      }, ()=> alert('Permiso denegado'));
    }

    function sendSOS(){
      if(!currentUser){ alert('Inicia sesión'); return; }
      if(!navigator.geolocation){ alert('Geolocalización no disponible'); return; }
      navigator.geolocation.getCurrentPosition(pos=>{
        const lat = pos.coords.latitude, lon = pos.coords.longitude;
        const at = new Date().toISOString();
        const url = `https://www.google.com/maps?q=${lat},${lon}`;
        const arr = JSON.parse(localStorage.getItem(userKey('sosHist'))||'[]');
        arr.unshift({at,lat,lon,url});
        localStorage.setItem(userKey('sosHist'), JSON.stringify(arr));
        renderSosHistory();
        placeUserMarker(lat,lon);
        showLocationText(lat,lon);
        try{ document.getElementById('siren').currentTime=0; document.getElementById('siren').play(); setTimeout(()=>document.getElementById('siren').pause(),3500);}catch(e){}
        alert('🚨 SOS registrado en historial. Comparte el enlace si necesitas ayuda.');
      }, ()=> alert('No se pudo obtener ubicación (permiso)'));
    }

    function quickSOS(){ if(confirm('Confirmar SOS rápido?')) sendSOS(); }

    /* ---------------- SOS history ---------------- */
    function renderSosHistory(){
      const el = document.getElementById('sosHistory');
      el.innerHTML = '';
      if(!currentUser){ el.innerHTML = '<div class="muted">Inicia sesión para ver historial</div>'; return; }
      const arr = JSON.parse(localStorage.getItem(userKey('sosHist'))||'[]');
      if(!arr.length){ el.innerHTML = '<div class="muted">Sin eventos SOS</div>'; return; }
      arr.slice(0,50).forEach(item=>{
        const d = new Date(item.at);
        const row = document.createElement('div');
        row.style.padding='6px'; row.style.borderBottom='1px solid #f1f1f1';
        row.innerHTML = `<b>${d.toLocaleString()}</b><br>${item.lat.toFixed(5)}, ${item.lon.toFixed(5)} — <a href="${item.url}" target="_blank">Maps</a>
                          <button class="btn small btn-inline" onclick="copyText('${item.url}')">Copiar</button>`;
        el.appendChild(row);
      });
    }

    function exportSosCSV(){
      const arr = JSON.parse(localStorage.getItem(userKey('sosHist'))||'[]');
      if(!arr.length){ alert('Nada que exportar'); return; }
      let csv = 'fecha,lat,lon,url\n';
      arr.forEach(r => csv += `${r.at},${r.lat},${r.lon},"${r.url}"\n`);
      downloadBlob(csv, `${currentUser}_ves_sos.csv`);
    }

    function clearSosHistory(){
      if(confirm('Eliminar historial SOS?')){ localStorage.removeItem(userKey('sosHist')); renderSosHistory(); }
    }

    /* ---------------- Personal contacts (call only) ---------------- */
    function addPersonalContact(){
      const name = document.getElementById('pName').value.trim();
      const phone = document.getElementById('pPhone').value.trim();
      if(!name || !phone){ alert('Completa nombre y teléfono'); return; }
      const arr = JSON.parse(localStorage.getItem(userKey('personal'))||'[]');
      arr.push({name,phone});
      localStorage.setItem(userKey('personal'), JSON.stringify(arr));
      document.getElementById('pName').value=''; document.getElementById('pPhone').value='';
      renderPersonalContacts();
    }

    function renderPersonalContacts(){
      const el = document.getElementById('personalList');
      el.innerHTML = '';
      const arr = JSON.parse(localStorage.getItem(userKey('personal'))||'[]');
      if(!arr.length){ el.innerHTML = '<div class="muted">No hay contactos personales</div>'; return; }
      arr.forEach((c,i)=>{
        const d = document.createElement('div');
        d.style.display='flex'; d.style.justifyContent='space-between'; d.style.alignItems='center'; d.style.padding='6px';
        d.innerHTML = `<div><b>${escapeHtml(c.name)}</b><br><small class="muted">${c.phone}</small></div>
                       <div style="display:flex;gap:6px">
                         <a class="btn small" href="tel:${c.phone}">Llamar</a>
                         <button class="btn ghost small" onclick="removePersonal(${i})">Eliminar</button>
                       </div>`;
        el.appendChild(d);
      });
    }

    function removePersonal(i){ const arr = JSON.parse(localStorage.getItem(userKey('personal'))||'[]'); arr.splice(i,1); localStorage.setItem(userKey('personal'), JSON.stringify(arr)); renderPersonalContacts(); }
    function clearPersonalContacts(){ if(confirm('Eliminar todos?')){ localStorage.removeItem(userKey('personal')); renderPersonalContacts(); } }

    /* ---------------- Reports (local) ---------------- */
    function saveReport(){
      const title = document.getElementById('repTitle').value.trim();
      const text = document.getElementById('repText').value.trim();
      if(!title || !text){ alert('Completa asunto y descripción'); return; }
      const arr = JSON.parse(localStorage.getItem(userKey('reports'))||'[]');
      arr.unshift({at:new Date().toLocaleString(), title, text});
      localStorage.setItem(userKey('reports'), JSON.stringify(arr));
      document.getElementById('repTitle').value=''; document.getElementById('repText').value='';
      renderReports();
      alert('Reporte guardado localmente.');
    }

    function renderReports(){
      const el = document.getElementById('reportsList');
      el.innerHTML = '';
      const arr = JSON.parse(localStorage.getItem(userKey('reports'))||'[]');
      if(!arr.length){ el.innerHTML = '<div class="muted">Sin reportes</div>'; return; }
      arr.forEach(r=>{
        const d = document.createElement('div'); d.style.padding='6px'; d.style.borderBottom='1px solid #f1f1f1';
        d.innerHTML = `<b>${escapeHtml(r.title)}</b> <small class="muted">${r.at}</small><div>${escapeHtml(r.text)}</div>`;
        el.appendChild(d);
      });
    }
    function showReports(){ const arr = JSON.parse(localStorage.getItem(userKey('reports'))||'[]'); if(!arr.length) return alert('No hay reportes'); alert(arr.map(x=>`${x.at} - ${x.title}`).join('\n')); }

    /* ---------------- Survey ---------------- */
    function evaluateSurvey(){
      const form = document.getElementById('surveyForm');
      let score = 0;
      for(let i=1;i<=5;i++){
        const val = form[`q${i}`].value;
        if(val===''){ document.getElementById('surveyResult').textContent = 'Completa todas las preguntas.'; return; }
        score += parseInt(val,10);
      }
      let res='';
      if(score>=5) res='🚨 Alto riesgo. Contacta 105 y comparte tu ubicación con alguien de confianza.';
      else if(score>=3) res='⚠️ Riesgo moderado. Activa check-in y comparte tu trayecto.';
      else res='✅ Riesgo bajo. Mantén precauciones.';
      document.getElementById('surveyResult').textContent = res;
      addEventLog('survey_eval', res);
    }

    function saveSurvey(){
      const form = document.getElementById('surveyForm');
      const obj={at:new Date().toLocaleString(), answers:{}};
      for(let i=1;i<=5;i++) obj.answers['q'+i]=form[`q${i}`].value || '';
      const arr = JSON.parse(localStorage.getItem(userKey('surveys'))||'[]');
      arr.unshift(obj);
      localStorage.setItem(userKey('surveys'), JSON.stringify(arr));
      alert('Encuesta guardada localmente.');
    }

    /* ---------------- Tips dinámicos por hora ---------------- */
    const tips = {
      morning: [
        'Si sales temprano, comparte tu ruta con alguien de confianza.',
        'Prioriza avenidas principales con mayor iluminación al amanecer.',
        'Evita atajos por calles sin comercio abierto.'
      ],
      afternoon: [
        'Durante el día mantén objetos de valor guardados y a la vista reducida.',
        'Si transitas por mercados o zonas comerciales, vigila bolsos y mochilas.',
        'Prefiere paraderos principales y evita esperar en calles solitarias.'
      ],
      night: [
        'Por la noche evita calles poco iluminadas y zonas poco concurridas.',
        'Coordina transporte seguro antes de salir de un local nocturno.',
        'Si te sientes inseguro, busca un establecimiento concurrido inmediatamente.'
      ]
    };

    function getPhase(){
      const h = new Date().getHours();
      if(h>=6 && h<12) return 'morning';
      if(h>=12 && h<18) return 'afternoon';
      return 'night';
    }

    function showTips(){
      const phase = getPhase();
      const pool = [...tips[phase], ...tips.morning, ...tips.afternoon, ...tips.night];
      pool.sort(()=>Math.random()-0.5);
      const list = document.getElementById('tipsList');
      list.innerHTML = '';
      pool.slice(0,4).forEach(t => { const li = document.createElement('li'); li.textContent = t; list.appendChild(li); });
    }

    /* ---------------- Utilities / storage ---------------- */
    function addEventLog(type, text){
      const arr = JSON.parse(localStorage.getItem(userKey('events'))||'[]');
      arr.unshift({at:new Date().toISOString(), type, text});
      localStorage.setItem(userKey('events'), JSON.stringify(arr));
    }

    function loadUserData(){
      renderSosHistory(); renderPersonalContacts(); renderReports(); showTips();
    }

    function copyText(txt){ navigator.clipboard.writeText(txt).then(()=>alert('Copiado'), ()=>alert('No se pudo copiar')); }
    function downloadBlob(content, filename){ const blob = new Blob([content], {type:'text/csv;charset=utf-8;'}); const url=URL.createObjectURL(blob); const a=document.createElement('a'); a.href=url; a.download=filename; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url); }

    function exportSosCSV(){
      const arr = JSON.parse(localStorage.getItem(userKey('sosHist'))||'[]');
      if(!arr.length){ alert('No hay historial'); return; }
      let csv='fecha,lat,lon,url\n';
      arr.forEach(r=> csv += `${r.at},${r.lat},${r.lon},"${r.url}"\n`);
      downloadBlob(csv, `${currentUser}_sos.csv`);
    }

    function exportAll(){
      if(!currentUser){ alert('Inicia sesión'); return; }
      const keys=['sosHist','personal','reports','surveys','events'];
      const out={};
      keys.forEach(k=> out[k]= JSON.parse(localStorage.getItem(userKey(k))||'[]'));
      const blob = new Blob([JSON.stringify(out,null,2)],{type:'application/json'});
      const url = URL.createObjectURL(blob);
      const a=document.createElement('a'); a.href=url; a.download=`${currentUser}_safe_step_ves.json`; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url);
    }

    /* ---------------- Helpers ---------------- */
    function escapeHtml(s){ return String(s||'').replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }
    function copyLocationLink(){ if(!navigator.geolocation){ alert('Geolocalización no disponible'); return; } navigator.geolocation.getCurrentPosition(pos=>{ const url=`https://www.google.com/maps?q=${pos.coords.latitude},${pos.coords.longitude}`; navigator.clipboard.writeText(url).then(()=>alert('Enlace copiado'), ()=>alert('No se pudo copiar')); }, ()=>alert('Permiso denegado')); }
    function downloadBlob(content, filename){ const blob=new Blob([content],{type:'text/csv'}); const url=URL.createObjectURL(blob); const a=document.createElement('a'); a.href=url; a.download=filename; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url); }

    /* ---------------- Personal: render on load ---------------- */
    function renderPersonalContacts(){ const el=document.getElementById('personalList'); el.innerHTML=''; const arr=JSON.parse(localStorage.getItem(userKey('personal'))||'[]'); if(!arr.length){ el.innerHTML='<div class="muted">No hay contactos personales</div>'; return; } arr.forEach((c,i)=>{ const d=document.createElement('div'); d.style.display='flex'; d.style.justifyContent='space-between'; d.style.alignItems='center'; d.style.padding='6px'; d.innerHTML=`<div><b>${escapeHtml(c.name)}</b><br><small class="muted">${c.phone}</small></div><div style="display:flex;gap:6px"><a class="btn small" href="tel:${c.phone}">Llamar</a><button class="btn ghost small" onclick="removePersonal(${i})">Eliminar</button></div>`; el.appendChild(d); }); }

    /* ---------------- remove personal ---------------- */
    function removePersonal(i){ const arr=JSON.parse(localStorage.getItem(userKey('personal'))||'[]'); arr.splice(i,1); localStorage.setItem(userKey('personal'), JSON.stringify(arr)); renderPersonalContacts(); }

    /* --------------- SOS quick wrappers --------------- */
    function renderSosHistory(){ const el=document.getElementById('sosHistory'); el.innerHTML=''; const arr=JSON.parse(localStorage.getItem(userKey('sosHist'))||'[]'); if(!arr.length){ el.innerHTML='<div class="muted">Sin eventos SOS</div>'; return; } arr.slice(0,50).forEach(item=>{ const d=new Date(item.at); const row=document.createElement('div'); row.style.padding='6px'; row.style.borderBottom='1px solid #f1f1f1'; row.innerHTML = `<b>${d.toLocaleString()}</b><br>${item.lat.toFixed(5)}, ${item.lon.toFixed(5)} — <a href="${item.url}" target="_blank">Maps</a> <button class="btn small btn-inline" onclick="copyText('${item.url}')">Copiar</button>`; el.appendChild(row); }); }

    /* helper to download blob (duplicated safe) */
    function downloadBlob(content, filename){ const blob = new Blob([content], {type:'text/csv;charset=utf-8;'}); const url = URL.createObjectURL(blob); const a = document.createElement('a'); a.href = url; a.download = filename; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(url); }

  </script>
</body>
</html>
