const jwt = require('jsonwebtoken');
const secret = process.env.JWT_SECRET || 'dev_secret_key';
const adminId = 'ff925e56-bbdf-46d7-ba9a-d0d4db0f2df3'; // from DB
const token = jwt.sign({ sub: adminId, role: 'admin' }, secret, { expiresIn: '7d' });
console.log(token);
