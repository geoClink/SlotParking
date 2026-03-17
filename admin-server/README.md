SlotParking Admin Server

Quick start:

1) Install dependencies

   npm install

2) Start server in dev mode

   ADMIN_TOKEN=dev-token-1234 npm run dev

3) Endpoints:

   GET /admin/lots?status=pending  - list pending lots (requires x-admin-token)
   POST /admin/lots/:id/approve    - approve lot (requires x-admin-token)
   POST /admin/lots/:id/reject     - reject lot with reason (requires x-admin-token)
   GET /lots                       - public endpoint returning approved lots

The server stores lots in admin-server/data/lots.json. For a quick pilot use the default token printed at startup.
