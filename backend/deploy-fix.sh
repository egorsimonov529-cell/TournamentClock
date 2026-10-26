#!/bin/bash

# Upload updated tableRoutes.js to server
echo "📤 Uploading tableRoutes.js to server..."
scp /c/Users/Lenovo/Desktop/works/MVP_Poker/tournament_clock/backend/src/routes/tableRoutes.js user@188.225.81.114:/var/www/poker-club/backend/src/routes/

if [ $? -eq 0 ]; then
    echo "✅ File uploaded successfully!"
    echo "🔄 Restarting backend..."
    ssh user@188.225.81.114 "cd /var/www/poker-club/backend && pm2 restart poker-backend --update-env"
    echo "✅ Backend restarted!"
    echo ""
    echo "📋 Logs (last 30 lines):"
    ssh user@188.225.81.114 "pm2 logs poker-backend --lines 30 --nostream"
else
    echo "❌ Upload failed!"
fi
