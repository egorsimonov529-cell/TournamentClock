const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  // You need to create a service account key JSON file
  // 1. Go to Firebase Console -> Project Settings -> Service Accounts
  // 2. Click "Generate new private key"
  // 3. Save the JSON file as 'serviceAccountKey.json' in the backend root
  // 4. Or use environment variables

  const serviceAccount = require('../serviceAccountKey.json');

  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

module.exports = admin;
