import React, { useEffect, useState } from 'react';
import axios from 'axios';

function PendingList({ token }){
  const [lots, setLots] = useState([]);

  async function fetchPending(){
    try{
      const res = await axios.get('http://localhost:4001/admin/lots?status=pending', { headers: { 'x-admin-token': token }});
      setLots(res.data);
    }catch(e){ console.error(e); }
  }

  useEffect(()=>{ fetchPending(); }, []);

  async function approve(id){
    await axios.post(`http://localhost:4001/admin/lots/${id}/approve`, {}, { headers: { 'x-admin-token': token }});
    fetchPending();
  }

  async function reject(id){
    const reason = prompt('Rejection reason (optional)') || '';
    await axios.post(`http://localhost:4001/admin/lots/${id}/reject`, { reason }, { headers: { 'x-admin-token': token }});
    fetchPending();
  }

  return (
    <div className="pending-list">
      <button onClick={fetchPending}>Refresh</button>
      <div style={{display:'grid', gridTemplateColumns:'repeat(auto-fill,minmax(320px,1fr))', gap:12}}>
        {lots.map(l => (
          <div key={l.id} className="card">
            <h3>{l.name}</h3>
            <div>{l.address}</div>
            <div>Spots: {l.availableSpots}/{l.totalSpots}</div>
            <div>Price: ${l.pricePerHour}/hr</div>
            <div>Submitted: {l.submittedAt || '—'}</div>
            <div style={{marginTop:8}}>
              <button onClick={()=>approve(l.id)}>Approve</button>
              <button onClick={()=>reject(l.id)} style={{marginLeft:8}}>Reject</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}

export default PendingList;
