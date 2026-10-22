const cfg=window.EVENTO_CONFIG;const $=id=>document.getElementById(id);let client=null,ev=null;
function show(message,kind='error'){ $('message').textContent=message; $('message').className='message '+kind; }
async function init(){if(!cfg?.supabaseUrl||cfg.supabaseUrl.includes('TU-PROYECTO')||!cfg.supabaseKey||cfg.supabaseKey.startsWith('TU_')){show('El organizador aún no ha activado las inscripciones.');$('submitBtn').disabled=true;return;}try{client=window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseKey);const {data,error}=await client.from('events').select('*').eq('slug',cfg.eventSlug).eq('published',true).single();if(error)throw error;ev=data;$('title').textContent=ev.title;document.title=ev.title+' | Inscripción gratuita';$('description').textContent=ev.description||'';$('date').textContent='📅 '+(ev.event_date?new Date(ev.event_date+'T12:00:00').toLocaleDateString('es-ES',{day:'numeric',month:'long',year:'numeric'}):'Fecha por confirmar')+(ev.event_time?' · '+ev.event_time.slice(0,5):'');$('place').textContent='📍 '+(ev.location||'Ubicación por confirmar');
                                                                                                                                                                                                                                                
if (ev.location && ev.location.trim() &&
    ev.location !== 'Ubicación por confirmar') {
  const mapsLink = $('mapsLink');

  mapsLink.href =
    'https://www.google.com/maps/search/?api=1&query=' +
    encodeURIComponent(ev.location);

  mapsLink.classList.remove('hidden');
}

                                                                                                                                                                                                                                                $('org').textContent=ev.organizer||'Organización del evento';if(ev.image_url){$('poster').src=ev.image_url;$('poster').classList.remove('hidden');$('posterFallback').classList.add('hidden');$('poster').onerror=()=>{$('poster').classList.add('hidden');$('posterFallback').classList.remove('hidden');};}if(!ev.registration_open){$('submitBtn').disabled=true;show('Inscripciones cerradas por la organización.');}}catch(e){show('No se pudo cargar el evento. Comprueba la configuración.');$('submitBtn').disabled=true;console.error(e);}}
$('form').addEventListener('submit',async e=>{e.preventDefault();if(!client||!ev)return;if($('website').value)return;const b=$('submitBtn');b.disabled=true;show('Enviando inscripción…','success');const record={event_id:ev.id,first_name:$('first').value.trim(),last_name:$('last').value.trim(),email:$('email').value.trim().toLowerCase(),phone:$('phone').value.trim()||null,privacy_accepted:true};if(!record.first_name||!record.last_name||!record.email||!$('consent').checked){show('Completa los campos obligatorios.');b.disabled=false;return;}try{const {error}=await client.from('registrations').insert(record);if(error){if(error.code==='23505')show('Este correo ya está inscrito en el evento.');else throw error;}else{$('form').reset();show('¡Inscripción recibida! Tu plaza ha quedado registrada.','success');}}catch(err){show('No se pudo completar la inscripción. Inténtalo de nuevo.');console.error(err);}finally{b.disabled=false;}});init();
