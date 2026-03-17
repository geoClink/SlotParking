require('dotenv').config();
const express = require('express');
const cors = require('cors');
const morgan = require('morgan');
const fs = require('fs-extra');
const bodyParser = require('body-parser');
const path = require('path');

const DATA_FILE = path.join(__dirname, 'data', 'lots.json');
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || 'dev-token-1234';

const app = express();
app.use(cors());
app.use(morgan('dev'));
app.use(bodyParser.json({ limit: '5mb' }));

// ensure data dir exists
fs.ensureDirSync(path.join(__dirname, 'data'));

// load initial data (if file missing create base from empty array)
if (!fs.existsSync(DATA_FILE)) {
  fs.writeJsonSync(DATA_FILE, []);
}

function readLots() {
  try {
    return fs.readJsonSync(DATA_FILE);
  } catch (e) {
    console.error('read error', e);
    return [];
  }
}

function writeLots(arr) {
  try {
    fs.writeJsonSync(DATA_FILE, arr, { spaces: 2 });
  } catch (e) { console.error('write error', e); }
}

// simple admin auth middleware
function adminAuth(req, res, next) {
  const token = req.headers['x-admin-token'];
  if (!token || token !== ADMIN_TOKEN) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  next();
}

// GET pending lots
app.get('/admin/lots', adminAuth, (req, res) => {
  const status = req.query.status;
  const lots = readLots();
  if (status) {
    res.json(lots.filter(l => l.status === status));
  } else {
    res.json(lots);
  }
});

// Approve
app.post('/admin/lots/:id/approve', adminAuth, (req, res) => {
  const id = req.params.id;
  const lots = readLots();
  const idx = lots.findIndex(l => l.id === id);
  if (idx === -1) return res.status(404).json({ error: 'Not found' });
  lots[idx].status = 'approved';
  lots[idx].updatedAt = new Date().toISOString();
  writeLots(lots);
  res.json({ success: true, lot: lots[idx] });
});

// Reject
app.post('/admin/lots/:id/reject', adminAuth, (req, res) => {
  const id = req.params.id;
  const reason = req.body.reason || '';
  const lots = readLots();
  const idx = lots.findIndex(l => l.id === id);
  if (idx === -1) return res.status(404).json({ error: 'Not found' });
  lots[idx].status = 'rejected';
  lots[idx].updatedAt = new Date().toISOString();
  lots[idx].rejectionReason = reason;
  writeLots(lots);
  res.json({ success: true });
});

// Sync endpoint for the app to fetch approved lots (GET /lots)
app.get('/lots', (req, res) => {
  const lots = readLots();
  const approved = lots.filter(l => l.status === 'approved');
  res.json(approved);
});

// Endpoint to add or update a lot (used by owner onboarding to register)
app.post('/lots', adminAuth, (req, res) => {
  const body = req.body;
  if (!body || !body.id) return res.status(400).json({ error: 'Invalid payload' });
  const lots = readLots();
  const idx = lots.findIndex(l => l.id === body.id);
  if (idx === -1) {
    lots.push(body);
  } else {
    lots[idx] = { ...lots[idx], ...body };
  }
  writeLots(lots);
  res.json({ success: true });
});

const port = process.env.PORT || 4001;
app.listen(port, () => console.log(`Admin server listening on ${port}, ADMIN_TOKEN=${ADMIN_TOKEN}`));
