import React, { useState } from 'react';
import PendingList from './PendingList';
import './App.css';

function App(){
  const [token, setToken] = useState(localStorage.getItem('adminToken') || 'dev-token-1234');
  const [isAuthed, setAuthed] = useState(!!token);

  function handleSaveToken() {
    localStorage.setItem('adminToken', token);
    setAuthed(true);
  }

  if(!isAuthed) {
    return (
      <div className="login">
        <h2>Admin Login</h2>
        <input value={token} onChange={e=>setToken(e.target.value)} />
        <button onClick={handleSaveToken}>Save token</button>
      </div>
    )
  }

  return (
    <div className="app">
      <h1>SlotParking Admin</h1>
      <PendingList token={token} />
    </div>
  )
}

export default App;
